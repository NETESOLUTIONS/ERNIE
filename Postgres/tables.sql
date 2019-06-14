/* Existing tables: only those tables and views are shown that the current user has access to
(by way of being the owner or having some privilege). */
SELECT *
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name LIKE :tablePattern;

-- Table class data
SELECT pc.*
FROM pg_class pc
JOIN pg_namespace pn
  ON pn.oid = pc.relnamespace AND pn.nspname = 'public'
WHERE pc.relname = :tableName;

-- All tables with owners
SELECT
  table_pc.relname AS table_name,
  pa.rolname AS owner
FROM pg_class table_pc
JOIN pg_namespace pn
  ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public'
JOIN pg_authid pa
  ON pa.oid = table_pc.relowner
WHERE table_pc.relkind = 'r'
ORDER BY 2, 1;

-- Foreign tables
SELECT *
FROM information_schema.foreign_tables;

-- Existing table constraints by table
SELECT *
FROM information_schema.constraint_table_usage
WHERE constraint_schema = 'public' AND table_name = :tableName;

-- Existing table constraints by constraint name
SELECT *
FROM information_schema.constraint_table_usage
WHERE constraint_schema = 'public' AND constraint_name = :constraintName;

-- PK or UK name
SELECT index_pc.relname AS pkorukname
FROM pg_class table_pc
JOIN pg_namespace pn
  ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public'
-- pi.indrelid: The OID of the pg_class entry for the table this index is for
JOIN pg_index pi
  ON pi.indrelid = table_pc.oid
-- pi.indexrelid: The OID of the pg_class entry for this index
JOIN pg_class index_pc
  ON index_pc.oid = pi.indexrelid
WHERE table_pc.relname = :tableName AND pi.indisunique;

-- Table columns
SELECT pa.attname
FROM pg_class pc
JOIN pg_namespace pn
  ON pn.oid = pc.relnamespace AND pn.nspname = 'public'
-- pa.attrelid: The table this column belongs to
-- Ordinary columns are numbered from 1 up. System columns, such as oid, have (arbitrary) negative numbers.
JOIN pg_attribute pa
  ON pc.oid = pa.attrelid AND pa.attnum > 0
WHERE pc.relname = :tableName
ORDER BY pa.attnum;

-- List of table columns
SELECT string_agg(pa.attname, ', '
ORDER BY pa.attnum)
FROM pg_class pc
JOIN pg_namespace pn
  ON pn.oid = pc.relnamespace AND pn.nspname = 'public'
-- pa.attrelid: The table this column belongs to
-- Ordinary columns are numbered from 1 up. System columns, such as oid, have (arbitrary) negative numbers.
JOIN pg_attribute pa
  ON pc.oid = pa.attrelid AND pa.attnum > 0
WHERE pc.relname = :tableName;

-- Key columns (simple only)
SELECT pa.attname
FROM pg_class table_pc
JOIN pg_namespace pn
  ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public'
-- pi.indrelid: The OID of the pg_class entry for the table this index is for
JOIN pg_index pi
  ON pi.indrelid = table_pc.oid
-- pi.indexrelid: The OID of the pg_class entry for this index
JOIN pg_class index_pc
  ON index_pc.oid = pi.indexrelid
-- pa.attrelid: The table this column belongs to
JOIN pg_attribute pa
  ON pa.attrelid = table_pc.oid AND pa.attnum = ANY (pi.indkey)
WHERE table_pc.relname = :tableName AND pi.indisunique
ORDER BY pa.attnum;

-- List of key columns (simple only)
SELECT string_agg(pa.attname, ', '
ORDER BY pa.attnum)
FROM pg_class table_pc
JOIN pg_namespace pn
  ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public'
-- pi.indrelid: The OID of the pg_class entry for the table this index is for
JOIN pg_index pi
  ON pi.indrelid = table_pc.oid AND pi.indisunique
-- pa.attrelid: The table this column belongs to
JOIN pg_attribute pa
  ON pa.attrelid = table_pc.oid AND pa.attnum = ANY (pi.indkey)
WHERE table_pc.relname = :tableName;

-- Key, index DDL and functional expressions
SELECT
  substring(pg_get_indexdef(index_pc.relname :: REGCLASS) FROM '\(.*\)') AS key,
  pg_get_indexdef(index_pc.relname :: REGCLASS) AS ddl,
  pg_get_expr(pi.indexprs, pi.indrelid) AS functional_expr
FROM pg_class table_pc
JOIN pg_namespace pn
  ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public'
-- pi.indrelid: The OID of the pg_class entry for the table this index is for
JOIN pg_index pi
  ON pi.indrelid = table_pc.oid AND pi.indisunique
-- pi.indexrelid: The OID of the pg_class entry for this index
JOIN pg_class index_pc
  ON index_pc.oid = pi.indexrelid
WHERE table_pc.relname = :tableName;

-- Is it visible on the search path?
SELECT
  c.oid,
  n.nspname,
  c.relname
FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n
  ON n.oid = c.relnamespace
WHERE c.relname = :table_name AND pg_catalog.pg_table_is_visible(c.oid)
ORDER BY 2, 3;

-- Is it visible on the search path (by a regex pattern)?
SELECT
  c.oid,
  n.nspname,
  c.relname
FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n
  ON n.oid = c.relnamespace
WHERE c.relname ~ ('^(' || :table_pattern || ')$') AND pg_catalog.pg_table_is_visible(c.oid)
ORDER BY 2, 3;

-- DDL
SELECT create_table_ddl(:tablename);

-- CREATE TABLE DDL for a table in a public schema with PKs, but no DEFAULTs
-- Based on https://stackoverflow.com/a/42742509/534217
WITH cte AS (
  SELECT
    cc.conrelid,
    format(E',
    CONSTRAINT %I PRIMARY KEY(%s)', cc.conname, string_agg(a.attname, ', '
    ORDER BY array_position(cc.conkey, a.attnum))) pkey
  FROM pg_catalog.pg_constraint cc
  JOIN pg_catalog.pg_class c
    ON c.oid = cc.conrelid
  JOIN pg_catalog.pg_attribute a
    ON a.attrelid = cc.conrelid AND a.attnum = ANY (cc.conkey)
  WHERE cc.contype = 'p'
  GROUP BY cc.conrelid, cc.conname
) --
SELECT
  pn.nspname AS schema,
  pc.relname AS table,
  format(E'CREATE %sTABLE %s%I (\n%s%s\n);\n', --
              CASE pc.relpersistence
              WHEN 't'
                THEN 'TEMPORARY '
              ELSE '' END, --
              CASE pc.relpersistence
              WHEN 't'
                THEN ''
              ELSE pn.nspname || '.' END, --
              pc.relname, --
              string_agg(format(E'\t%I %s%s', pa.attname, pg_catalog.format_type(pa.atttypid, pa.atttypmod),
                                CASE WHEN pa.attnotnull
                                  THEN ' NOT NULL'
                                ELSE '' END), E',\n'
              ORDER BY pa.attnum), (
                SELECT pkey
                FROM cte
                WHERE cte.conrelid = pc.oid)) AS DDL
FROM pg_catalog.pg_class pc
JOIN pg_catalog.pg_namespace pn
  ON pn.oid = pc.relnamespace
JOIN pg_catalog.pg_attribute pa
  ON pa.attrelid = pc.oid AND pa.attnum > 0
JOIN pg_catalog.pg_type pt
  ON pa.atttypid = pt.oid
WHERE pc.relname = :table_name
  AND (pn.nspname = 'public' OR pc.relpersistence = 't')
GROUP BY pc.oid, pc.relname, pc.relpersistence, pn.nspname;