\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE TABLE stg_uz_ds3 AS
SELECT
  article_wp.source_id,
  article_wp.publication_year AS source_year,
  wr.cited_source_uid,
  reference_wp.publication_year AS reference_year
FROM wos_publications article_wp
JOIN wos_references wr ON article_wp.source_id = wr.source_id AND substring(wr.cited_source_uid, 1, 4) = 'WOS:'
  AND length(wr.cited_source_uid) = 19
  -- cleans out references published after pub_year (this is by convention)
JOIN wos_publications reference_wp ON wr.cited_source_uid = reference_wp.source_id AND reference_wp.publication_year::INT
  <= article_wp.publication_year::INT
WHERE article_wp.publication_year::INT = :year AND article_wp.document_type = 'Article';
-- 1985: ?

CREATE INDEX stg_uz_ds3_idx ON stg_uz_ds3(source_id, cited_source_uid, reference_year);

-- ISSNs per a pub
SELECT *
FROM wos_document_identifiers wdi
WHERE wdi.document_id_type = 'issn' AND wdi.source_id = :source_uid;

SELECT source_id, publication_year, source_document_id_type, source_issn
FROM (
  SELECT
    wp.source_id,
    wp.publication_year,
    wdi.document_id_type AS source_document_id_type,
    wdi.document_id AS source_issn,
    wis.publication_count,
    row_number()
      OVER (PARTITION BY wp.source_id ORDER BY wdi.document_id_type DESC, wis.publication_count, wdi.document_id) r
  FROM wos_publications wp
  JOIN wos_document_identifiers wdi ON wdi.source_id = wp.source_id AND wdi.document_id_type IN ('issn', 'eissn')
  JOIN wos_doc_id_stats wis ON wis.document_id_type = wdi.document_id_type AND wis.document_id = wdi.document_id
  WHERE wp.source_id = :source_uid
) sq
WHERE r = 1;

-- All ids
SELECT *
FROM wos_document_identifiers wdi
WHERE wdi.source_id = :source_uid;

-- Pubs with eissn and no issn
SELECT *
FROM wos_document_identifiers wdi
WHERE document_id_type = 'eissn'
  AND NOT EXISTS(SELECT 1
                 FROM wos_document_identifiers issn_wdi
                 WHERE issn_wdi.document_id_type = 'issn' AND issn_wdi.source_id = wdi.source_id);
-- Long-running
-- WOS:000219380000003