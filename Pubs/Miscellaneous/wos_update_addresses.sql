-- Author: Samet Keserci, Lingtian "Lindsay" Wan
-- Create Date: 08/11/2017
-- Modified from serial loading process.

\set ON_ERROR_STOP on
\set ECHO all

-- Set temporary tablespace for calculation.
SET log_temp_files = 0;
--set enable_seqscan='off';
--set temp_tablespaces = 'temp_tbs';
--set enable_hashjoin = 'off';
--set enable_mergejoin = 'off';

-- Update table: wos_addresses
\echo ***UPDATING TABLE: wos_addresses
INSERT INTO uhs_wos_addresses
  SELECT a.*
  FROM wos_addresses a INNER JOIN temp_update_wosid_2 b ON a.source_id = b.source_id;

DELETE FROM wos_addresses a
WHERE exists(SELECT 1
             FROM temp_update_wosid_2 b
             WHERE a.source_id = b.source_id);

INSERT INTO wos_addresses
  SELECT *
  FROM new_wos_addresses;