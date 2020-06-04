-- Table constraints
SELECT table_pc.relname AS table, pg_get_constraintdef(pc.oid)
FROM pg_class table_pc
JOIN pg_namespace pn ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public'
JOIN pg_constraint pc ON pc.conrelid = table_pc.oid
WHERE table_pc.relname = :tableName
ORDER BY table_pc.relname;

SELECT pi.indexname, pi.indexdef
FROM pg_indexes pi
WHERE pi.tablename = :table_name;

-- This works on PKs and FKs
ALTER TABLE :table
    RENAME CONSTRAINT :old_constraint_name TO :new_constraint_name;