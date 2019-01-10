\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- region wos_doc_id_stats
DROP MATERIALIZED VIEW IF EXISTS wos_doc_id_stats CASCADE;

CREATE MATERIALIZED VIEW wos_doc_id_stats TABLESPACE wos_tbs AS
SELECT document_id_type, document_id, count(1) AS publication_count
FROM wos_document_identifiers wdi
WHERE document_id_type IN ('issn', 'eissn')
GROUP BY document_id_type, document_id;
-- 6m:48s

CREATE UNIQUE INDEX wdis_document_id_uk ON wos_doc_id_stats(document_id_type, document_id) TABLESPACE index_tbs;

COMMENT ON MATERIALIZED VIEW wos_doc_id_stats IS 'Total publication counts per ISSN (issn, eissn document identifiers)';
-- endregion

-- region wos_publication_issns
DROP MATERIALIZED VIEW IF EXISTS wos_publication_issns;

CREATE MATERIALIZED VIEW wos_publication_issns TABLESPACE wos_tbs AS
SELECT source_id, document_id_type AS issn_type, document_id AS issn
FROM (
  SELECT
    wp.source_id,
    wdi.document_id_type,
    wdi.document_id,
    row_number()
      OVER (PARTITION BY wp.source_id ORDER BY wdi.document_id_type DESC, wis.publication_count DESC, wdi.document_id)--
      AS rank
  FROM wos_publications wp
  JOIN wos_document_identifiers wdi ON wdi.source_id = wp.source_id AND wdi.document_id_type IN ('issn', 'eissn')
  JOIN wos_doc_id_stats wis ON wis.document_id_type = wdi.document_id_type AND wis.document_id = wdi.document_id
) sq
WHERE rank = 1;

CREATE UNIQUE INDEX IF NOT EXISTS wos_publication_issns_uk ON wos_publication_issns(source_id) TABLESPACE index_tbs;

--@formatter:off
COMMENT ON MATERIALIZED VIEW wos_publication_issns IS
  'Publications with a single ISSN selected per a publication. The order of selection preferences is 1) ISSN over EISSN'
  ' type, 2) most frequently used, 3) natural order';
--@formatter:on
-- endregion