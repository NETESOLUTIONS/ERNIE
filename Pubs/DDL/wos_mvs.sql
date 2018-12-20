\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE MATERIALIZED VIEW IF NOT EXISTS wos_issn_stats AS
SELECT CAST(document_id AS CHAR(9)) AS ssn, count(1) AS publication_count
FROM wos_document_identifiers wdi
WHERE document_id_type = 'issn'
GROUP BY document_id;

CREATE UNIQUE INDEX IF NOT EXISTS wis_ssn_uk ON wos_issn_stats(ssn) TABLESPACE index_tbs;
