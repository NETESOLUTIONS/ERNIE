\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE MATERIALIZED VIEW wos_issn_stats TABLESPACE wos_tbs AS
SELECT CAST(document_id AS CHAR(9)) AS issn, count(1) AS publication_count
FROM wos_document_identifiers wdi
WHERE document_id_type = 'issn'
GROUP BY document_id;

CREATE UNIQUE INDEX wis_issn_uk ON wos_issn_stats(issn) TABLESPACE index_tbs;
