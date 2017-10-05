
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


-- Update table: wos_addresses
\echo ***UPDATING TABLE: wos_addresses
insert into uhs_wos_addresses
  select a.* from wos_addresses a inner join temp_update_wosid_addresses b
  on a.source_id=b.source_id;

delete from wos_addresses a where exists
  (select 1 from temp_update_wosid_2 b where a.source_id=b.source_id);

insert into wos_addresses
  select * from new_wos_addresses;
