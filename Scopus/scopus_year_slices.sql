-- test script to test Monte-Carlo methods for networks
-- this script was specifically developed for the ERNIE project
-- but can be used for benchmarking performance
-- George Chacko 12/8/2018
-- cleaned up bad git merge and replace 'gc_mc' with 'stg_uz_ds' (Uzzi-dataslice)
-- DK added expresions to select most frequently used issns where multiple values exist
-- can pass parametes now
-- e.g., nohup  psql -f /home/chackoge/ERNIE/P2_studies/Uzzi/stg_uz_ds.sql -v year=1980 &
-- George Chacko 12/20/2018
-- Sitaram Devarakonda 06/24/2018
-- Ported code to work on Scopus data

\set ON_ERROR_STOP on
\set ECHO all

\set dataset 'dataset':year
\set dataset_pk :dataset'_pk'
\set dataset_index 'd':year'_reference_year_i'
\set shuffled_view :dataset'_shuffled'

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

SET SEARCH_PATH = public;

-- SELECT NOW();

DROP TABLE IF EXISTS :dataset CASCADE;

CREATE TABLE :dataset TABLESPACE p2_studies AS
SELECT source_id,
       source_year,
       source_document_id_type,
       source_issn,
       cited_source_uid,
       reference_year,
       reference_document_id_type,
       reference_issn
FROM (
         SELECT sp.scp                              AS source_id,
                spg.pub_year                        AS source_year,
                'issn'                              AS source_document_id_type,
                ss.issn_main                        AS source_issn,
                sp2.scp                             AS cited_source_uid,
                spg2.pub_year                       AS reference_year,
                'issn'                              AS reference_document_id_type,
                ss2.issn_main                       AS reference_issn,
                count(1) OVER (PARTITION BY sp.scp) AS ref_count
         FROM scopus_publications sp
                  JOIN scopus_publication_groups spg ON sp.sgr = spg.sgr
                  JOIN scopus_sources ss ON sp.ernie_source_id = ss.ernie_source_id
                  JOIN scopus_references sr ON sp.scp = sr.scp
                  JOIN scopus_publications sp2 ON sp2.sgr = sr.ref_sgr
                  JOIN scopus_publication_groups spg2 ON spg2.sgr = sp2.sgr AND spg2.pub_year <= :year
                  JOIN scopus_sources ss2 ON sp2.ernie_source_id = ss2.ernie_source_id
         WHERE spg.pub_year = :year
           AND sp.citation_type = 'ar'
           AND ss.issn_main != ''
           AND ss2.issn_main != ''
     ) sq
WHERE ref_count > 1;

ALTER TABLE :dataset
    ADD CONSTRAINT :dataset_pk PRIMARY KEY (source_id, cited_source_uid) --
        USING INDEX TABLESPACE index_tbs;

CREATE INDEX IF NOT EXISTS :dataset_index ON :dataset (reference_year) TABLESPACE index_tbs;