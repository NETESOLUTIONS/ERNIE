-- Default Scopus staging tables: the first on the current search path
SELECT pn.nspname, pc.relname, pc.relkind
FROM
    pg_catalog.pg_class pc
      LEFT JOIN pg_catalog.pg_namespace pn ON pn.oid = pc.relnamespace
 WHERE pc.relkind IN ('r', 'p') AND pc.relname LIKE 'stg_scopus%' AND pg_catalog.pg_table_is_visible(pc.oid);