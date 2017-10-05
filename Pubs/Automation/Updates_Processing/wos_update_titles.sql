
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


-- Update table: wos_titles
\echo ***UPDATING TABLE: wos_titles
insert into uhs_wos_titles
  select a.* from wos_titles a inner join temp_update_wosid_titles b
  on a.source_id=b.source_id;
delete from wos_titles a where exists
  (select 1 from temp_update_wosid_4 b where a.source_id=b.source_id);

insert into wos_titles
  select * from new_wos_titles;
