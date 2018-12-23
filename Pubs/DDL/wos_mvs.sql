\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

DROP MATERIALIZED VIEW IF EXISTS wos_doc_id_stats;

CREATE MATERIALIZED VIEW wos_doc_id_stats TABLESPACE wos_tbs AS
SELECT document_id_type, document_id, count(1) AS publication_count
FROM wos_document_identifiers wdi
WHERE document_id_type IN ('issn', 'eissn')
GROUP BY document_id_type, document_id;
-- 6m:48s

CREATE UNIQUE INDEX wdis_document_id_uk ON wos_doc_id_stats(document_id_type, document_id) TABLESPACE index_tbs;