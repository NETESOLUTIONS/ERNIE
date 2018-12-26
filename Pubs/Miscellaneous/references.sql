\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- Limited deterministic sample of publication references
SELECT
  wr.source_id,
  source_wp.document_title,
  source_wp.document_type,
  source_wp.publication_year,
  wr.cited_source_uid,
  reference_wp.document_title,
  reference_wp.document_type,
  reference_wp.publication_year
FROM wos_references wr
JOIN wos_publications source_wp ON source_wp.source_id = wr.source_id
JOIN wos_publications reference_wp ON reference_wp.source_id = wr.cited_source_uid
ORDER BY wr.source_id DESC
LIMIT 5;
--

-- Limited deterministic sample of publication references
SELECT wr.*
FROM wos_references wr
JOIN wos_publications source_wp ON source_wp.source_id = wr.source_id
JOIN wos_publications reference_wp ON reference_wp.source_id = wr.cited_source_uid
WHERE source_wp.publication_year = '1980'
ORDER BY wr.source_id DESC
LIMIT 5;
-- Long-running

-- Limited deterministic sample of publication references
SELECT wr.*
FROM wos_publications wp
JOIN wos_references wr ON wr.source_id = wp.source_id
WHERE wp.publication_year = '1980'
ORDER BY wp.ctid
LIMIT 5;
-- Long-running