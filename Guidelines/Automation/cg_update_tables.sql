-- This script updates the Clinical Guidelines (CG) tables in database.
-- Specifically:
-- 1. Load new uids to a new table: new_cg_uids;
-- 2. Generate a new uid_to_pmid mapping table.
-- 3. Copy records in the old tables but not in the new tables to new tables.
-- 4. Update the expired_date and status.
-- 5. Drop original old tables, rename new tables to current, current to old.
-- 6. Update the log.

-- Tables updated: cg_uids, cg_uid_pmid_mapping, update_log_cg.

-- Usage: psql -d ernie -f cg_update_tables.sql \
--        -v mapping="'"$c_dir"/uid_to_pmid.csv'" \
--        -v uids="'"$c_dir"/ngc_uid.csv'"

-- Author: Lingtian "Lindsay" Wan
-- Create Date: 03/23/2016
-- Modified: 05/20/2016, Lindsay Wan, added documentation
--            11/21/2016, Samet Keserci, revision wrt new schema plan
--            03/20/2017, Samet Keserci, revised according to migration from dev2 to dev3

-- Create a new table of uids.

SET search_path to public;


\echo ***LOADING TO NEW_CG_UIDS
drop table if exists new_cg_uids;
create table new_cg_uids
  (
    uid varchar(30),
    title varchar(1000),
    load_date date,
    expire_date date,
    status varchar(30)
  )
  tablespace ernie_cg_tbs;

-- Load UIDs to new table.
copy new_cg_uids (uid, title) from :combined;

-- Update log.
insert into update_log_cg (num_current_uid)
  select count(uid) from new_cg_uids;

-- Update uid table.
\echo ***UPDATING NEW_CG_UIDS
-- Set load_date of uids in new table to current date, status to 'current'.
update new_cg_uids
  set load_date = current_date, status = 'current';

-- Take uids in old table but not in new table to the new table.
insert into new_cg_uids
  (select a.* from cg_uids as a where a.uid not in
    (select uid from new_cg_uids));

-- Mark the above uids as expired and set expire date as current date.
update new_cg_uids
  set expire_date = current_date, status='expired'
  where load_date!=current_date and expire_date is Null;

-- Create a new table of uid-pmid mapping.
\echo ***LOADING TO NEW_CG_UID_PMID_MAPPING
drop table if exists new_cg_uid_pmid_mapping;
create table new_cg_uid_pmid_mapping
  (
    uid varchar(30),
    pmid varchar(50)
  )
  tablespace ernie_cg_tbs;

-- Load mapping file to new table.
copy new_cg_uid_pmid_mapping from :mapping delimiter ',' CSV;

-- Update mapping table.
\echo ***UPDATING NEW_CG_UID_PMID_MAPPING
insert into new_cg_uid_pmid_mapping
  (select a.* from cg_uid_pmid_mapping as a where a.uid not in
    (select uid from new_cg_uid_pmid_mapping));

-- Drop old tables.
\echo ***MODIFYING TABLES
drop table if exists old_cg_uids;
drop table if exists old_cg_uid_pmid_mapping;

-- Rename tables.
alter table cg_uids rename to old_cg_uids;
alter table cg_uid_pmid_mapping rename to old_cg_uid_pmid_mapping;
alter table new_cg_uids rename to cg_uids;
alter table new_cg_uid_pmid_mapping rename to cg_uid_pmid_mapping;

-- Update log table.
\echo ***UPDATING LOG
update update_log_cg
  set num_expired_uid =
  (select count(uid) from cg_uids where status='expired'),
  num_pmid =
  (select count(1) from cg_uid_pmid_mapping),
  last_updated = current_timestamp
  where id = (select max(id) from update_log_cg);
