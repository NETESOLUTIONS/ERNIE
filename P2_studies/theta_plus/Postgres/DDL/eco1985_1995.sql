-- create list of scps common to all 11 years (intersection)
CREATE TABLE theta_plus_ecology.eco_2000_2010_common_scps tablespace theta_plus_ecology_tbs AS
with cte as (select scp from eco2000_nodes INTERSECT
select scp from eco2001_nodes INTERSECT
select scp from eco2002_nodes INTERSECT
select scp from eco2003_nodes INTERSECT
select scp from eco2004_nodes INTERSECT
select scp from eco2005_nodes INTERSECT
select scp from eco2005_nodes INTERSECT
select scp from eco2006_nodes INTERSECT
select scp from eco2007_nodes INTERSECT
select scp from eco2008_nodes INTERSECT
select scp from eco2009_nodes INTERSECT
select scp from eco2010_nodes) select * from cte;

CREATE INDEX eco2000_citing_cited_idx ON theta_plus_ecology.eco2000_citing_cited(citing,cited) TABLESPACE index_tbs;
CREATE INDEX eco2001_citing_cited_idx ON theta_plus_ecology.eco2001_citing_cited(citing,cited) TABLESPACE index_tbs;
CREATE INDEX eco2002_citing_cited_idx ON theta_plus_ecology.eco2002_citing_cited(citing,cited) TABLESPACE index_tbs;
CREATE INDEX eco2003_citing_cited_idx ON theta_plus_ecology.eco2003_citing_cited(citing,cited) TABLESPACE index_tbs;
CREATE INDEX eco2004_citing_cited_idx ON theta_plus_ecology.eco2004_citing_cited(citing,cited) TABLESPACE index_tbs;
CREATE INDEX eco2005_citing_cited_idx ON theta_plus_ecology.eco2005_citing_cited(citing,cited) TABLESPACE index_tbs;
CREATE INDEX eco2006_citing_cited_idx ON theta_plus_ecology.eco2006_citing_cited(citing,cited) TABLESPACE index_tbs;
CREATE INDEX eco2007_citing_cited_idx ON theta_plus_ecology.eco2007_citing_cited(citing,cited) TABLESPACE index_tbs;
CREATE INDEX eco2008_citing_cited_idx ON theta_plus_ecology.eco2008_citing_cited(citing,cited) TABLESPACE index_tbs;
CREATE INDEX eco2009_citing_cited_idx ON theta_plus_ecology.eco2009_citing_cited(citing,cited) TABLESPACE index_tbs;
CREATE INDEX eco2010_citing_cited_idx ON theta_plus_ecology.eco2010_citing_cited(citing,cited) TABLESPACE index_tbs;
-- create union of edge lists across 11 years

DROP TABLE IF EXISTS theta_plus_ecology.eco2000_2010_citing_cited_union;
CREATE TABLE theta_plus_ecology.eco_2000_2010_citing_cited TABLESPACE theta_plus_ecology_tbs AS
SELECT * FROM eco2000_citing_cited UNION
SELECT * FROM eco2001_citing_cited UNION
SELECT * FROM eco2002_citing_cited UNION
SELECT * FROM eco2003_citing_cited UNION
SELECT * FROM eco2004_citing_cited UNION
SELECT * FROM eco2005_citing_cited UNION
SELECT * FROM eco2006_citing_cited UNION
SELECT * FROM eco2007_citing_cited UNION
SELECT * FROM eco2008_citing_cited UNION
SELECT * FROM eco2009_citing_cited UNION
SELECT * FROM eco2010_citing_cited;

DROP TABLE IF EXISTS theta_plus_ecology.eco2000_2010_title_abstracts_intersection;
CREATE TABLE theta_plus_ecology.eco2000_2010_title_abstracts_intersection
TABLESPACE theta_plus_ecology_tbs AS
SELECT tpin.scp,st.title,sa.abstract_text
FROM theta_plus_ecology.eco2000_2010_nodes_intersection tpin
INNER JOIN scopus_titles st ON tpin.scp=st.scp
INNER JOIN scopus_abstracts sa ON tpin.scp=sa.scp
AND sa.abstract_language='eng'
AND st.language='English';

DROP TABLE IF EXISTS theta_plus_ecology.eco2000_2010_nodes_union;
CREATE TABLE theta_plus_ecology.eco2000_2010_nodes
TABLESPACE theta_plus_ecology_tbs AS
SELECT distinct citing as scp
FROM theta_plus_ecology.eco2000_2010_citing_cited_union
UNION
SELECT distinct cited
FROM theta_plus_ecology.eco2000_2010_citing_cited_union;
CREATE INDEX eco2000_2010_nodes_idx ON theta_plus_ecology.eco2000_2010_nodes_union(scp);

DROP TABLE IF EXISTS theta_plus_ecology.eco2000_2010_union_title_abstracts;
CREATE TABLE theta_plus_ecology.eco2000_2010_union_title_abstracts
TABLESPACE theta_plus_ecology_tbs AS
SELECT tpin.scp,st.title,sa.abstract_text
FROM theta_plus_ecology.eco2000_2010_nodes_union tpin
INNER JOIN public.scopus_titles st ON tpin.scp=st.scp
INNER JOIN public.scopus_abstracts sa ON tpin.scp=sa.scp
AND sa.abstract_language='eng'
AND st.language='English';