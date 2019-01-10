-- Limited non-deterministic sample of 1980 publication references
SELECT
  wp.source_id,
  wp.document_title,
  wp.publication_year AS source_year,
  wr.cited_source_uid,
  ref_wp.document_title AS reference_title,
  ref_wp.publication_year AS reference_year
FROM wos_publications wp
JOIN wos_references wr ON wr.source_id = wp.source_id
JOIN wos_publications ref_wp ON ref_wp.source_id = wr.cited_source_uid
WHERE wp.publication_year = '1980'
LIMIT 100;
-- 5m:15s

-- Limited deterministic sample of 1980 publication references
SELECT
  wp.source_id,
  wp.document_title,
  wp.publication_year AS source_year,
  wr.cited_source_uid,
  ref_wp.document_title AS reference_title,
  ref_wp.publication_year AS reference_year
FROM wos_publications wp
JOIN wos_references wr ON wr.source_id = wp.source_id
JOIN wos_publications ref_wp ON ref_wp.source_id = wr.cited_source_uid
WHERE wp.publication_year = '1980'
ORDER BY wp.source_id
LIMIT 100;

-- Limited deterministic sample of publication references from the Uzzi 1980 dataset
SELECT
  d.source_id,
  source_wp.document_title,
  d.source_year,
  d.source_document_id_type,
  d.source_issn,
  d.cited_source_uid,
  reference_wp.document_title AS reference_title,
  d.reference_year,
  d.reference_document_id_type,
  d.reference_issn
FROM dataset1980 d
JOIN wos_publications source_wp ON source_wp.source_id = d.source_id
JOIN wos_publications reference_wp ON reference_wp.source_id = d.cited_source_uid
ORDER BY d.source_id
LIMIT 100;