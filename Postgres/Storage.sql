-- All tablespaces
SELECT
  pt.spcname AS tablespace,
  pg_size_pretty(COALESCE(pg_tablespace_size(pt.spcname), 0)) AS used_space,
  CASE spcname
  WHEN 'pg_default'
    THEN ps.setting || '/base'
  WHEN 'pg_global'
    THEN ps.setting || '/global'
  ELSE pg_tablespace_location(pt.oid) END AS location,
  pt.oid AS tablespace_oid --, pd.datname AS using_db, ptd.oid AS using_db_oid
FROM pg_tablespace pt, pg_settings ps
WHERE ps.name = 'data_directory'
-- LEFT JOIN LATERAL pg_tablespace_databases(pt.oid) ptd ON TRUE -- table function (returns setof oid)
-- LEFT JOIN pg_database pd ON ptd.oid = pd.oid
ORDER BY pg_tablespace_size(pt.spcname) DESC/*, pd.datname*/;

-- Default tablespace parameter
SHOW default_tablespace;

-- Current DB's default tablespace
SELECT
  datname AS db,
  pt.spcname AS db_default_tablespace,
  --
  pg_size_pretty(pg_tablespace_size(pt.spcname)) AS used_space
FROM pg_database pd
JOIN pg_tablespace pt ON pt.oid = pd.dattablespace
WHERE datname = current_catalog;

SHOW temp_tablespaces;

-- Database cluster directory
SHOW data_directory;

-- Sizes and tablespaces of all relations (table-like objects)
SELECT
  pc.relname,
  pg_size_pretty(pg_total_relation_size(pc.oid)),
  CASE pc.relkind
  WHEN 'r' -- By default, CASE will cast results as char (pc.relkind)
    THEN CAST('table' AS TEXT)
  WHEN 'i'
    THEN 'index'
  WHEN 'S'
    THEN 'sequence'
  WHEN 'v'
    THEN 'view'
  WHEN 'm'
    THEN 'materialized view'
  WHEN 'c'
    THEN 'composite type'
  WHEN 't'
    THEN 'TOAST table'
  WHEN 'f'
    THEN 'foreign table'
  ELSE pc.relkind --
  END AS kind,
  coalesce(obj_pt.spcname, db_pt.spcname) AS tablespace
FROM pg_class pc --
LEFT JOIN pg_tablespace obj_pt ON obj_pt.oid = pc.reltablespace
JOIN pg_database pd ON pd.datname = current_catalog
JOIN pg_tablespace db_pt ON db_pt.oid = pd.dattablespace
ORDER BY pg_total_relation_size(pc.oid) DESC;

/*
Relations (data-containing objects) in a tablespace
Does not support default DB tablespace
*/
SELECT
  pc.relname,
  pg_size_pretty(pg_total_relation_size(pc.oid)),
  --
  CASE pc.relkind
  WHEN 'r' -- By default, CASE will cast results as char (pc.relkind)
    THEN CAST('table' AS TEXT)
  WHEN 'i'
    THEN 'index'
  WHEN 'S'
    THEN 'sequence'
  WHEN 'v'
    THEN 'view'
  WHEN 'm'
    THEN 'materialized view'
  WHEN 'c'
    THEN 'composite type'
  WHEN 't'
    THEN 'TOAST table'
  WHEN 'f'
    THEN 'foreign table'
  ELSE pc.relkind --
  END AS kind
FROM pg_class pc
JOIN pg_tablespace obj_pt ON obj_pt.oid = pc.reltablespace
WHERE obj_pt.spcname = :tablespace
ORDER BY pg_total_relation_size(pc.oid) DESC;

-- Relations (data-containing objects) by name pattern
SELECT
  pc.relname,
  pg_size_pretty(pg_total_relation_size(pc.oid)),
  CASE pc.relkind
  WHEN 'r' -- By default, CASE will cast results as char (pc.relkind)
    THEN CAST('table' AS TEXT)
  WHEN 'i'
    THEN 'index'
  WHEN 'S'
    THEN 'sequence'
  WHEN 'v'
    THEN 'view'
  WHEN 'm'
    THEN 'materialized view'
  WHEN 'c'
    THEN 'composite type'
  WHEN 't'
    THEN 'TOAST table'
  WHEN 'f'
    THEN 'foreign table'
  ELSE pc.relkind --
  END AS kind,
  coalesce(obj_pt.spcname, db_pt.spcname) AS tablespace
FROM pg_class pc --
LEFT JOIN pg_tablespace obj_pt ON obj_pt.oid = pc.reltablespace
JOIN pg_database pd ON pd.datname = current_catalog
JOIN pg_tablespace db_pt ON db_pt.oid = pd.dattablespace
WHERE pc.relname LIKE :name_pattern
ORDER BY pg_total_relation_size(pc.oid) DESC;

-- Relations (data-containing objects) by kind
SELECT
  pc.relname,
  pg_size_pretty(pg_total_relation_size(pc.oid)),
  CASE pc.relkind
  WHEN 'r' -- By default, CASE will cast results as char (pc.relkind)
    THEN CAST('table' AS TEXT)
  WHEN 'i'
    THEN 'index'
  WHEN 'S'
    THEN 'sequence'
  WHEN 'v'
    THEN 'view'
  WHEN 'm'
    THEN 'materialized view'
  WHEN 'c'
    THEN 'composite type'
  WHEN 't'
    THEN 'TOAST table'
  WHEN 'f'
    THEN 'foreign table'
  ELSE pc.relkind --
  END AS kind,
  coalesce(obj_pt.spcname, db_pt.spcname) AS tablespace
FROM pg_class pc --
LEFT JOIN pg_tablespace obj_pt ON obj_pt.oid = pc.reltablespace
JOIN pg_database pd ON pd.datname = current_catalog
JOIN pg_tablespace db_pt ON db_pt.oid = pd.dattablespace
WHERE pc.relkind = :relkind
ORDER BY pg_total_relation_size(pc.oid) DESC;

-- Total size for a table + indexes
SELECT pg_size_pretty(pg_total_relation_size('temp_wos_references'));

-- Table indexes with sizes
SELECT
  pc_index.relname AS index_name,
  pg_size_pretty(pg_total_relation_size(pc_index.oid))
FROM pg_class pc_table
JOIN pg_index pi ON pc_table.oid = pi.indrelid
JOIN pg_class pc_index ON pc_index.oid = pi.indexrelid
WHERE pc_table.relname = 'temp_wos_reference'
--'derwent_familyid'      
ORDER BY pc_index.relname;

-- Create a tablespace
CREATE TABLESPACE wos LOCATION '/pardidata8/pgsql/wos/data';

-- Rename a tablespace
-- ALTER TABLESPACE pardiindex_tbs RENAME to indexes;

ALTER TABLESPACE wosdata_ssd_tbs
RENAME TO wos;

ALTER TABLESPACE wosindex_ssd_tbs
RENAME TO indexes;

-- Drop a tablespace
DROP TABLESPACE wosdata_tbs;
DROP TABLESPACE wosindex_tbs;

-- Move to a tablespace
ALTER TABLE wos_abstracts
-- ALL IN TABLESPACE wosdata_ssd_tbs
SET TABLESPACE wos;

-- 1.7 GB
-- 17s for Premium to Premium storage move
ALTER TABLE wos_patent_mapping
SET TABLESPACE wos;

-- 2.6 GB
-- 23-42s for Premium to Premium storage move
ALTER INDEX wos_publications_pk
  SET TABLESPACE indexes;

-- 2.1 GB
-- 19-34s for Premium to Premium storage move
ALTER INDEX wos_addresses_country_idx
  SET TABLESPACE indexes;

-- 742 MB
-- 7s for Premium to Premium storage move
ALTER INDEX wos_pmid_mapping_pk
  SET TABLESPACE indexes;

ALTER SEQUENCE wos_pmid_mapping_wos_pmid_seq_seq
  SET TABLESPACE wos;