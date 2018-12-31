-- script to generate datasets for analysis of dataset_altschul
-- subset altschul subset by year-slice, join with dataset_1995
-- and generate comparison group by random selection 

-- The BLAST paper was published in 1990. The first papers to cite it appeared in 1991. This script
-- assembles 10 one-year slices.

\set ON_ERROR_STOP on
\set ECHO all

\set dataset 'dataset':year
\set analysis_slice 'blast_analysis_gen1_':year
\set analysis_slice_pk :analysis_slice'_pk'
\set comparison_slice 'blast_comparison_gen1_':year
\set comparison_slice_pk :comparison_slice'_pk'

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

SET SEARCH_PATH = public;

-- build 1991 slice from gen 1 data
-- join with dataaset_1991 t0 get blast_analysis_1991
DROP TABLE IF EXISTS :analysis_slice;

CREATE TABLE :analysis_slice TABLESPACE p2_studies AS
SELECT DISTINCT d.*
FROM dataset_altschul da
JOIN :dataset d ON d.source_id = da.citing1;
-- dataset pubs are all from the analyzed year
-- WHERE da.citing1_pubyear = '1991';

ALTER TABLE :analysis_slice --
  ADD CONSTRAINT :analysis_slice_pk PRIMARY KEY (source_id, cited_source_uid) USING INDEX TABLESPACE index_tbs;

-- create comparison group using same number of source_ids as blast_analysis_1991
DROP TABLE IF EXISTS :comparison_slice;

CREATE TABLE :comparison_slice TABLESPACE p2_studies AS
SELECT *
FROM :dataset
WHERE source_id IN (
  SELECT source_id
  FROM :dataset
  GROUP BY source_id
  HAVING source_id NOT IN (
    SELECT source_id
    FROM :analysis_slice
  )
  ORDER BY random()
  LIMIT :scale_factor * (
    SELECT count(DISTINCT source_id)
    FROM :analysis_slice
  )
);

ALTER TABLE :comparison_slice --
  ADD CONSTRAINT :comparison_slice_pk PRIMARY KEY (source_id, cited_source_uid) USING INDEX TABLESPACE index_tbs;