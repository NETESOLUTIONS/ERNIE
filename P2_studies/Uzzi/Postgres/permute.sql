CREATE INDEX d1980_reference_year_i ON dataset1980(reference_year) TABLESPACE index_tbs;
-- 4.0s

SELECT first_value(cited_source_uid) OVER (ORDER BY random()) AS shuffled_cited_source_uid_1
FROM dataset1980
GROUP BY reference_year;

SELECT
  source_id,
  source_year,
  source_document_id_type,
  source_issn,
  cited_source_uid,
  reference_year,
  reference_document_id_type,
  reference_issn,
  row_number() OVER (PARTITION BY reference_year ORDER BY random()) AS random_index,
  coalesce(lead(cited_source_uid, 1) OVER (PARTITION BY reference_year ORDER BY random()),
    first_value(cited_source_uid) OVER (PARTITION BY reference_year ORDER BY random())) AS shuffle_cited_source_uid
FROM dataset1980;
-- 7.9s