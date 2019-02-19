-- script to generate datasets for analysis of dataset_altschul for the year 2000
-- subset altschul subset by year-slice, join with dataset_1995
-- and generate comparison group by random selection 

-- The BLAST paper was published in 1990. The first papers to cite it appeared in 1991. This script
-- assembles several one-year slices.

-- build 1996 slice from gen 1 data
DROP TABLE IF EXISTS blast_data_gen1_1996;
CREATE TABLE public.blast_data_gen1_1996 TABLESPACE p2_studies AS 
SELECT DISTINCT citing1,citing1_pubyear 
FROM dataset_altschul WHERE citing1_pubyear='1996';
CREATE INDEX blast_data_gen1_1996_idx ON blast_data_gen1_1996(citing1);

-- join with dataset_1996 to get blast_analysis_1996
DROP TABLE IF EXISTS blast_analysis_gen1_1996;
CREATE TABLE public.blast_analysis_gen1_1996 TABLESPACE p2_studies AS 
SELECT b.* FROM blast_data_gen1_1996 a 
INNER JOIN dataset1996 b 
ON a.citing1=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis_1991
DROP TABLE IF EXISTS blast_comparison_gen1_1996;
CREATE TABLE public.blast_comparison_gen1_1996 TABLESPACE p2_studies AS
SELECT * FROM dataset1996
WHERE SOURCE_ID IN
(SELECT source_id FROM dataset1996 
WHERE  source_id NOT IN 
(SELECT DISTINCT source_id FROM blast_analysis_gen1_1996) 
ORDER BY random() limit (select count (distinct source_id) from blast_analysis_gen1_1996));

-- build another slice from gen 1 data...

-- build 1997 slice from gen 1 data

DROP TABLE IF EXISTS blast_data_gen1_1997;
CREATE TABLE public.blast_data_gen1_1997 TABLESPACE p2_studies AS
SELECT DISTINCT citing1,citing1_pubyear
FROM dataset_altschul WHERE citing1_pubyear='1997';
CREATE INDEX blast_data_gen1_1997_idx ON blast_data_gen1_1997(citing1);

-- join with dataset_1997 to get blast_analysis_1997                                                                                                              
DROP TABLE IF EXISTS blast_analysis_gen1_1997;
CREATE TABLE public.blast_analysis_gen1_1997 TABLESPACE p2_studies AS
SELECT b.* FROM blast_data_gen1_1997 a
INNER JOIN dataset1997 b
ON a.citing1=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis_1991                                                                                 
DROP TABLE IF EXISTS blast_comparison_gen1_1997;
CREATE TABLE public.blast_comparison_gen1_1997 TABLESPACE p2_studies AS
SELECT * FROM dataset1997
WHERE SOURCE_ID IN
(SELECT source_id FROM dataset1997
WHERE  source_id NOT IN
(SELECT DISTINCT source_id FROM blast_analysis_gen1_1997)
ORDER BY random() limit (select count (distinct source_id) from blast_analysis_gen1_1997));

-- build 1998 slice from gen 1 data

DROP TABLE IF EXISTS blast_data_gen1_1998;
CREATE TABLE public.blast_data_gen1_1998 TABLESPACE p2_studies AS
SELECT DISTINCT citing1,citing1_pubyear
FROM dataset_altschul WHERE citing1_pubyear='1998';
CREATE INDEX blast_data_gen1_1998_idx ON blast_data_gen1_1998(citing1);

-- join with dataset_1998 to get blast_analysis_1998                                                                                                              
DROP TABLE IF EXISTS blast_analysis_gen1_1998;
CREATE TABLE public.blast_analysis_gen1_1998 TABLESPACE p2_studies AS
SELECT b.* FROM blast_data_gen1_1998 a
INNER JOIN dataset1998 b
ON a.citing1=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis_1991                                                                                 
DROP TABLE IF EXISTS blast_comparison_gen1_1998;
CREATE TABLE public.blast_comparison_gen1_1998 TABLESPACE p2_studies AS
SELECT * FROM dataset1998
WHERE SOURCE_ID IN
(SELECT source_id FROM dataset1998
WHERE  source_id NOT IN
(SELECT DISTINCT source_id FROM blast_analysis_gen1_1998)
ORDER BY random() limit (select count (distinct source_id) from blast_analysis_gen1_1998));

-- build 1999 slice

DROP TABLE IF EXISTS blast_data_gen1_1999;
CREATE TABLE public.blast_data_gen1_1999 TABLESPACE p2_studies AS
SELECT DISTINCT citing1,citing1_pubyear
FROM dataset_altschul WHERE citing1_pubyear='1999';
CREATE INDEX blast_data_gen1_1999_idx ON blast_data_gen1_1999(citing1);

-- join with dataset_1999 to get blast_analysis_1999                                                                                                              
DROP TABLE IF EXISTS blast_analysis_gen1_1999;
CREATE TABLE public.blast_analysis_gen1_1999 TABLESPACE p2_studies AS
SELECT b.* FROM blast_data_gen1_1999 a
INNER JOIN dataset1999 b
ON a.citing1=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis_1991                                                                                 
DROP TABLE IF EXISTS blast_comparison_gen1_1999;
CREATE TABLE public.blast_comparison_gen1_1999 TABLESPACE p2_studies AS
SELECT * FROM dataset1999
WHERE SOURCE_ID IN
(SELECT source_id FROM dataset1999
WHERE  source_id NOT IN
(SELECT DISTINCT source_id FROM blast_analysis_gen1_1999)
ORDER BY random() limit (select count (distinct source_id) from blast_analysis_gen1_1999));




