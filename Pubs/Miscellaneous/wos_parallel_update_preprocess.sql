-- Author: Samet Keserci, Lingtian "Lindsay" Wan
-- Create Date: 08/11/2017
-- Modified from serial loading process.

\set ON_ERROR_STOP on
\set ECHO all

-- Set temporary tablespace for calculation.
SET log_temp_files = 0;
SET enable_seqscan = 'off';
--set enable_hashjoin = 'off';
--set enable_mergejoin = 'off';

-- Create a temp table to store WOS IDs from the update file.
DROP TABLE IF EXISTS temp_update_wosid;
CREATE TABLE temp_update_wosid TABLESPACE wos AS
  SELECT source_id
  FROM new_wos_publications;
CREATE INDEX temp_update_wosid_idx
  ON temp_update_wosid USING HASH (source_id) TABLESPACE indexes;

DROP TABLE IF EXISTS temp_update_wosid_1;
CREATE TABLE temp_update_wosid_1 TABLESPACE wos AS
  SELECT source_id
  FROM temp_update_wosid;

DROP TABLE IF EXISTS temp_update_wosid_2;
CREATE TABLE temp_update_wosid_2 TABLESPACE wos AS
  SELECT source_id
  FROM temp_update_wosid;

DROP TABLE IF EXISTS temp_update_wosid_3;
CREATE TABLE temp_update_wosid_3 TABLESPACE wos AS
  SELECT source_id
  FROM temp_update_wosid;

DROP TABLE IF EXISTS temp_update_wosid_4;
CREATE TABLE temp_update_wosid_4 TABLESPACE wos AS
  SELECT source_id
  FROM temp_update_wosid;

ANALYZE temp_update_wosid;
ANALYZE temp_update_wosid_1;
ANALYZE temp_update_wosid_2;
ANALYZE temp_update_wosid_3;
ANALYZE temp_update_wosid_4;

-- Create a temporary table to store update WOS IDs that already exist in WOS
-- tables.
DROP TABLE IF EXISTS temp_replace_wosid;
CREATE TABLE temp_replace_wosid TABLESPACE wos AS
  SELECT a.source_id
  FROM temp_update_wosid a INNER JOIN wos_publications b ON a.source_id = b.source_id;
CREATE INDEX temp_replace_wosid_idx
  ON temp_replace_wosid USING HASH (source_id) TABLESPACE indexes;

ANALYZE temp_replace_wosid;

-- Update log file.
\echo ***UPDATING LOG TABLE
INSERT INTO update_log_wos (num_update)
  SELECT count(*)
  FROM temp_replace_wosid;
UPDATE update_log_wos
SET num_new = (SELECT count(*)
FROM temp_update_wosid) - num_update
WHERE id = (SELECT max(id)
FROM update_log_wos);

--drop table if exists temp_update_wosid_grants;
--create table temp_update_wosid_grants tablespace wos as
--select source_id from temp_update_wosid;

--drop table if exists temp_update_wosid_keywords;
--create table temp_update_wosid_keywords tablespace wos as
--select source_id from temp_update_wosid;

--drop table if exists temp_update_wosid_publications;
--create table temp_update_wosid_publications tablespace wos as
--select source_id from temp_update_wosid;

--drop table if exists temp_update_wosid_titles;
--create table temp_update_wosid_titles tablespace wos as
--select source_id from temp_update_wosid;

--drop table if exists temp_replace_wosid_1;
--  create table temp_replace_wosid_1 tablespace wos as
--  select source_id from temp_replace_wosid;

--  drop table if exists temp_replace_wosid_2;
--  create table temp_replace_wosid_2 tablespace wos as
--  select source_id from temp_replace_wosid;

--  drop table if exists temp_replace_wosid_3;
--  create table temp_replace_wosid_3 tablespace wos as
--  select source_id from temp_replace_wosid;

--  drop table if exists temp_replace_wosid_4;
--  create table temp_replace_wosid_4 tablespace wos as
--  select source_id from temp_replace_wosid;

--drop table if exists temp_replace_wosid_grants;
--create table temp_replace_wosid_grants tablespace wos as
--select source_id from temp_replace_wosid;

--drop table if exists temp_replace_wosid_keywords;
--create table temp_replace_wosid_keywords tablespace wos as
--select source_id from temp_replace_wosid;

--drop table if exists temp_replace_wosid_publications;
--create table temp_replace_wosid_publications tablespace wos as
--select source_id from temp_replace_wosid;

--drop table if exists temp_replace_wosid_titles;
--create table temp_replace_wosid_titles tablespace wos as
--select source_id from temp_replace_wosid;
