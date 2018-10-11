-- Table indexes
SELECT table_pc.relname AS table, index_pc.relname AS index, pi.indisunique, pg_get_indexdef(index_pc.oid)
FROM pg_class table_pc
JOIN pg_namespace pn ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public' --
  -- pi.indrelid: The OID of the pg_class entry for the table this index is for
JOIN pg_index pi ON pi.indrelid = table_pc.oid --
  -- pi.indexrelid: The OID of the pg_class entry for this index
JOIN pg_class index_pc ON index_pc.oid = pi.indexrelid
WHERE table_pc.relname = :tableName
ORDER BY table_pc.relname;

-- List of all indexes in the public schema
SELECT pi.tablename, pi.indexname, pi.tablespace --, pi.indexdef
FROM pg_indexes pi
WHERE pi.schemaname = 'public'
ORDER BY pi.tablename, pi.indexname;

-- List of all non-PK unique indexes in the public schema
SELECT table_pc.relname AS table, index_pc.relname AS index, pg_get_indexdef(index_pc.oid)
FROM pg_class table_pc
JOIN pg_namespace pn
       ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public' -- pi.indrelid: The OID of the pg_class entry for the table this index is for
JOIN pg_index pi ON pi.indrelid = table_pc.oid -- pi.indexrelid: The OID of the pg_class entry for this index
JOIN pg_class index_pc ON index_pc.oid = pi.indexrelid
WHERE pi.indisunique AND index_pc.relname NOT LIKE '%_pk%'
ORDER BY table_pc.relname;
