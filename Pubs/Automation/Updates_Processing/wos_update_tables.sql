-- This script updates the main WOS table (wos_*) except wos_references with
-- data from newly-downloaded files. Specifically:

-- For all except wos_publications and wos_references:
--     1. Find update records: find WOS IDs that need to be updated, and move
--        current records with these WOS IDs to the update history tables:
--        uhs_wos_*.
--     2. Insert updated/new records: insert all the records from the new
--        tables (new_wos_*) into the main table: wos_*.
--     3. Delete records: move records with specified delete WOS IDs to the
--                        delete tables: del_wos_*.
--     4. Truncate the new tables: new_wos_*.
--     5. Record to log table: update_log_wos.

-- For wos_publications:
--     1. Find update_records: copy current records with WOS IDs in new table
--        to update history table: uhs_wos_publications.
--     2a. Update records: replace records in main table with same WOS IDs in
--         new table.
--     2b. Insert records: insert records with new WOS IDs in new table to main.
--     3,4,5: Same as above.

-- Relevant main tables:
--     1. wos_abstracts
--     2. wos_addresses
--     3. wos_authors
--     4. wos_document_identifiers
--     5. wos_grants
--     6. wos_keywords
--     7. wos_publications
--     8. wos_references not included in this script
--     9. wos_titles
-- Usage: psql -d ernie -f wos_update_tables.sql

-- Author: Lingtian "Lindsay" Wan
-- Create Date: 03/03/2016
-- Modified: 05/17/2016
--           06/06/2016, Lindsay Wan, deleted wos_references to another script
--           06/07/2016, Lindsay Wan, added begin_page, end_page, has_abstract columns to wos_publications
--           08/05/2016, Lindsay Wan, disabled hashjoin & mergejoin, added indexes
--           11/21/2016, Lindsay Wan, set search_path to public and lindsay
--           02/22/2017, Lindsay Wan, set search_path to public and samet
--           08/08/2017, Samet Keserci, index and tablespace are revised according to wos smokeload.


-- Set temporary tablespace for calculation.
set log_temp_files = 0;
set enable_seqscan='off';
--set temp_tablespaces = 'temp_tbs';
SET temp_tablespaces='temp'; -- temporaryly it is being set.
set enable_hashjoin = 'off';
set enable_mergejoin = 'off';
set search_path = public;

-- Create a temp table to store WOS IDs from the update file.
drop table if exists temp_update_wosid;
create table temp_update_wosid tablespace wos as
  select source_id from new_wos_publications;
create index temp_update_wosid_idx on temp_update_wosid
  using hash (source_id) tablespace indexes;

-- Create a temporary table to store update WOS IDs that already exist in WOS
-- tables.
drop table if exists temp_replace_wosid;
create table temp_replace_wosid tablespace wos as
  select a.source_id from temp_update_wosid a
  inner join wos_publications b
  on a.source_id=b.source_id;
create index temp_replace_wosid_idx on temp_replace_wosid
  using hash (source_id) tablespace indexes;

-- Update log file.
\echo ***UPDATING LOG TABLE
insert into update_log_wos (num_update)
  select count(*) from temp_replace_wosid;
update update_log_wos set num_new =
  (select count(*) from temp_update_wosid) - num_update
  where id = (select max(id) from update_log_wos);

-- Update table: wos_abstracts
\echo ***UPDATING TABLE: wos_abstracts
insert into uhs_wos_abstracts
  select a.* from wos_abstracts a inner join temp_update_wosid b
  on a.source_id=b.source_id;
delete from wos_abstracts a where exists
  (select 1 from temp_update_wosid b where a.source_id=b.source_id);
insert into wos_abstracts
  select * from new_wos_abstracts;

-- Update table: wos_addresses
\echo ***UPDATING TABLE: wos_addresses
insert into uhs_wos_addresses
  select a.* from wos_addresses a inner join temp_update_wosid b
  on a.source_id=b.source_id;
delete from wos_addresses a where exists
  (select 1 from temp_update_wosid b where a.source_id=b.source_id);
insert into wos_addresses
  select * from new_wos_addresses;

-- Update table: wos_authors
\echo ***UPDATING TABLE: wos_authors
insert into uhs_wos_authors
  select a.* from wos_authors a inner join temp_update_wosid b
  on a.source_id=b.source_id;
delete from wos_authors a where exists
  (select 1 from temp_update_wosid b where a.source_id=b.source_id);
insert into wos_authors
  select * from new_wos_authors;

-- Update table: wos_document_identifiers
\echo ***UPDATING TABLE: wos_document_identifiers
insert into uhs_wos_document_identifiers
  select a.* from wos_document_identifiers a inner join temp_update_wosid b
  on a.source_id=b.source_id;
delete from wos_document_identifiers a where exists
  (select 1 from temp_update_wosid b where a.source_id=b.source_id);
insert into wos_document_identifiers
  select * from new_wos_document_identifiers;

-- Update table: wos_grants
\echo ***UPDATING TABLE: wos_grants
insert into uhs_wos_grants
  select a.* from wos_grants a inner join temp_update_wosid b
  on a.source_id=b.source_id;
delete from wos_grants a where exists
  (select 1 from temp_update_wosid b where a.source_id=b.source_id);
insert into wos_grants
  select * from new_wos_grants;

-- Update table: wos_keywords
\echo ***UPDATING TABLE: wos_keywords
insert into uhs_wos_keywords
  select a.* from wos_keywords a inner join temp_update_wosid b
  on a.source_id=b.source_id;
delete from wos_keywords a where exists
  (select 1 from temp_update_wosid b where a.source_id=b.source_id);
insert into wos_keywords
  select * from new_wos_keywords;

-- Update table: wos_publications
\echo ***UPDATING TABLE: wos_publications
insert into uhs_wos_publications
  select
    id, source_id, source_type, source_title, language, document_title,
    document_type, has_abstract, issue, volume, begin_page, end_page,
    publisher_name, publisher_address, publication_year, publication_date,
    created_date, last_modified_date, edition, source_filename
  from wos_publications a
  where exists
  (select 1 from temp_replace_wosid b where a.source_id=b.source_id);
update wos_publications as a
  set (source_id, source_type, source_title, language, document_title,
    document_type, has_abstract, issue, volume, begin_page, end_page,
    publisher_name, publisher_address, publication_year, publication_date,
    created_date, last_modified_date, edition, source_filename) =
    (b.source_id, b.source_type, b.source_title, b.language, b.document_title,
    b.document_type, b.has_abstract, b.issue, b.volume, b.begin_page,
    b.end_page, b.publisher_name, b.publisher_address, b.publication_year,
    b.publication_date, b.created_date, b.last_modified_date, b.edition,
    b.source_filename)
  from new_wos_publications b where a.source_id=b.source_id;
insert into wos_publications
  (id, source_id, source_type, source_title, language, document_title,
   document_type, has_abstract, issue, volume, begin_page, end_page,
   publisher_name, publisher_address, publication_year, publication_date,
   created_date, last_modified_date, edition, source_filename)
  select * from new_wos_publications a
  where not exists
  (select * from temp_replace_wosid b where a.source_id=b.source_id);

-- Update table: wos_titles
\echo ***UPDATING TABLE: wos_titles
insert into uhs_wos_titles
  select a.* from wos_titles a inner join temp_update_wosid b
  on a.source_id=b.source_id;
delete from wos_titles a where exists
  (select 1 from temp_update_wosid b where a.source_id=b.source_id);
insert into wos_titles
  select * from new_wos_titles;

-- Truncate new_wos_tables.
\echo ***TRUNCATING TABLES: new_wos_*
truncate table new_wos_abstracts;
truncate table new_wos_addresses;
truncate table new_wos_authors;
truncate table new_wos_document_identifiers;
truncate table new_wos_grants;
truncate table new_wos_keywords;
truncate table new_wos_publications;
truncate table new_wos_titles;

-- Write date to log.
update update_log_wos
  set num_wos = (select count(1) from wos_publications)
  where id = (select max(id) from update_log_wos);
