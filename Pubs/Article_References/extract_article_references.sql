\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

TRUNCATE TABLE wos_article_references_1985;

-- Step 1
INSERT INTO wos_article_references_1985(reference_id)
SELECT DISTINCT reference_wp.source_id
FROM wos_publications article_wp
JOIN wos_references wr ON wr.source_id = article_wp.source_id
  -- only valid WoS references
JOIN wos_publications reference_wp ON reference_wp.source_id = wr.cited_source_uid
WHERE article_wp.publication_year = '1985' AND article_wp.document_type = 'Article';

-- Step 2
-- noinspection SqlWithoutWhere
UPDATE wos_article_references_1985 war
SET cit_count = (
  SELECT count(1)
  FROM wos_references wr
  JOIN wos_publications wp ON wp.source_id = wr.source_id AND wp.publication_year <= '1985'
  WHERE wr.cited_source_uid = war.reference_id
);

-- Step 3
-- noinspection SqlWithoutWhere
UPDATE wos_article_references_1985
SET ratio = cit_count / (
  SELECT SUM(cit_count)
  FROM wos_article_references_1985
);