-- Author     : Samet Keserci,
-- Aim        : Preparation for parallel DELETE operation.
-- Create date: 08/28/2017


-- Set temporary tablespace for calculation.
set log_temp_files = 0;
set enable_seqscan='off';
--set temp_tablespaces = 'temp_tbs';
SET temp_tablespaces='temp'; -- temporaryly it is being set.
--set enable_hashjoin = 'off';
--set enable_mergejoin = 'off';
set search_path = public;


-- Create a temporary table to store all delete WOSIDs.
drop table if exists temp_delete_wosid;
create table temp_delete_wosid
  (source_id varchar(30))
  tablespace ernie_wos_tbs;
copy temp_delete_wosid from :delete_csv delimiter ',' CSV;


drop table if exists temp_delete_wosid_1;
create table temp_delete_wosid_1 tablespace ernie_wos_tbs as
select source_id from temp_delete_wosid;

drop table if exists temp_delete_wosid_2;
create table temp_delete_wosid_2 tablespace ernie_wos_tbs as
select source_id from temp_delete_wosid;

drop table if exists temp_delete_wosid_3;
create table temp_delete_wosid_3 tablespace ernie_wos_tbs as
select source_id from temp_delete_wosid;

drop table if exists temp_delete_wosid_4;
create table temp_delete_wosid_4 tablespace ernie_wos_tbs as
select source_id from temp_delete_wosid;

drop table if exists temp_delete_wosid_5;
create table temp_delete_wosid_5 tablespace ernie_wos_tbs as
select source_id from temp_delete_wosid;

drop table if exists temp_delete_wosid_6;
create table temp_delete_wosid_6 tablespace ernie_wos_tbs as
select source_id from temp_delete_wosid;

drop table if exists temp_delete_wosid_7;
create table temp_delete_wosid_7 tablespace ernie_wos_tbs as
select source_id from temp_delete_wosid;

drop table if exists temp_delete_wosid_8;
create table temp_delete_wosid_8 tablespace ernie_wos_tbs as
select source_id from temp_delete_wosid;


create index temp_delete_wosid_idx0 on temp_delete_wosid using hash (source_id) tablespace indexes;
create index temp_delete_wosid_idx1 on temp_delete_wosid_1 using hash (source_id) tablespace indexes;
create index temp_delete_wosid_idx2 on temp_delete_wosid_2 using hash (source_id) tablespace indexes;
create index temp_delete_wosid_idx3 on temp_delete_wosid_3 using hash (source_id) tablespace indexes;
create index temp_delete_wosid_idx4 on temp_delete_wosid_4 using hash (source_id) tablespace indexes;
create index temp_delete_wosid_idx5 on temp_delete_wosid_5 using hash (source_id) tablespace indexes;
create index temp_delete_wosid_idx6 on temp_delete_wosid_6 using hash (source_id) tablespace indexes;
create index temp_delete_wosid_idx7 on temp_delete_wosid_7 using hash (source_id) tablespace indexes;
create index temp_delete_wosid_idx8 on temp_delete_wosid_8 using hash (source_id) tablespace indexes;


-- Update log table.
insert into update_log_wos (num_delete)
  select count(1) from wos_publications a
    inner join temp_delete_wosid b
    on a.source_id=b.source_id;
