/* Existing tables: only those tables and views are shown that the current user has access to
(by way of being the owner or having some privilege). */
SELECT *
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name LIKE :tablePattern;

-- Table class data
SELECT pc.*
FROM pg_class pc
JOIN pg_namespace pn ON pn.oid = pc.relnamespace AND pn.nspname = 'public'
WHERE pc.relname = :tableName;

-- All tables by owner
SELECT table_pc.relname AS table_name, pa.rolname AS owner
FROM pg_class table_pc
JOIN pg_namespace pn ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public'
JOIN pg_authid pa ON pa.oid = table_pc.relowner
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

-- Table indexes
SELECT
  table_pc.relname AS table,
  index_pc.relname AS index,
  pi.indisunique
FROM pg_class table_pc
JOIN pg_namespace pn ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public'
-- pi.indrelid: The OID of the pg_class entry for the table this index is for
JOIN pg_index pi ON pi.indrelid = table_pc.oid
-- pi.indexrelid: The OID of the pg_class entry for this index
JOIN pg_class index_pc ON index_pc.oid = pi.indexrelid
WHERE table_pc.relname = :tableName
ORDER BY table_pc.relname;

-- PK or UK name
SELECT index_pc.relname AS pkorukname
FROM pg_class table_pc
JOIN pg_namespace pn ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public'
-- pi.indrelid: The OID of the pg_class entry for the table this index is for
JOIN pg_index pi ON pi.indrelid = table_pc.oid
-- pi.indexrelid: The OID of the pg_class entry for this index
JOIN pg_class index_pc ON index_pc.oid = pi.indexrelid
WHERE table_pc.relname = :tableName AND pi.indisunique;

-- Table columns
SELECT pa.attname
FROM pg_class pc
JOIN pg_namespace pn ON pn.oid = pc.relnamespace AND pn.nspname = 'public'
-- pa.attrelid: The table this column belongs to
-- Ordinary columns are numbered from 1 up. System columns, such as oid, have (arbitrary) negative numbers.
JOIN pg_attribute pa ON pc.oid = pa.attrelid AND pa.attnum > 0
WHERE pc.relname = :tableName
ORDER BY pa.attnum;

-- List of table columns
SELECT string_agg(pa.attname, ', '
ORDER BY pa.attnum)
FROM pg_class pc
JOIN pg_namespace pn ON pn.oid = pc.relnamespace AND pn.nspname = 'public'
-- pa.attrelid: The table this column belongs to
-- Ordinary columns are numbered from 1 up. System columns, such as oid, have (arbitrary) negative numbers.
JOIN pg_attribute pa ON pc.oid = pa.attrelid AND pa.attnum > 0
WHERE pc.relname = :tableName;

-- Key columns (simple only)
SELECT pa.attname
FROM pg_class table_pc
JOIN pg_namespace pn ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public'
-- pi.indrelid: The OID of the pg_class entry for the table this index is for
JOIN pg_index pi ON pi.indrelid = table_pc.oid
-- pi.indexrelid: The OID of the pg_class entry for this index
JOIN pg_class index_pc ON index_pc.oid = pi.indexrelid
-- pa.attrelid: The table this column belongs to
JOIN pg_attribute pa ON pa.attrelid = table_pc.oid AND pa.attnum = ANY (pi.indkey)
WHERE table_pc.relname = :tableName AND pi.indisunique
ORDER BY pa.attnum;

-- List of key columns (simple only)
SELECT string_agg(pa.attname, ', '
ORDER BY pa.attnum)
FROM pg_class table_pc
JOIN pg_namespace pn ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public'
-- pi.indrelid: The OID of the pg_class entry for the table this index is for
JOIN pg_index pi ON pi.indrelid = table_pc.oid AND pi.indisunique
-- pa.attrelid: The table this column belongs to
JOIN pg_attribute pa ON pa.attrelid = table_pc.oid AND pa.attnum = ANY (pi.indkey)
WHERE table_pc.relname = :tableName;

-- Key, index DDL and functional expressions
SELECT
  substring(pg_get_indexdef(index_pc.relname :: REGCLASS) FROM '\(.*\)') AS key,
  pg_get_indexdef(index_pc.relname :: REGCLASS) AS ddl,
  pg_get_expr(pi.indexprs, pi.indrelid) AS functional_expr
FROM pg_class table_pc
JOIN pg_namespace pn ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public'
-- pi.indrelid: The OID of the pg_class entry for the table this index is for
JOIN pg_index pi ON pi.indrelid = table_pc.oid AND pi.indisunique
-- pi.indexrelid: The OID of the pg_class entry for this index
JOIN pg_class index_pc ON index_pc.oid = pi.indexrelid
WHERE table_pc.relname = :tableName;