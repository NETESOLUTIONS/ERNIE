-- test script to test Monte-Carlo methods for networks
-- this script was specifically developed for the ERNIE project 
-- but can be used for benchmarking performance
-- George Chacko 12/8/2018
-- cleaned up bad git merge and replace 'gc_mc' with 'stg_uz_ds' (Uzzi-dataslice)
-- DK added expresions to select most frequently used issns where multiple values exist
-- can pass parametes now
-- e.g., nohup  psql -f /home/chackoge/ERNIE/P2_studies/Uzzi/stg_uz_ds.sql -v year=1980 &
-- George Chacko 12/20/2018

\set ON_ERROR_STOP on
\set ECHO all

\set output_table 'dataset':year
\set output_table_pk :output_table'_pk'

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

SET SEARCH_PATH = public;

SELECT NOW();

DROP TABLE IF EXISTS :output_table;

CREATE TABLE :output_table TABLESPACE p2_studies AS
SELECT
  source_wp.source_id,
  CAST(:year AS INT) AS source_year,
  source_wpi.issn_type AS source_document_id_type,
  source_wpi.issn AS source_issn,
  wr.cited_source_uid,
  ref_wp.publication_year AS reference_year,
  ref_wpi.issn_type AS reference_document_id_type,
  ref_wpi.issn AS reference_issn
FROM wos_publications source_wp
JOIN wos_publication_issns source_wpi ON source_wpi.source_id = source_wp.source_id
JOIN wos_references wr ON wr.source_id = source_wp.source_id
  -- Checks below are redundant since we're joining to wos_publications
  -- AND substring(wr.cited_source_uid, 1, 4) = 'WOS:'
  -- AND length(wr.cited_source_uid) = 19
  -- ensure that ref pubs year is not greater that source_id pub year
JOIN wos_publications ref_wp
     ON ref_wp.source_id = wr.cited_source_uid AND ref_wp.publication_year::INT <= :year
JOIN wos_publication_issns ref_wpi ON ref_wpi.source_id = ref_wp.source_id
WHERE source_wp.publication_year::INT = :year AND source_wp.document_type = 'Article';

ALTER TABLE :output_table ADD CONSTRAINT :output_table_pk PRIMARY KEY (source_id, cited_source_uid) --
  USING INDEX TABLESPACE index_tbs;


SELECT NOW();
