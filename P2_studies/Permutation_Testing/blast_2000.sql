-- script to generate datasets for analysis of dataset_altschul for the year 2000
-- subset altschul subset by year-slice, join with dataset_1995
-- and generate comparison group by random selection 

-- The BLAST paper was published in 1990. The first papers to cite it appeared in 1991. This script
-- assembles 10 one-year slices.

-- build 2000 slice from gen 1 data
DROP TABLE IF EXISTS blast_data_gen1_2000;
CREATE TABLE public.blast_data_gen1_2000 TABLESPACE p2_studies AS 
SELECT DISTINCT citing1,citing1_pubyear 
FROM dataset_altschul WHERE citing1_pubyear='2000';
CREATE INDEX blast_data_gen1_2000_idx ON blast_data_gen1_2000(citing1);

-- join with dataset_2000 to get blast_analysis_2000
DROP TABLE IF EXISTS blast_analysis_gen1_2000;
CREATE TABLE public.blast_analysis_gen1_2000 TABLESPACE p2_studies AS 
SELECT b.* FROM blast_data_gen1_2000 a 
INNER JOIN dataset2000 b 
ON a.citing1=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis_1991
DROP TABLE IF EXISTS blast_comparison_gen1_2000;
CREATE TABLE public.blast_comparison_gen1_2000 TABLESPACE p2_studies AS
SELECT * FROM dataset2000
WHERE SOURCE_ID IN
(SELECT source_id FROM dataset2000 
WHERE  source_id NOT IN 
(SELECT DISTINCT source_id FROM blast_analysis_gen1_2000) 
ORDER BY random() limit (select count (distinct source_id) from blast_analysis_gen1_2000));



-- build another slice from gen 1 data...

