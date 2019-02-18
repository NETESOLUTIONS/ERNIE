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

\set dataset 'dataset':year
\set dataset_pk :dataset'_pk'
\set dataset_index 'd':year'_reference_year_i'
\set shuffled_view :dataset'_shuffled'

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

SET SEARCH_PATH = public;

SELECT NOW();

DROP TABLE IF EXISTS :dataset CASCADE;

CREATE TABLE :dataset TABLESPACE p2_studies AS
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
JOIN wos_publications ref_wp ON ref_wp.source_id = wr.cited_source_uid AND ref_wp.publication_year::INT <= :year
JOIN wos_publication_issns ref_wpi ON ref_wpi.source_id = ref_wp.source_id
WHERE source_wp.publication_year::INT = :year AND source_wp.document_type = 'Article';

ALTER TABLE :dataset ADD CONSTRAINT :dataset_pk PRIMARY KEY (source_id, cited_source_uid) --
  USING INDEX TABLESPACE index_tbs;

CREATE INDEX IF NOT EXISTS :dataset_index ON :dataset(reference_year) TABLESPACE index_tbs;

CREATE OR REPLACE VIEW :shuffled_view AS
SELECT DISTINCT
  source_id,
  source_year,
  source_document_id_type,
  source_issn,
  -- Can’t embed a window function as lead() default expressions
  coalesce(lead(cited_source_uid, 1) OVER (PARTITION BY reference_year ORDER BY random()), --
           first_value(cited_source_uid)
                       OVER (PARTITION BY reference_year ORDER BY random())) AS shuffled_cited_source_uid,
  coalesce(lead(reference_year, 1) OVER (PARTITION BY reference_year ORDER BY random()),
           first_value(reference_year) OVER (PARTITION BY reference_year ORDER BY random())) AS shuffled_reference_year,
  coalesce(lead(reference_document_id_type, 1) OVER (PARTITION BY reference_year ORDER BY random()),
           first_value(reference_document_id_type)
                       OVER (PARTITION BY reference_year ORDER BY random())) AS shuffled_reference_document_id_type,
  coalesce(lead(reference_issn, 1) OVER (PARTITION BY reference_year ORDER BY random()),
           first_value(reference_issn) OVER (PARTITION BY reference_year ORDER BY random())) AS shuffled_reference_issn
FROM : dataset;

INSERT INTO dataset_stats(year, unique_source_id_count, unique_cited_id_count, cited_id_count)
SELECT :year, COUNT(DISTINCT source_id), COUNT(DISTINCT cited_source_uid), COUNT(cited_source_uid)
FROM :dataset d
ON CONFLICT (year) DO UPDATE SET unique_source_id_count = excluded.unique_source_id_count, --
  unique_cited_id_count = excluded.unique_cited_id_count, cited_id_count = excluded.cited_id_count;

SELECT NOW();
