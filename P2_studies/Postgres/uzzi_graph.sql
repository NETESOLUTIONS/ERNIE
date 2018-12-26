-- Limited deterministic sample of publication references
SELECT
  d.source_id,
  source_wp.document_title,
  d.source_year,
  d.source_document_id_type,
  d.source_issn,
  d.cited_source_uid,
  reference_wp.document_title,
  d.reference_year,
  d.reference_document_id_type,
  d.reference_issn
FROM dataset1980 d
JOIN wos_publications source_wp ON source_wp.source_id = d.source_id
JOIN wos_publications reference_wp ON reference_wp.source_id = d.cited_source_uid
ORDER BY d.source_id DESC
LIMIT 20;