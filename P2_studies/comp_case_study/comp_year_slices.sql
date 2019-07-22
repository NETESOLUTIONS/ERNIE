-- Script to generate Scopus year slices for discipline COMP



\set ON_ERROR_STOP on
\set ECHO all

\set dataset 'comp_':year
\set dataset_pk :dataset'_pk'
\set dataset_index 'comp_':year'_reference_year_i'

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
       citation_type,
       source_publication,
       source_publication_id_type,
       source_type,
       cited_source_uid,
       reference_year,
       reference_citation_type,
       reference_publication,
       reference_publication_id_type,
       reference_source_type
FROM (
         SELECT source_sp.scp                                                              AS source_id,
                source_spg.pub_year                                                        AS source_year,
                source_sp.citation_type                                                    AS citation_type,
                coalesce(nullif(source_ss.issn_main, ''), nullif(source_ss.isbn_main, '')) AS source_publication,
                CASE
                    WHEN nullif(source_ss.issn_main, ' ') IS NULL THEN ''
                    WHEN nullif(source_ss.issn_main, '') IS NOT NULL
                        THEN 'issn'
                    ELSE 'isbn'
                    END                                                                    AS source_publication_id_type,
                source_ss.source_type                                                      AS source_type,
                ref_sp.scp                                                                 AS cited_source_uid,
                ref_spg.pub_year                                                           AS reference_year,
                ref_sp.citation_type                                                       AS reference_citation_type,
                coalesce(nullif(ref_ss.issn_main, ''), nullif(ref_ss.isbn_main, ''))       AS reference_publication,
                CASE
                    WHEN nullif(ref_ss.issn_main, ' ') IS NULL THEN ''
                    WHEN nullif(ref_ss.issn_main, '') IS NOT NULL THEN 'issn'
                    ELSE 'isbn'
                    END                                                                    AS reference_publication_id_type,
                ref_ss.source_type                                                         AS reference_source_type,
                count(1) OVER (PARTITION BY source_sp.scp)                                 AS ref_count
         FROM scopus_publications source_sp
                  JOIN scopus_publication_groups source_spg
                       ON source_spg.sgr = source_sp.sgr AND source_spg.pub_year = :year
                  JOIN scopus_sources source_ss
                       ON source_ss.ernie_source_id = source_sp.ernie_source_id AND
                          (source_ss.isbn_main != '' OR source_ss.issn_main != '')
                  JOIN scopus_references sr USING (scp)
                  JOIN scopus_publications ref_sp ON ref_sp.sgr = sr.ref_sgr
                  JOIN scopus_publication_groups ref_spg ON ref_spg.sgr = ref_sp.sgr AND ref_spg.pub_year <= :year
                  JOIN scopus_sources ref_ss
                       ON ref_ss.ernie_source_id = ref_sp.ernie_source_id AND
                          (ref_ss.isbn_main != '' OR ref_ss.issn_main != '')
                  JOIN scopus_subjects ss ON source_sp.scp = ss.scp
         WHERE ss.subj_abbr = 'COMP'
           AND source_sp.citation_language = 'English'
     ) sq
WHERE ref_count > 1;

ALTER TABLE :dataset
  ADD CONSTRAINT :dataset_pk PRIMARY KEY (source_id, cited_source_uid) --
    USING INDEX TABLESPACE index_tbs;

CREATE INDEX IF NOT EXISTS :dataset_index ON :dataset(reference_year) TABLESPACE index_tbs;