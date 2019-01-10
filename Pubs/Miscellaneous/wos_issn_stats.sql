\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

INSERT INTO wos_issn_stats
SELECT DISTINCT document_id
FROM wos_document_identifiers wdi
WHERE document_id_type = 'issn';

UPDATE wos_issn_stats wis
SET publication_count = (
  SELECT count(1)
  FROM wos_document_identifiers wdi
  WHERE document_id_type = 'issn' AND document_id = wis.issn
);