-- This script updates the wos_references with data from
-- newly-downloaded files. Specifically:

--     1. Find update_records: copy current records with WOS IDs in new table
--        to update history table: uhs_wos_publications.
--     2a. Delete records in main table that have same source_id in new table,
--         but cited_source_uid not in new table.
--     2b. Replace records in main table with records that have same
--         source_id & cited_source_uid in new table.
--     2c. Delete records in new table that have same source_id &
--         cited_source_uid in main table.
--     2d. Insert the remaining of new table to main table.
--     3. Truncate the new tables: new_wos_*.
--     4. Record to log table: update_log_wos.

-- Relevant main tables:
--     wos_references
-- Usage: psql -d ernie -f wos_update_ref_tables.sql
--        -v new_ref_chunk=$new_chunk
--        where $new_chunk are variables tablename passed by a shell script.

-- Author: Lingtian "Lindsay" Wan
-- Create Date: 06/06/2016
-- Modified: 06/07/2016, Lindsay Wan, added source_filename column
--           08/05/2016, Lindsay Wan, disabled hashjoin & mergejoin, added indexes
--           11/21/2016, Lindsay Wan, set search_path to public and lindsay
--           02/22/2017, Lindsay Wan, set search_path to public and samet
--           08/08/2017, Samet Keserci, index and tablespace are revised according to wos smokeload.


-- Set temporary tablespace for calculation.
set log_temp_files = 0;
--set enable_seqscan='off';
--set temp_tablespaces = 'temp_tbs';
SET temp_tablespaces='temp'; -- temporaryly it is being set.
--set enable_hashjoin = 'off';
--set enable_mergejoin = 'off';
set search_path = public;

-- Create index on the chunk of new table.
create index new_ref_chunk_idx on :new_ref_chunk
  using btree (source_id, cited_source_uid) tablespace ernie_index_tbs;

-- Create a temp table to store WOS IDs from the update file.
drop table if exists temp_update_ref_wosid;
create table temp_update_ref_wosid tablespace ernie_wos_tbs as
  select distinct source_id from :new_ref_chunk;
create index temp_update_ref_wosid_idx on temp_update_ref_wosid
  using hash (source_id) tablespace ernie_index_tbs;

analyze temp_update_ref_wosid;


-- Create a temporary table to store update WOS IDs that already exist in WOS
-- tables.
drop table if exists temp_replace_ref_wosid;
create table temp_replace_ref_wosid tablespace ernie_wos_tbs as
  select distinct a.source_id from temp_update_ref_wosid a
  inner join wos_references b
  on a.source_id=b.source_id;
create index temp_replace_ref_wosid_idx on temp_replace_ref_wosid
  using hash (source_id) tablespace ernie_index_tbs;

analyze temp_replace_ref_wosid;




-- Update table: wos_references
\echo ***UPDATING TABLE: wos_references
-- Create a temp table to store ids that need to be dealt with.
drop table if exists temp_wos_reference_1;
create table temp_wos_reference_1 tablespace ernie_wos_tbs as
  select a.source_id, a.cited_source_uid from wos_references a
  where exists
  (select 1 from temp_replace_ref_wosid b
    where a.source_id=b.source_id);
create index temp_wos_reference_1_idx on temp_wos_reference_1
  using btree (source_id, cited_source_uid) tablespace ernie_index_tbs;

analyze temp_wos_reference_1;

-- Copy records to be replaced or deleted to update history table.
insert into uhs_wos_references
  (select
   id, source_id, cited_source_uid, cited_title, cited_work, cited_author,
   cited_year, cited_page, created_date, last_modified_date, source_filename
   from wos_references a
   where exists
   (select * from temp_wos_reference_1 b
    where a.source_id=b.source_id
    and a.cited_source_uid=b.cited_source_uid));
-- Delete records with source_id in new table, but cited_source_uid not in.
delete from wos_references a
  using temp_replace_ref_wosid b
  where a.source_id=b.source_id
  and not exists
  (select 1 from :new_ref_chunk c
    where a.source_id=c.source_id
    and a.cited_source_uid=c.cited_source_uid);
-- Replace records with new records that have same source_id & cited_source_uid.
update wos_references as a
  set (cited_title, cited_work, cited_author, cited_year, cited_page,
    created_date, last_modified_date, source_filename) =
    (b.cited_title, b.cited_work, b.cited_author, b.cited_year, b.cited_page,
    b.created_date, b.last_modified_date, b.source_filename)
  from :new_ref_chunk b
  where a.source_id=b.source_id and a.cited_source_uid=b.cited_source_uid;
-- Delete records in new table that have already replaced main table records.
delete from :new_ref_chunk a using wos_references b
  where a.source_id=b.source_id and a.cited_source_uid=b.cited_source_uid;
-- Add remaining records (new) from new table to main table.
insert into wos_references
  (id, source_id, cited_source_uid, cited_title, cited_work, cited_author,
   cited_year, cited_page, created_date, last_modified_date, source_filename)
  select * from :new_ref_chunk;
-- Drop the chunked new table.
drop table :new_ref_chunk;
