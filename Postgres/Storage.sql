-- All tablespaces
SELECT spcname AS "tablespace", pg_size_pretty(COALESCE(pg_tablespace_size(spcname), 0)) AS used_space,
       pg_tablespace_location(pt.oid), pt.oid AS tablespace_oid, pd.datname AS using_db, ptd.oid AS using_db_oid
FROM pg_tablespace pt
LEFT JOIN LATERAL pg_tablespace_databases(pt.oid) ptd ON TRUE -- table function (returns setof oid)
LEFT JOIN pg_database pd ON ptd.oid = pd.oid
ORDER BY pg_tablespace_size(spcname) DESC, pd.datname;

-- Default tablespace parameter
show default_tablespace;

-- Current DB's default tablespace size
SELECT datname AS d, dattablespace, pt.spcname AS db_default_tablespace, --
       pg_size_pretty(pg_tablespace_size (pt.spcname)) AS used
FROM pg_database pd
  JOIN pg_tablespace pt ON pd.dattablespace = pt.oid
WHERE datname = current_catalog;

show temp_tablespaces;

-- Database cluster directory
show data_directory;

-- Sizes for all objects
SELECT relname, pg_size_pretty(pg_total_relation_size (OID))
FROM pg_class
ORDER BY pg_total_relation_size(OID) DESC;

-- Total size for a table + indexes
SELECT pg_size_pretty(pg_total_relation_size ('temp_wos_references'));

-- Table indexes with sizes
SELECT pc_index.relname AS index_name, pg_size_pretty(pg_total_relation_size (pc_index.oid))
FROM pg_class pc_table
  JOIN pg_index PI ON pc_table.oid = pi.indrelid
  JOIN pg_class pc_index ON pc_index.oid = pi.indexrelid
WHERE pc_table.relname = 'temp_wos_reference'
--'derwent_familyid'      
ORDER BY pc_index.relname;

-- Tablespace rename
-- ALTER TABLESPACE pardiindex_tbs RENAME to indexes;

CREATE TABLESPACE wos LOCATION '/pardidata8/pgsql/wos/data';