-- script to generate datasets for analysis of dataset_altschul
-- subset altschul subset by year-slice, join with dataset_1995
-- and generate comparison group by random selection 

-- The BLAST paper was published in 1990. The first papers to cite it appeared in 1991. This script
-- assembles 10 one-year slices of citing papers and randomly drawn papers for a comparison group

-- build 1991 slice from gen 1 data
DROP TABLE IF EXISTS blast_data_gen1_1991;
CREATE TABLE public.blast_data_gen1_1991 TABLESPACE p2_studies AS 
SELECT DISTINCT citing1,citing1_pubyear 
FROM dataset_altschul WHERE citing1_pubyear='1991';

-- join with dataset_1991 to get blast_analysis_1991
DROP TABLE IF EXISTS blast_analysis_gen1_1991;
CREATE TABLE public.blast_analysis_gen1_1991 TABLESPACE p2_studies AS 
SELECT b.* FROM blast_data_gen1_1991 a 
INNER JOIN dataset1991 b 
ON a.citing1=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis_1991
DROP TABLE IF EXISTS blast_comparison_gen1_1991;
CREATE TABLE public.blast_comparison_gen1_1991 TABLESPACE p2_studies AS
SELECT * FROM dataset1991
WHERE source_id IN 
(SELECT source_id FROM dataset1991 
WHERE  source_id NOT IN 
(SELECT DISTINCT source_id FROM blast_analysis_gen1_1991) 
ORDER BY random() limit (select count (distinct source_id) from blast_analysis_gen1_1991));

-- build 1992 slice from gen 1 data                                                                                                                                                                 
DROP TABLE IF EXISTS blast_data_gen1_1992;
CREATE TABLE public.blast_data_gen1_1992 TABLESPACE p2_studies AS
SELECT DISTINCT citing1,citing1_pubyear
FROM dataset_altschul WHERE citing1_pubyear='1992';

-- join with dataset_1992 to get blast_analysis_1992                                                                                                                                               
DROP TABLE IF EXISTS blast_analysis_gen1_1992;
CREATE TABLE public.blast_analysis_gen1_1992 TABLESPACE p2_studies AS
SELECT b.* FROM blast_data_gen1_1992 a
INNER JOIN dataset1992 b
ON a.citing1=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis                                                                                                                  
DROP TABLE IF EXISTS blast_comparison_gen1_1992;
CREATE TABLE public.blast_comparison_gen1_1992 TABLESPACE p2_studies AS
SELECT * FROM dataset1992
WHERE source_id IN
(SELECT source_id FROM dataset1992
WHERE  source_id NOT IN
(SELECT DISTINCT source_id FROM blast_analysis_gen1_1992)
ORDER BY random() limit (select count (distinct source_id) from blast_analysis_gen1_1992));

-- build 1993 slice from gen 1 data                                                                                                                                                                 
DROP TABLE IF EXISTS blast_data_gen1_1993;
CREATE TABLE public.blast_data_gen1_1993 TABLESPACE p2_studies AS
SELECT DISTINCT citing1,citing1_pubyear
FROM dataset_altschul WHERE citing1_pubyear='1993';

-- join with dataset_1993 to get blast_analysis_1993                                                                                                                                               
DROP TABLE IF EXISTS blast_analysis_gen1_1993;
CREATE TABLE public.blast_analysis_gen1_1993 TABLESPACE p2_studies AS
SELECT b.* FROM blast_data_gen1_1993 a
INNER JOIN dataset1993 b
ON a.citing1=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis                                                                                                                    
DROP TABLE IF EXISTS blast_comparison_gen1_1993;
CREATE TABLE public.blast_comparison_gen1_1993 TABLESPACE p2_studies AS
SELECT * FROM dataset1993
WHERE source_id IN
(SELECT source_id FROM dataset1993
WHERE  source_id NOT IN
(SELECT DISTINCT source_id FROM blast_analysis_gen1_1993)
ORDER BY random() limit (select count (distinct source_id) from blast_analysis_gen1_1993));

-- build 1994 slice from gen 1 data                                                                                                                                                                 
DROP TABLE IF EXISTS blast_data_gen1_1994;
CREATE TABLE public.blast_data_gen1_1994 TABLESPACE p2_studies AS
SELECT DISTINCT citing1,citing1_pubyear
FROM dataset_altschul WHERE citing1_pubyear='1994';

-- join with dataset_1994 to get blast_analysis_1994                                                                                                                                               
DROP TABLE IF EXISTS blast_analysis_gen1_1994;
CREATE TABLE public.blast_analysis_gen1_1994 TABLESPACE p2_studies AS
SELECT b.* FROM blast_data_gen1_1994 a
INNER JOIN dataset1994 b
ON a.citing1=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis                                                                                                                    
DROP TABLE IF EXISTS blast_comparison_gen1_1994;
CREATE TABLE public.blast_comparison_gen1_1994 TABLESPACE p2_studies AS
SELECT * FROM dataset1994
WHERE source_id IN
(SELECT source_id FROM dataset1994
WHERE  source_id NOT IN
(SELECT DISTINCT source_id FROM blast_analysis_gen1_1994)
ORDER BY random() limit (select count (distinct source_id) from blast_analysis_gen1_1994));

-- build 1995 slice from gen 1 data                                                                                                                                                                 
DROP TABLE IF EXISTS blast_data_gen1_1995;
CREATE TABLE public.blast_data_gen1_1995 TABLESPACE p2_studies AS
SELECT DISTINCT citing1,citing1_pubyear
FROM dataset_altschul WHERE citing1_pubyear='1995';

-- join with dataset_1995 to get blast_analysis_1995                                                                                                                                               
DROP TABLE IF EXISTS blast_analysis_gen1_1995;
CREATE TABLE public.blast_analysis_gen1_1995 TABLESPACE p2_studies AS
SELECT b.* FROM blast_data_gen1_1995 a
INNER JOIN dataset1995 b
ON a.citing1=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis                                                                                                                    
DROP TABLE IF EXISTS blast_comparison_gen1_1995;
CREATE TABLE public.blast_comparison_gen1_1995 TABLESPACE p2_studies AS
SELECT * FROM dataset1995
WHERE source_id IN
(SELECT source_id FROM dataset1995
WHERE  source_id NOT IN
(SELECT DISTINCT source_id FROM blast_analysis_gen1_1995)
ORDER BY random() limit (select count (distinct source_id) from blast_analysis_gen1_1995));

-- *************************
-- generation 2 calculations
-- *************************

DROP TABLE IF EXISTS blast_data_gen2_1991;
CREATE TABLE public.blast_data_gen2_1991 TABLESPACE p2_studies AS
SELECT DISTINCT citing2,citing2_pubyear
FROM dataset_altschul WHERE citing2_pubyear='1991';

-- join with dataset_1991 to get blast_analysis_1991                                                                                                                                      
DROP TABLE IF EXISTS blast_analysis_gen2_1991;
CREATE TABLE public.blast_analysis_gen2_1991 TABLESPACE p2_studies AS
SELECT b.* FROM blast_data_gen2_1991 a
INNER JOIN dataset1991 b
ON a.citing2=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis_1991                                                                                                         
--1991 
DROP TABLE IF EXISTS blast_comparison_gen2_1991;
CREATE TABLE public.blast_comparison_gen2_1991 TABLESPACE p2_studies AS
SELECT * FROM dataset1991
WHERE source_id IN
(SELECT source_id FROM dataset1991
WHERE  source_id NOT IN
(SELECT DISTINCT source_id FROM blast_analysis_gen2_1991)
ORDER BY random() LIMIT (select count (distinct citing2) FROM blast_data_gen2_1991));

-- 1992
DROP TABLE IF EXISTS blast_data_gen2_1992;
CREATE TABLE public.blast_data_gen2_1992 TABLESPACE p2_studies AS
SELECT DISTINCT citing2,citing2_pubyear
FROM dataset_altschul WHERE citing2_pubyear='1992';

-- join with dataset_1992 to get blast_analysis_1992                                                                                                                                      
DROP TABLE IF EXISTS blast_analysis_gen2_1992;
CREATE TABLE public.blast_analysis_gen2_1992 TABLESPACE p2_studies AS
SELECT b.* FROM blast_data_gen2_1992 a
INNER JOIN dataset1992 b
ON a.citing2=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis_1992                                                                                                          
DROP TABLE IF EXISTS blast_comparison_gen2_1992;
CREATE TABLE public.blast_comparison_gen2_1992 TABLESPACE p2_studies AS
SELECT * FROM dataset1992
WHERE source_id IN
(SELECT source_id FROM dataset1992
WHERE  source_id NOT IN
(SELECT DISTINCT source_id FROM blast_analysis_gen2_1992)
ORDER BY random() LIMIT (select count (distinct citing2) FROM blast_data_gen2_1992));

-- 1993
DROP TABLE IF EXISTS blast_data_gen2_1993;
CREATE TABLE public.blast_data_gen2_1993 TABLESPACE p2_studies AS
SELECT DISTINCT citing2,citing2_pubyear
FROM dataset_altschul WHERE citing2_pubyear='1993';

-- join with dataset_1993 to get blast_analysis_1993                                                                                                                                      
DROP TABLE IF EXISTS blast_analysis_gen2_1993;
CREATE TABLE public.blast_analysis_gen2_1993 TABLESPACE p2_studies AS
SELECT b.* FROM blast_data_gen2_1993 a
INNER JOIN dataset1993 b
ON a.citing2=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis_1993                                                                                                          
DROP TABLE IF EXISTS blast_comparison_gen2_1993;
CREATE TABLE public.blast_comparison_gen2_1993 TABLESPACE p2_studies AS
SELECT * FROM dataset1993
WHERE source_id IN
(SELECT source_id FROM dataset1993
WHERE  source_id NOT IN
(SELECT DISTINCT source_id FROM blast_analysis_gen2_1993)
ORDER BY random() LIMIT (select count (distinct citing2) FROM blast_data_gen2_1993));

-- 1994
DROP TABLE IF EXISTS blast_data_gen2_1994;
CREATE TABLE public.blast_data_gen2_1994 TABLESPACE p2_studies AS
SELECT DISTINCT citing2,citing2_pubyear
FROM dataset_altschul WHERE citing2_pubyear='1994';

-- join with dataset_1994 to get blast_analysis_1994                                                                                                                                      
DROP TABLE IF EXISTS blast_analysis_gen2_1994;
CREATE TABLE public.blast_analysis_gen2_1994 TABLESPACE p2_studies AS
SELECT b.* FROM blast_data_gen2_1994 a
INNER JOIN dataset1994 b
ON a.citing2=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis_1994                                                                                                          
DROP TABLE IF EXISTS blast_comparison_gen2_1994;
CREATE TABLE public.blast_comparison_gen2_1994 TABLESPACE p2_studies AS
SELECT * FROM dataset1994
WHERE source_id IN
(SELECT source_id FROM dataset1994
WHERE  source_id NOT IN
(SELECT DISTINCT source_id FROM blast_analysis_gen2_1994)
ORDER BY random() LIMIT (select count (distinct citing2) FROM blast_data_gen2_1994));

-- 1995
DROP TABLE IF EXISTS blast_data_gen2_1995;
CREATE TABLE public.blast_data_gen2_1995 TABLESPACE p2_studies AS
SELECT DISTINCT citing2,citing2_pubyear
FROM dataset_altschul WHERE citing2_pubyear='1995';

-- join with dataset_1995 to get blast_analysis_1995                                                                                                                                      
DROP TABLE IF EXISTS blast_analysis_gen2_1995;
CREATE TABLE public.blast_analysis_gen2_1995 TABLESPACE p2_studies AS
SELECT b.* FROM blast_data_gen2_1995 a
INNER JOIN dataset1995 b
ON a.citing2=b.source_id;

-- create comparison group using same number of source_ids as blast_analysis                                                                                                          
DROP TABLE IF EXISTS blast_comparison_gen2_1995;
CREATE TABLE public.blast_comparison_gen2_1995 TABLESPACE p2_studies AS
SELECT * FROM dataset1995
WHERE source_id IN
(SELECT source_id FROM dataset1995
WHERE  source_id NOT IN
(SELECT DISTINCT source_id FROM blast_analysis_gen2_1995)
ORDER BY random() LIMIT (select count (distinct citing2) FROM blast_data_gen2_1995));

