-- Author: Samet Keserci, Lingtian "Lindsay" Wan
-- Create Date: 08/11/2017
-- Modified from serial loading process.

\set ON_ERROR_STOP on
\set ECHO all

-- Set temporary tablespace for calculation.
SET log_temp_files = 0;

-- Update table: wos_abstracts
\echo ***UPDATING TABLE: wos_abstracts
INSERT INTO uhs_wos_abstracts
  SELECT a.*
  FROM wos_abstracts a INNER JOIN temp_update_wosid_1 b ON a.source_id = b.source_id;

DELETE FROM wos_abstracts a
WHERE exists(SELECT 1
             FROM temp_update_wosid_1 b
             WHERE a.source_id = b.source_id);

INSERT INTO wos_abstracts
  SELECT *
  FROM new_wos_abstracts;