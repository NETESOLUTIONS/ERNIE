-- This script deletes records in the main WOS table (wos_*) with source_id
-- from wos*.del files.
-- Specifically, it does the following things:
--     1. Delete records: move records with specified delete WOS IDs to the
--                        delete tables: del_wos_*.
--     2. Record to log table: update_log_wos.
-- Relevant main tables:
--     1. wos_abstracts
--     2. wos_addresses
--     3. wos_authors
--     4. wos_document_identifiers
--     5. wos_grants
--     6. wos_keywords
--     7. wos_publications
--     8. wos_references
--     9. wos_titles
-- Usage: psql -d ernie -f wos_delete_tables.sql \
--        -v delete_csv="'"$c_dir"del_wosid.csv'"

-- Author: Lingtian "Lindsay" Wan
-- Create Date: 03/04/2016
-- Modified: 05/17/2016
--           08/06/2016, Lindsay Wan, disabled hashjoin & mergerjoin, added column names to wos_publications & wos_references
--           11/21/2016, Lindsay Wan, set search_path to public and lindsay
--           02/22/2017, Lindsay Wan, set search_path to public and samet

-- Set temporary tablespace for calculation.
set log_temp_files = 0;
set enable_seqscan='off';
--set temp_tablespaces = 'temp_tbs';
SET temp_tablespaces='temp'; -- temporaryly it is being set.
set enable_hashjoin = 'off';
set enable_mergejoin = 'off';
set search_path = public;

-- Create a temporary table to store all delete WOSIDs.
drop table if exists temp_delete_wosid;
create table temp_delete_wosid
  (source_id varchar(30))
  tablespace ernie_wos_tbs;
copy temp_delete_wosid from :delete_csv delimiter ',' CSV;

-- Update log table.
insert into update_log_wos (num_delete)
  select count(1) from wos_publications a
    inner join temp_delete_wosid b
    on a.source_id=b.source_id;

-- Delete wos_abstracts to del_wos_abstracts.
\echo ***DELETING FROM TABLE: wos_abstracts
insert into del_wos_abstracts
  select a.* from wos_abstracts a inner join temp_delete_wosid b
  on a.source_id=b.source_id;
delete from wos_abstracts a
  where exists
  (select 1 from temp_delete_wosid b
    where a.source_id=b.source_id);

-- Delete wos_addresses to del_wos_addresses.
\echo ***DELETING FROM TABLE: wos_addresses
insert into del_wos_addresses
  select a.* from wos_addresses a inner join temp_delete_wosid b
  on a.source_id=b.source_id;
delete from wos_addresses a
  where exists
  (select 1 from temp_delete_wosid b
    where a.source_id=b.source_id);

-- Delete wos_authors to del_wos_authors.
\echo ***DELETING FROM TABLE: wos_authors
insert into del_wos_authors
  select a.* from wos_authors a inner join temp_delete_wosid b
  on a.source_id=b.source_id;
delete from wos_authors a
  where exists
  (select 1 from temp_delete_wosid b
    where a.source_id=b.source_id);

-- Delete wos_document_identifiers to del_wos_document_identifiers.
\echo ***DELETING FROM TABLE: wos_document_identifiers
insert into del_wos_document_identifiers
  select a.* from wos_document_identifiers a inner join temp_delete_wosid b
  on a.source_id=b.source_id;
delete from wos_document_identifiers a
  where exists
  (select 1 from temp_delete_wosid b
    where a.source_id=b.source_id);

-- Delete wos_grants to del_wos_grants.
\echo ***DELETING FROM TABLE: wos_grants
insert into del_wos_grants
  select a.* from wos_grants a inner join temp_delete_wosid b
  on a.source_id=b.source_id;
delete from wos_grants a
  where exists
  (select 1 from temp_delete_wosid b
    where a.source_id=b.source_id);

-- Delete wos_keywords to del_wos_keywords.
\echo ***DELETING FROM TABLE: wos_keywords
insert into del_wos_keywords
  select a.* from wos_keywords a inner join temp_delete_wosid b
  on a.source_id=b.source_id;
delete from wos_keywords a
  where exists
  (select 1 from temp_delete_wosid b
    where a.source_id=b.source_id);

-- Delete wos_publications to del_wos_publications.
\echo ***DELETING FROM TABLE: wos_publications
insert into del_wos_publications
  select a.id, a.source_id, a.source_type, a.source_title, a.language,
  a.document_title, a.document_type, a.has_abstract, a.issue, a.volume,
  a.begin_page, a.end_page, a.publisher_name, a.publisher_address,
  a.publication_year, a.publication_date, a.created_date, a.last_modified_date,
  a.edition, a.source_filename
  from wos_publications a inner join temp_delete_wosid b
  on a.source_id=b.source_id;
delete from wos_publications a
  where exists
  (select 1 from temp_delete_wosid b
    where a.source_id=b.source_id);

-- Delete wos_references to del_wos_references.
\echo ***DELETING FROM TABLE: wos_references
insert into del_wos_references
  select a.id, a.source_id, a.cited_source_uid, a.cited_title, a.cited_work,
  a.cited_author, a.cited_year, a.cited_page, a.created_date,
  a.last_modified_date, a.source_filename
  from wos_references a inner join temp_delete_wosid b
  on a.source_id=b.source_id;
delete from wos_references a
  where exists
  (select 1 from temp_delete_wosid b
    where a.source_id=b.source_id);

-- Delete wos_titles to del_wos_titles.
\echo ***DELETING FROM TABLE: wos_titles
insert into del_wos_titles
  select a.* from wos_titles a inner join temp_delete_wosid b
  on a.source_id=b.source_id;
delete from wos_titles a
  where exists
  (select 1 from temp_delete_wosid b
    where a.source_id=b.source_id);

-- Update log table.
update update_log_wos
  set last_updated = current_timestamp,
  num_wos = (select count(1) from wos_publications)
  where id = (select max(id) from update_log_wos);
