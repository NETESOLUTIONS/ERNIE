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
        RAISE NOTICE 'Creating %_shuffled ...', dataset;
        sql := format($$
CREATE MATERIALIZED VIEW %s_shuffled AS
SELECT
  source_id,
  source_year,
  source_document_id_type,
  source_issn,
  shuffled_cited_source_uid,
  shuffled_reference_year,
  shuffled_reference_document_id_type,
  shuffled_reference_issn
FROM (
  SELECT
    source_id,
    source_year,
    source_document_id_type,
    source_issn,
    -- Can’t embed a window function as lead() default expressions
    coalesce(lead(cited_source_uid, 1) OVER (PARTITION BY reference_year ORDER BY random()),
             first_value(cited_source_uid) OVER (PARTITION BY reference_year ORDER BY random())) --*
      AS shuffled_cited_source_uid,
    coalesce(lead(reference_year, 1) OVER (PARTITION BY reference_year ORDER BY random()),
             first_value(reference_year) OVER (PARTITION BY reference_year ORDER BY random())) --*
      AS shuffled_reference_year,
    coalesce(lead(reference_document_id_type, 1) OVER (PARTITION BY reference_year ORDER BY random()),
             first_value(reference_document_id_type) OVER (PARTITION BY reference_year ORDER BY random())) --*
      AS shuffled_reference_document_id_type,
    coalesce(lead(reference_issn, 1) OVER (PARTITION BY reference_year ORDER BY random()),
             first_value(reference_issn) OVER (PARTITION BY reference_year ORDER BY random())) --*
      AS shuffled_reference_issn
  FROM %1$s
) sq
GROUP BY source_id,
         source_year,
         source_document_id_type,
         source_issn,
         shuffled_cited_source_uid,
         shuffled_reference_year,
         shuffled_reference_document_id_type,
         shuffled_reference_issn
HAVING COUNT(1) = 1
            $$, dataset);
        EXECUTE sql;
        EXECUTE format($$
COMMENT ON MATERIALIZED VIEW %s_shuffled IS
'References randomly shuffled within the same reference year.'
'Sources with any randomly generated duplicates are discarded (in order to preserve the number of references).'
          $$, dataset);
      END IF;
    END LOOP;
  END $block$;
