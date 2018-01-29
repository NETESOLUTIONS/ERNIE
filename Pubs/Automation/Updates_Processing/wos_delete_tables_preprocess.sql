-- Author     : Samet Keserci,
-- Aim        : Preparation for parallel DELETE operation.
-- Create date: 08/28/2017

-- Set temporary tablespace for calculation.
SET log_temp_files = 0;
SET enable_seqscan = 'off';
--set temp_tablespaces = 'temp_tbs';
-- SET temp_tablespaces = 'temp'; -- temporaryly it is being set.
--set enable_hashjoin = 'off';
--set enable_mergejoin = 'off';
-- SET search_path = public;

-- Create a temporary table to store all delete WOSIDs.
DROP TABLE IF EXISTS temp_delete_wosid;
CREATE TABLE temp_delete_wosid (
  source_id VARCHAR(30)
) TABLESPACE wos;
COPY temp_delete_wosid FROM :'delete_csv' DELIMITER ',' CSV;

DROP TABLE IF EXISTS temp_delete_wosid_1;
CREATE TABLE temp_delete_wosid_1 TABLESPACE wos AS
  SELECT source_id
  FROM temp_delete_wosid;

DROP TABLE IF EXISTS temp_delete_wosid_2;
CREATE TABLE temp_delete_wosid_2 TABLESPACE wos AS
  SELECT source_id
  FROM temp_delete_wosid;

DROP TABLE IF EXISTS temp_delete_wosid_3;
CREATE TABLE temp_delete_wosid_3 TABLESPACE wos AS
  SELECT source_id
  FROM temp_delete_wosid;

DROP TABLE IF EXISTS temp_delete_wosid_4;
CREATE TABLE temp_delete_wosid_4 TABLESPACE wos AS
  SELECT source_id
  FROM temp_delete_wosid;

DROP TABLE IF EXISTS temp_delete_wosid_5;
CREATE TABLE temp_delete_wosid_5 TABLESPACE wos AS
  SELECT source_id
  FROM temp_delete_wosid;

DROP TABLE IF EXISTS temp_delete_wosid_6;
CREATE TABLE temp_delete_wosid_6 TABLESPACE wos AS
  SELECT source_id
  FROM temp_delete_wosid;

DROP TABLE IF EXISTS temp_delete_wosid_7;
CREATE TABLE temp_delete_wosid_7 TABLESPACE wos AS
  SELECT source_id
  FROM temp_delete_wosid;

DROP TABLE IF EXISTS temp_delete_wosid_8;
CREATE TABLE temp_delete_wosid_8 TABLESPACE wos AS
  SELECT source_id
  FROM temp_delete_wosid;

CREATE INDEX temp_delete_wosid_idx0
  ON temp_delete_wosid USING HASH (source_id) TABLESPACE indexes;
CREATE INDEX temp_delete_wosid_idx1
  ON temp_delete_wosid_1 USING HASH (source_id) TABLESPACE indexes;
CREATE INDEX temp_delete_wosid_idx2
  ON temp_delete_wosid_2 USING HASH (source_id) TABLESPACE indexes;
CREATE INDEX temp_delete_wosid_idx3
  ON temp_delete_wosid_3 USING HASH (source_id) TABLESPACE indexes;
CREATE INDEX temp_delete_wosid_idx4
  ON temp_delete_wosid_4 USING HASH (source_id) TABLESPACE indexes;
CREATE INDEX temp_delete_wosid_idx5
  ON temp_delete_wosid_5 USING HASH (source_id) TABLESPACE indexes;
CREATE INDEX temp_delete_wosid_idx6
  ON temp_delete_wosid_6 USING HASH (source_id) TABLESPACE indexes;
CREATE INDEX temp_delete_wosid_idx7
  ON temp_delete_wosid_7 USING HASH (source_id) TABLESPACE indexes;
CREATE INDEX temp_delete_wosid_idx8
  ON temp_delete_wosid_8 USING HASH (source_id) TABLESPACE indexes;

-- Update log table.
INSERT INTO update_log_wos (num_delete)
  SELECT count(1)
  FROM wos_publications a INNER JOIN temp_delete_wosid b ON a.source_id = b.source_id;
