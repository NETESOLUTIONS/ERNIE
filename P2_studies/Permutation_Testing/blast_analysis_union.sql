DROP TABLE IF EXISTS public. blast_1991_2005_analysis;

CREATE TABLE public.blast_1991_2005_analysis TABLESPACE p2_studies AS

SELECT * FROM  blast_analysis_gen1_1991
UNION
SELECT * FROM  blast_analysis_gen1_1992
UNION
SELECT * FROM  blast_analysis_gen1_1993
UNION
SELECT * FROM  blast_analysis_gen1_1994
UNION
SELECT * FROM  blast_analysis_gen1_1995
UNION
SELECT * FROM  blast_analysis_gen1_1996
UNION
SELECT * FROM  blast_analysis_gen1_1997
UNION
SELECT * FROM  blast_analysis_gen1_1998
UNION
SELECT * FROM  blast_analysis_gen1_1999
UNION
SELECT * FROM  blast_analysis_gen1_2000
UNION
SELECT * FROM  blast_analysis_gen1_2001
UNION
SELECT * FROM  blast_analysis_gen1_2001
UNION
SELECT * FROM  blast_analysis_gen1_2003
UNION
SELECT * FROM  blast_analysis_gen1_2004
UNION
SELECT * FROM  blast_analysis_gen1_2005;

ALTER TABLE blast_1991_2005_analysis ADD PRIMARY KEY (source_id,source_year,cited_source_uid);







