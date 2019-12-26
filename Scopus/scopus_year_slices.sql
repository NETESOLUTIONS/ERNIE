-- test script to test Monte-Carlo methods for networks
-- -- this script was specifically developed for the ERNIE project
-- -- but can be used for benchmarking performance
-- -- George Chacko 12/8/2018
-- -- cleaned up bad git merge and replace 'gc_mc' with 'stg_uz_ds' (Uzzi-dataslice)
-- -- DK added expresions to select most frequently used issns where multiple values exist
-- -- can pass parametes now
-- -- e.g., nohup  psql -f /home/chackoge/ERNIE/P2_studies/Uzzi/stg_uz_ds.sql -v year=1980 &
-- -- George Chacko 12/20/2018
-- -- Sitaram Devarakonda 06/24/2018
-- -- Ported code to work on Scopus data

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

CREATE TABLE :dataset
    TABLESPACE p2_studies_tbs --
AS
SELECT source_id,
       source_year,
       source_document_id_type,
       source_issn,
       cited_source_uid,
       reference_year,
       reference_document_id_type,
       reference_issn
FROM (
         SELECT source_sp.scp                              AS source_id,
                source_spg.pub_year                        AS source_year,
                'issn'                                     AS source_document_id_type,
                source_ss.issn_main                        AS source_issn,
                ref_sp.scp                                 AS cited_source_uid,
                ref_spg.pub_year                           AS reference_year,
                'issn'                                     AS reference_document_id_type,
                ref_ss.issn_main                           AS reference_issn,
                count(1) OVER (PARTITION BY source_sp.scp) AS ref_count
         FROM scopus_publications source_sp
                  JOIN scopus_publication_groups source_spg
                       ON source_spg.sgr = source_sp.sgr AND source_spg.pub_year = :year
                  JOIN scopus_sources source_ss
                       ON source_ss.ernie_source_id = source_sp.ernie_source_id AND source_ss.issn_main != ''
                  JOIN scopus_references sr USING (scp)
                  JOIN scopus_publications ref_sp ON ref_sp.sgr = sr.ref_sgr
                  JOIN scopus_publication_groups ref_spg ON ref_spg.sgr = ref_sp.sgr AND ref_spg.pub_year <= :year
                  JOIN scopus_sources ref_ss
                       ON ref_ss.ernie_source_id = ref_sp.ernie_source_id AND ref_ss.issn_main != ''
         WHERE source_sp.citation_type = 'ar'
     ) sq
WHERE ref_count > 4;

ALTER TABLE :dataset
    ADD CONSTRAINT :dataset_pk PRIMARY KEY (source_id, cited_source_uid) --
        USING INDEX TABLESPACE index_tbs;


DELETE
FROM :dataset
WHERE source_id = cited_source_uid;

DELETE
FROM :dataset
WHERE source_id IN (
    SELECT source_id FROM :dataset GROUP BY source_id HAVING count(cited_source_uid) < 5);

CREATE INDEX IF NOT EXISTS :dataset_index ON :dataset (reference_year) TABLESPACE index_tbs;
