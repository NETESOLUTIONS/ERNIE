-- test script to test Monte-Carlo methods for networks
-- this script was specifically developed for the ERNIE project 
-- but can be used for benchmarking performance
-- George Chacko 12/8/2018
-- cleaned up bad git merge and replace 'gc_mc' with 'stg_uz_ds' (Uzzi-dataslice)
-- DK added expresions to select most frequently used issns where multiple values exist
-- can pass parametes now
-- e.g., nohup  psql -d ernie -f /home/chackoge/ERNIE/P2_studies/Uzzi/stg_uz_ds.sql 
-- -v year=1980 -v dataset_name=dataset1980 &
-- George Chacko 12/20/2018

\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

SELECT NOW();

DROP TABLE IF EXISTS stg_uz_sources;

CREATE TABLE stg_uz_sources TABLESPACE temp_tbs AS
SELECT
  source_id,
  publication_year::INT AS source_year,
  document_id_type AS source_document_id_type,
  document_id AS source_issn
FROM (
  SELECT
    wp.source_id,
    wp.publication_year,
    wdi.document_id_type,
    wdi.document_id,
    row_number()
      OVER (PARTITION BY wp.source_id ORDER BY wdi.document_id_type DESC, wis.publication_count DESC, wdi.document_id)--
      AS rank
  FROM wos_publications wp
  JOIN wos_document_identifiers wdi ON wdi.source_id = wp.source_id AND wdi.document_id_type IN ('issn', 'eissn')
  JOIN wos_doc_id_stats wis ON wis.document_id_type = wdi.document_id_type AND wis.document_id = wdi.document_id
  WHERE wp.publication_year::INT = :year AND wp.document_type = 'Article'
) sq
WHERE rank = 1;

ALTER TABLE stg_uz_sources ADD CONSTRAINT stg_uz_sources_pk PRIMARY KEY (source_id) USING INDEX TABLESPACE index_tbs;

DROP TABLE IF EXISTS :dataset_name;

CREATE TABLE :dataset_name TABLESPACE p2_studies AS
  -- The records should be DISTINCT on source_id + cited_source_uid
SELECT
  source_id,
  source_year,
  source_document_id_type,
  source_issn,
  cited_source_uid,
  reference_year,
  document_id_type AS reference_document_id_type,
  document_id AS reference_issn
FROM (
  SELECT
    sus.*,
    wr.cited_source_uid,
    wp.publication_year AS reference_year,
    wdi.document_id_type,
    wdi.document_id,
    row_number() OVER (PARTITION BY sus.source_id, wr.cited_source_uid --
      ORDER BY wdi.document_id_type DESC, wis.publication_count DESC, wdi.document_id) AS rank
    -- reference_issn
  FROM stg_uz_sources sus
  JOIN wos_references wr ON wr.source_id = sus.source_id
    -- Checks below are redundant since we're joining to wos_publications
    -- AND substring(wr.cited_source_uid, 1, 4) = 'WOS:'
    -- AND length(wr.cited_source_uid) = 19
    -- ensure that ref pubs year is not greater that source_id pubyear
  JOIN wos_publications wp ON wp.source_id = wr.cited_source_uid AND wp.publication_year::INT <= sus.source_year
  JOIN wos_document_identifiers wdi ON wdi.source_id = wp.source_id AND wdi.document_id_type IN ('issn', 'eissn')
  JOIN wos_doc_id_stats wis ON wis.document_id_type = wdi.document_id_type AND wis.document_id = wdi.document_id
) sq
WHERE rank = 1;

/*
TODO

EXECUTE format($$ALTER TABLE %I ADD CONSTRAINT %s_pk' PRIMARY KEY (source_id) USING INDEX TABLESPACE index_tbs $$, :dataset_name);*/

-- TODO Migrate to search_path
ALTER TABLE :dataset_name SET SCHEMA public;

-- clean up
-- DROP TABLE stg_uz_sources;

SELECT NOW();
