-- Get combined set (superset) of all 5 years of data

SET SEARCH_PATH = theta_plus;

-- -- create list of scps common to all 5 years (intersection)
-- DROP TABLE IF EXISTS theta_plus.imm2000_2004_common_scps;
-- CREATE TABLE theta_plus.imm2000_2004_common_scps tablespace theta_plus_tbs AS
-- WITH cte AS (SELECT scp FROM imm2000_nodes INTERSECT
--              SELECT scp FROM imm2001_nodes INTERSECT
--              SELECT scp FROM imm2002_nodes INTERSECT
--              SELECT scp FROM imm2003_nodes INTERSECT
--              SELECT scp FROM imm2004_nodes INTERSECT) 
--  SELECT * FROM cte;

-- CREATE INDEX IF NOT EXISTS imm2000_citing_cited_idx 
-- ON theta_plus.imm2000_citing_cited(citing,cited) 
-- TABLESPACE index_tbs;

-- CREATE INDEX IF NOT EXISTS imm2001_citing_cited_idx 
-- ON theta_plus.imm2001_citing_cited(citing,cited) 
-- TABLESPACE index_tbs;

-- CREATE INDEX IF NOT EXISTS imm2002_citing_cited_idx 
-- ON theta_plus.imm2002_citing_cited(citing,cited) 
-- TABLESPACE index_tbs;

-- CREATE INDEX IF NOT EXISTS imm2003_citing_cited_idx 
-- ON theta_plus.imm2003_citing_cited(citing,cited) 
-- TABLESPACE index_tbs;

-- CREATE INDEX IF NOT EXISTS imm2004_citing_cited_idx 
-- ON theta_plus.imm2004_citing_cited(citing,cited) 
-- TABLESPACE index_tbs;

-- CREATE INDEX IF NOT EXISTS imm2005_citing_cited_idx 
-- ON theta_plus.imm2005_citing_cited(citing,cited) 
-- TABLESPACE index_tbs;



-- create union of edge lists across 5 years

DROP TABLE IF EXISTS theta_plus.imm2000_2004_citing_cited;
CREATE TABLE theta_plus.imm2000_2004_citing_cited 
TABLESPACE theta_plus_tbs AS
    SELECT * FROM imm2000_citing_cited UNION
    SELECT * FROM imm2001_citing_cited UNION
    SELECT * FROM imm2002_citing_cited UNION
    SELECT * FROM imm2003_citing_cited UNION
    SELECT * FROM imm2004_citing_cited;

DROP TABLE IF EXISTS theta_plus.imm2000_2004_nodes;
CREATE TABLE theta_plus.imm2000_2004_nodes
TABLESPACE theta_plus_tbs AS
    SELECT distinct citing as scp
    FROM theta_plus.imm2000_2004_citing_cited
    UNION
    SELECT distinct cited
    FROM theta_plus.imm2000_2004_citing_cited;
    
CREATE INDEX IF NOT EXISTS imm2000_2004_nodes_idx 
    ON theta_plus.imm2000_2004_nodes(scp);

DROP TABLE IF EXISTS theta_plus.imm2000_2004_union_title_abstracts;
CREATE TABLE theta_plus.imm2000_2004_union_title_abstracts
TABLESPACE theta_plus_tbs AS
    SELECT tpin.scp, st.title, sa.abstract_text
    FROM theta_plus.imm2000_2004_nodes tpin
    INNER JOIN public.scopus_titles st 
            ON tpin.scp=st.scp
    INNER JOIN public.scopus_abstracts sa 
            ON tpin.scp=sa.scp
            AND sa.abstract_language='eng'
            AND st.language='English';

-- total seed set count
-- imm2000_2004
-- [18395, 17114, 16550, 16291, 17323]