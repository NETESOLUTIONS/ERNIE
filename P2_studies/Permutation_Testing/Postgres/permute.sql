CREATE INDEX d1980_reference_year_i ON dataset1980(reference_year) TABLESPACE index_tbs;
-- 4.0s

CREATE INDEX d2005_reference_year_i ON dataset2005(reference_year) TABLESPACE index_tbs;
-- 37s

SELECT first_value(cited_source_uid) OVER (ORDER BY random()) AS shuffled_cited_source_uid_1
FROM dataset1980
GROUP BY reference_year;

DROP MATERIALIZED VIEW dataset1980_shuffled;

CREATE MATERIALIZED VIEW dataset1980_shuffled AS
WITH cte AS (
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
  FROM dataset1980
)
SELECT
  source_id,
  source_year,
  source_document_id_type,
  source_issn,
  shuffled_cited_source_uid,
  shuffled_reference_year,
  shuffled_reference_document_id_type,
  shuffled_reference_issn
FROM cte
WHERE source_id NOT IN (
  SELECT source_id
  FROM cte
  GROUP BY source_id, shuffled_cited_source_uid
  HAVING COUNT(1) > 1
);
-- 26.9s (cold)

--@formatter:off
COMMENT ON MATERIALIZED VIEW dataset1980_shuffled IS 'References randomly shuffled within the same reference year.'
'Sources with any randomly generated duplicates are discarded (in order to preserve the number of references).';
--@formatter:on