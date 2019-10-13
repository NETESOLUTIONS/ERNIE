\set ON_ERROR_STOP on
-- Reduce verbosity
-- \set ECHO all

\if :{?schema}
  SET search_path = :schema;
\endif

-- JetBrains IDEs: start execution from here
SET TIMEZONE = 'US/Eastern';

DO $$
  DECLARE staging_table_record RECORD;
  BEGIN
    -- Truncate all default Scopus staging tables: the first on the current search path
    FOR staging_table_record IN (
      SELECT pn.nspname, pc.relname
        FROM
          pg_catalog.pg_class pc
            LEFT JOIN pg_catalog.pg_namespace pn ON pn.oid = pc.relnamespace
       WHERE pc.relkind IN ('r', 'p') AND pc.relname LIKE 'stg_scopus%' AND pg_catalog.pg_table_is_visible(pc.oid)
    ) LOOP
      EXECUTE format('TRUNCATE TABLE %I.%I CASCADE', staging_table_record.nspname, staging_table_record.relname);
    END LOOP;
  END ; $$;
