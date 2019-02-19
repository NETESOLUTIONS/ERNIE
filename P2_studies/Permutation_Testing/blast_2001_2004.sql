-- script to generate datasets for analysis of dataset_altschul for the year 2000
-- subset altschul subset by year-slice, join with dataset_1995
-- and generate comparison group by random selection 

-- The BLAST paper was published in 1990. The first papers to cite it appeared in 1991. This script
-- assembles several one-year slices.

-- build 2001 slice from gen 1 data

DROP TABLE IF EXISTS blast_data_gen1_2001;
CREATE TABLE public.blast_data_gen1_2001 TABLESPACE p2_studies AS 
SELECT DISTINCT citing1,citing1_pubyear 
FROM dataset_altschul WHERE citing1_pubyear='2001';
CREATE INDEX blast_data_gen1_2001_idx ON blast_data_gen1_2001(citing1);

-- join with dataset_2001 to get blast_analysis_2001
DROP TABLE IF EXISTS blast_analysis_gen1_2001;
CREATE TABLE public.blast_analysis_gen1_2001 TABLESPACE p2_studies AS 
SELECT b.* FROM blast_data_gen1_2001 a 
INNER JOIN dataset2001 b 
ON a.citing1=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis_1991
DROP TABLE IF EXISTS blast_comparison_gen1_2001;
CREATE TABLE public.blast_comparison_gen1_2001 TABLESPACE p2_studies AS
SELECT * FROM dataset2001
WHERE SOURCE_ID IN
(SELECT source_id FROM dataset2001 
WHERE  source_id NOT IN 
(SELECT DISTINCT source_id FROM blast_analysis_gen1_2001) 
ORDER BY random() limit (select count (distinct source_id) from blast_analysis_gen1_2001));

-- build 2002 slice from gen1 data

DROP TABLE IF EXISTS blast_data_gen1_2002;
CREATE TABLE public.blast_data_gen1_2002 TABLESPACE p2_studies AS
SELECT DISTINCT citing1,citing1_pubyear
FROM dataset_altschul WHERE citing1_pubyear='2002';
CREATE INDEX blast_data_gen1_2002_idx ON blast_data_gen1_2002(citing1);

-- join with dataset_2002 to get blast_analysis_2002                                                                                                                                   
DROP TABLE IF EXISTS blast_analysis_gen1_2002;
CREATE TABLE public.blast_analysis_gen1_2002 TABLESPACE p2_studies AS
SELECT b.* FROM blast_data_gen1_2002 a
INNER JOIN dataset2002 b
ON a.citing1=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis_1991                                                                                                      
DROP TABLE IF EXISTS blast_comparison_gen1_2002;
CREATE TABLE public.blast_comparison_gen1_2002 TABLESPACE p2_studies AS
SELECT * FROM dataset2002
WHERE SOURCE_ID IN
(SELECT source_id FROM dataset2002
WHERE  source_id NOT IN
(SELECT DISTINCT source_id FROM blast_analysis_gen1_2002)
ORDER BY random() limit (select count (distinct source_id) from blast_analysis_gen1_2002));

-- build 2003 slice from gen1 data

DROP TABLE IF EXISTS blast_data_gen1_2003;
CREATE TABLE public.blast_data_gen1_2003 TABLESPACE p2_studies AS
SELECT DISTINCT citing1,citing1_pubyear
FROM dataset_altschul WHERE citing1_pubyear='2003';
CREATE INDEX blast_data_gen1_2003_idx ON blast_data_gen1_2003(citing1);

-- join with dataset_2003 to get blast_analysis_2003                                                                                                                                   
DROP TABLE IF EXISTS blast_analysis_gen1_2003;
CREATE TABLE public.blast_analysis_gen1_2003 TABLESPACE p2_studies AS
SELECT b.* FROM blast_data_gen1_2003 a
INNER JOIN dataset2003 b
ON a.citing1=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis_1991                                                                                                      
DROP TABLE IF EXISTS blast_comparison_gen1_2003;
CREATE TABLE public.blast_comparison_gen1_2003 TABLESPACE p2_studies AS
SELECT * FROM dataset2003
WHERE SOURCE_ID IN
(SELECT source_id FROM dataset2003
WHERE  source_id NOT IN
(SELECT DISTINCT source_id FROM blast_analysis_gen1_2003)
ORDER BY random() limit (select count (distinct source_id) from blast_analysis_gen1_2003));

-- build 2004 slice from gen1 data

DROP TABLE IF EXISTS blast_data_gen1_2004;
CREATE TABLE public.blast_data_gen1_2004 TABLESPACE p2_studies AS
SELECT DISTINCT citing1,citing1_pubyear
FROM dataset_altschul WHERE citing1_pubyear='2004';
CREATE INDEX blast_data_gen1_2004_idx ON blast_data_gen1_2004(citing1);

-- join with dataset_2004 to get blast_analysis_2004                                                                                                                                   
DROP TABLE IF EXISTS blast_analysis_gen1_2004;
CREATE TABLE public.blast_analysis_gen1_2004 TABLESPACE p2_studies AS
SELECT b.* FROM blast_data_gen1_2004 a
INNER JOIN dataset2004 b
ON a.citing1=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis_1991                                                                                                      
DROP TABLE IF EXISTS blast_comparison_gen1_2004;
CREATE TABLE public.blast_comparison_gen1_2004 TABLESPACE p2_studies AS
SELECT * FROM dataset2004
WHERE SOURCE_ID IN
(SELECT source_id FROM dataset2004
WHERE  source_id NOT IN
(SELECT DISTINCT source_id FROM blast_analysis_gen1_2004)
ORDER BY random() limit (select count (distinct source_id) from blast_analysis_gen1_2004));



