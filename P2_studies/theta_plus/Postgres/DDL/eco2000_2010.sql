-- Get combined set (superset) of all 11 years of data

SET SEARCH_PATH = theta_plus_ecology;

--
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
    
COMMENT ON TABLE theta_plus.2000_2004_citing_cited IS
  'Union of theta_plus_ecology.eco2000_citing_cited through theta_plus_ecology.eco2010_citing_cited tables';
COMMENT ON COLUMN theta_plus_ecology.eco2000_2010_cited.citing IS 'SCP of seed articles from 2000 to 2010 and their citing references';
COMMENT ON COLUMN theta_plus_ecology.eco2000_2010_cited.cited IS 'SCP of seed articles from 2000 to 2010 and their cited references';
    
--
-- Get all nodes in the 2000-2010 dataset
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

COMMENT ON TABLEtheta_plus_ecology.eco2000_2010_nodes IS
  'All seed articles from 2000 to 2010 and their citing and cited references';
COMMENT ON COLUMN theta_plus_ecology.eco2000_2010_nodes.scp IS
  'SCPs of all seed articles from 2000 to 2010 and their citing and cited references';

--
-- Get all titles and abstracts for the 2000-2010 dataset
DROP TABLE IF EXISTS theta_plus_ecology.eco2000_2010_title_abstracts;
CREATE TABLE theta_plus_ecology.eco2000_2010_title_abstracts
TABLESPACE theta_plus_tbs AS
    SELECT tpin.scp, st.title, sa.abstract_text
    FROM theta_plus_ecology.eco2000_2010_nodes tpin
    INNER JOIN public.scopus_titles st 
            ON tpin.scp=st.scp
    INNER JOIN public.scopus_abstracts sa 
            ON tpin.scp=sa.scp
            AND sa.abstract_language='eng'
            AND st.language='English';
            
COMMENT ON TABLE theta_plus_ecology.eco2000_2010_title_abstracts IS
   'All titles and abstracts for seed articles from 2000 to 2010 and their citing and cited references';
COMMENT ON COLUMN theta_plus_ecology.eco2000_2010_title_abstracts.scp IS
  'SCPs of all seed articles from 2000 to 2010 and their citing and cited references';
COMMENT ON COLUMN theta_plus_ecology.eco2000_2010_title_abstracts.title IS
  'Titles of all seed articles from 2000 to 2010 and their citing and cited references';
COMMENT ON COLUMN theta_plus_ecology.eco2000_2010_title_abstracts.abstract_text IS
  'Abstracts of all seed articles from 2000 to 2010 and their citing and cited references';

-- Total seed set count:

-- eco2000_2010
-- [29111, 30240, 30976, 31945, 31788, 34773, 38498, 42820, 46437, 50262, 52460]