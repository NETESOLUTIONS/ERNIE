
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


-- Update table: wos_keywords
\echo ***UPDATING TABLE: wos_keywords
--insert into uhs_wos_keywords
--  select a.* from wos_keywords a inner join temp_update_wosid_keywords b
--  on a.source_id=b.source_id;
delete from wos_keywords a where exists
  (select 1 from temp_update_wosid_2 b where a.source_id=b.source_id);

insert into wos_keywords
  select * from new_wos_keywords;
