-- Tables with no PKs in the current schema
SELECT table_schema, table_name
  FROM information_schema.tables t
 WHERE table_schema = current_schema AND NOT EXISTS(SELECT 1
                                                      FROM information_schema.table_constraints tc
                                                     WHERE tc.table_schema = current_schema
                                                       AND tc.table_name = t.table_name
                                                       AND tc.constraint_type = 'PRIMARY KEY');

-- All PKs in the current schema
SELECT tc.table_name, tc.constraint_name
  FROM information_schema.table_constraints tc
 WHERE tc.table_schema = current_schema AND tc.constraint_type = 'PRIMARY KEY'
 ORDER BY tc.table_name;

-- Table constraints
SELECT table_pc.relname AS table, pg_get_constraintdef(pc.oid)
  FROM
    pg_class table_pc
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