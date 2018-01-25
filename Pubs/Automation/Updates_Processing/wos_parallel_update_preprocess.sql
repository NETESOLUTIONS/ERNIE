
-- Author: Samet Keserci, Lingtian "Lindsay" Wan
-- Create Date: 08/11/2017
-- Modified from serial loading process.

-- Set temporary tablespace for calculation.
set log_temp_files = 0;
set enable_seqscan='off';
--set temp_tablespaces = 'temp_tbs';
SET temp_tablespaces='temp'; -- temporaryly it is being set.
--set enable_hashjoin = 'off';
--set enable_mergejoin = 'off';
set search_path = public;

-- Create a temp table to store WOS IDs from the update file.
drop table if exists temp_update_wosid;
create table temp_update_wosid tablespace ernie_wos_tbs as
  select source_id from new_wos_publications;
create index temp_update_wosid_idx on temp_update_wosid
  using hash (source_id) tablespace indexes;

drop table if exists temp_update_wosid_1;
create table temp_update_wosid_1 tablespace ernie_wos_tbs as
select source_id from temp_update_wosid;

drop table if exists temp_update_wosid_2;
create table temp_update_wosid_2 tablespace ernie_wos_tbs as
select source_id from temp_update_wosid;

drop table if exists temp_update_wosid_3;
create table temp_update_wosid_3 tablespace ernie_wos_tbs as
select source_id from temp_update_wosid;

drop table if exists temp_update_wosid_4;
create table temp_update_wosid_4 tablespace ernie_wos_tbs as
select source_id from temp_update_wosid;

analyze temp_update_wosid;
analyze temp_update_wosid_1;
analyze temp_update_wosid_2;
analyze temp_update_wosid_3;
analyze temp_update_wosid_4;


-- Create a temporary table to store update WOS IDs that already exist in WOS
-- tables.
drop table if exists temp_replace_wosid;
create table temp_replace_wosid tablespace ernie_wos_tbs as
  select a.source_id from temp_update_wosid a
  inner join wos_publications b
  on a.source_id=b.source_id;
create index temp_replace_wosid_idx on temp_replace_wosid
  using hash (source_id) tablespace indexes;

analyze temp_replace_wosid;

  -- Update log file.
  \echo ***UPDATING LOG TABLE
  insert into update_log_wos (num_update)
    select count(*) from temp_replace_wosid;
  update update_log_wos set num_new =
    (select count(*) from temp_update_wosid) - num_update
    where id = (select max(id) from update_log_wos);



--drop table if exists temp_update_wosid_grants;
--create table temp_update_wosid_grants tablespace ernie_wos_tbs as
--select source_id from temp_update_wosid;

--drop table if exists temp_update_wosid_keywords;
--create table temp_update_wosid_keywords tablespace ernie_wos_tbs as
--select source_id from temp_update_wosid;

--drop table if exists temp_update_wosid_publications;
--create table temp_update_wosid_publications tablespace ernie_wos_tbs as
--select source_id from temp_update_wosid;

--drop table if exists temp_update_wosid_titles;
--create table temp_update_wosid_titles tablespace ernie_wos_tbs as
--select source_id from temp_update_wosid;

--drop table if exists temp_replace_wosid_1;
--  create table temp_replace_wosid_1 tablespace ernie_wos_tbs as
--  select source_id from temp_replace_wosid;

--  drop table if exists temp_replace_wosid_2;
--  create table temp_replace_wosid_2 tablespace ernie_wos_tbs as
--  select source_id from temp_replace_wosid;

--  drop table if exists temp_replace_wosid_3;
--  create table temp_replace_wosid_3 tablespace ernie_wos_tbs as
--  select source_id from temp_replace_wosid;

--  drop table if exists temp_replace_wosid_4;
--  create table temp_replace_wosid_4 tablespace ernie_wos_tbs as
--  select source_id from temp_replace_wosid;

--drop table if exists temp_replace_wosid_grants;
--create table temp_replace_wosid_grants tablespace ernie_wos_tbs as
--select source_id from temp_replace_wosid;

--drop table if exists temp_replace_wosid_keywords;
--create table temp_replace_wosid_keywords tablespace ernie_wos_tbs as
--select source_id from temp_replace_wosid;

--drop table if exists temp_replace_wosid_publications;
--create table temp_replace_wosid_publications tablespace ernie_wos_tbs as
--select source_id from temp_replace_wosid;

--drop table if exists temp_replace_wosid_titles;
--create table temp_replace_wosid_titles tablespace ernie_wos_tbs as
--select source_id from temp_replace_wosid;
