\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

DO $block$
  DECLARE
    entity TEXT;
    sql TEXT;
  BEGIN
    FOR year IN 1980..2015 LOOP
      entity := 'dataset' || year;
      -- Is table visible on the search path?
      IF EXISTS(SELECT 1
                FROM pg_catalog.pg_class c
                LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
                WHERE c.relname = entity AND pg_catalog.pg_table_is_visible(c.oid)) THEN
        sql := format($$
            INSERT INTO dataset_stats(year, unique_source_id_count, unique_cited_id_count, cited_id_count)
            SELECT %s, COUNT(DISTINCT source_id), COUNT(DISTINCT cited_source_uid), COUNT(cited_source_uid)
            FROM %s d
            ON CONFLICT (year) DO UPDATE SET unique_source_id_count = excluded.unique_source_id_count, --
              unique_cited_id_count = excluded.unique_cited_id_count, cited_id_count = excluded.cited_id_count
            $$, year, entity);
        RAISE NOTICE USING MESSAGE = sql;
        EXECUTE sql;
      END IF;
    END LOOP;
  END $block$;
-- 45.3s