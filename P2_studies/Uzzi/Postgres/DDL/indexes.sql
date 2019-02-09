\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

DO $block$
  DECLARE
    dataset TEXT;
    sql TEXT;
  BEGIN
    FOR year IN 1980..2015 LOOP
      dataset := 'dataset' || year;
      -- Is dataset table visible on the search path?
      IF EXISTS(SELECT 1
                FROM pg_catalog.pg_class c
                LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
                WHERE c.relname = dataset AND pg_catalog.pg_table_is_visible(c.oid)) THEN
        sql :=
          format('CREATE INDEX IF NOT EXISTS d%s_reference_year_i ON %s(reference_year) TABLESPACE index_tbs', year,
                 dataset);
        RAISE NOTICE USING MESSAGE = sql;
        EXECUTE sql;
      END IF;
    END LOOP;
  END $block$;
