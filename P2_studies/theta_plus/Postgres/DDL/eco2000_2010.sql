-- Get combined set (superset) of all 11 years of data

SET SEARCH_PATH = theta_plus_ecology;

-- create list of scps common to all 11 years (intersection)
DROP TABLE IF EXISTS theta_plus_ecology.eco2000_2010_common_scps;
CREATE TABLE theta_plus_ecology.eco2000_2010_common_scps tablespace theta_plus_tbs AS
WITH cte AS (SELECT scp FROM eco2000_nodes INTERSECT
             SELECT scp FROM eco2001_nodes INTERSECT
             SELECT scp FROM eco2002_nodes INTERSECT
             SELECT scp FROM eco2003_nodes INTERSECT
             SELECT scp FROM eco2004_nodes INTERSECT
             SELECT scp FROM eco2005_nodes INTERSECT
             SELECT scp FROM eco2005_nodes INTERSECT
             SELECT scp FROM eco2006_nodes INTERSECT
             SELECT scp FROM eco2007_nodes INTERSECT
             SELECT scp FROM eco2008_nodes INTERSECT
             SELECT scp FROM eco2009_nodes INTERSECT
             SELECT scp FROM eco2010_nodes) 
 SELECT * FROM cte;

CREATE INDEX IF NOT EXISTS eco2000_citing_cited_idx 
ON theta_plus_ecology.eco2000_citing_cited(citing,cited) 
TABLESPACE index_tbs;

CREATE INDEX IF NOT EXISTS eco2001_citing_cited_idx 
ON theta_plus_ecology.eco2001_citing_cited(citing,cited) 
TABLESPACE index_tbs;

CREATE INDEX IF NOT EXISTS eco2002_citing_cited_idx 
ON theta_plus_ecology.eco2002_citing_cited(citing,cited) 
TABLESPACE index_tbs;

CREATE INDEX IF NOT EXISTS eco2003_citing_cited_idx 
ON theta_plus_ecology.eco2003_citing_cited(citing,cited) 
TABLESPACE index_tbs;

CREATE INDEX IF NOT EXISTS eco2004_citing_cited_idx 
ON theta_plus_ecology.eco2004_citing_cited(citing,cited) 
TABLESPACE index_tbs;

CREATE INDEX IF NOT EXISTS eco2005_citing_cited_idx 
ON theta_plus_ecology.eco2005_citing_cited(citing,cited) 
TABLESPACE index_tbs;

CREATE INDEX IF NOT EXISTS eco2006_citing_cited_idx 
ON theta_plus_ecology.eco2006_citing_cited(citing,cited) 
TABLESPACE index_tbs;

CREATE INDEX IF NOT EXISTS eco2007_citing_cited_idx 
ON theta_plus_ecology.eco2007_citing_cited(citing,cited) 
TABLESPACE index_tbs;

CREATE INDEX IF NOT EXISTS eco2008_citing_cited_idx 
ON theta_plus_ecology.eco2008_citing_cited(citing,cited) 
TABLESPACE index_tbs;

CREATE INDEX IF NOT EXISTS eco2009_citing_cited_idx 
ON theta_plus_ecology.eco2009_citing_cited(citing,cited) 
TABLESPACE index_tbs;

CREATE INDEX IF NOT EXISTS eco2010_citing_cited_idx 
ON theta_plus_ecology.eco2010_citing_cited(citing,cited) 
TABLESPACE index_tbs;


-- create union of edge lists across 11 years

DROP TABLE IF EXISTS theta_plus_ecology.eco2000_2010_citing_cited;
CREATE TABLE theta_plus_ecology.eco2000_2010_citing_cited 
TABLESPACE theta_plus_tbs AS
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

DROP TABLE IF EXISTS theta_plus_ecology.eco2000_2010_nodes;
CREATE TABLE theta_plus_ecology.eco2000_2010_nodes
TABLESPACE theta_plus_tbs AS
    SELECT distinct citing as scp
    FROM theta_plus_ecology.eco2000_2010_citing_cited
    UNION
    SELECT distinct cited
    FROM theta_plus_ecology.eco2000_2010_citing_cited;
    
CREATE INDEX IF NOT EXISTS eco2000_2010_nodes_idx 
    ON theta_plus_ecology.eco2000_2010_nodes(scp);

DROP TABLE IF EXISTS theta_plus_ecology.eco2000_2010_union_title_abstracts;
CREATE TABLE theta_plus_ecology.eco2000_2010_union_title_abstracts
TABLESPACE theta_plus_tbs AS
    SELECT tpin.scp, st.title, sa.abstract_text
    FROM theta_plus_ecology.eco2000_2010_nodes tpin
    INNER JOIN public.scopus_titles st 
            ON tpin.scp=st.scp
    INNER JOIN public.scopus_abstracts sa 
            ON tpin.scp=sa.scp
            AND sa.abstract_language='eng'
            AND st.language='English';


-- Total seed set count:

-- eco2000_2010
-- [29111, 30240, 30976, 31945, 31788, 34773, 38498, 42820, 46437, 50262, 52460]