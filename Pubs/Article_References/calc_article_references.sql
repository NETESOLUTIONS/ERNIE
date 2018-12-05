\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE TABLE IF NOT EXISTS wos_article_references_1985 (
  reference_id VARCHAR(30) CONSTRAINT wos_article_references_1985_pk PRIMARY KEY USING INDEX TABLESPACE index_tbs,
  cit_count INTEGER,
  ratio DOUBLE PRECISION
) TABLESPACE wos_tbs;

TRUNCATE TABLE wos_article_references_1985;

INSERT INTO wos_article_references_1985(reference_id)
SELECT DISTINCT cited_source_uid
FROM wos_publications wp
JOIN wos_references wr ON wr.source_id = wp.source_id
WHERE publication_year = '1985' AND document_type = 'Article';