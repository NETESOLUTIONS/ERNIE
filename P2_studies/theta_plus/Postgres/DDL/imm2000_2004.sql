-- DDL script for base table:
-- Field - Immunology
-- Seed Years - 2000-2004

SET SEARCH_PATH = theta_plus;

-- create union of edge lists across 5 years
DROP TABLE IF EXISTS theta_plus.imm2000_2004_citing_cited;
CREATE TABLE theta_plus.imm2000_2004_citing_cited 
TABLESPACE theta_plus_tbs AS
    SELECT * FROM imm2000_citing_cited UNION
    SELECT * FROM imm2001_citing_cited UNION
    SELECT * FROM imm2002_citing_cited UNION
    SELECT * FROM imm2003_citing_cited UNION
    SELECT * FROM imm2004_citing_cited;
    
CREATE INDEX imm2000_2004_citing_cited_idx ON theta_plus.imm2000_2004_citing_cited(citing,cited) TABLESPACE index_tbs;

COMMENT ON TABLE theta_plus.2000_2004_citing_cited IS
  'Union of theta_plus.imm2000_citing_cited through theta_plus.imm2004_citing_cited tables';
COMMENT ON COLUMN theta_plus.imm2000_2004_cited.citing IS 'SCP of seed articles from 2000 to 2004 and their citing references';
COMMENT ON COLUMN theta_plus.imm2000_2004_cited.cited IS 'SCP of seed articles from 2000 to 2004 and their cited references';

--
-- Get all nodes in the 2000-2004 dataset
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

COMMENT ON TABLE theta_plus.imm2000_2004_nodes IS
  'All seed articles from 2000 to 2004 and their citing and cited references';
COMMENT ON COLUMN theta_plus.imm2000_2004_nodes.scp IS
  'SCPs of all seed articles from 2000 to 2004 and their citing and cited references';
  
--
-- Get all titles and abstracts for the 2000-2004 dataset
DROP TABLE IF EXISTS theta_plus.imm2000_2004_title_abstracts;
CREATE TABLE theta_plus.imm2000_2004_title_abstracts
TABLESPACE theta_plus_tbs AS
    SELECT tpin.scp, st.title, sa.abstract_text
    FROM theta_plus.imm2000_2004_nodes tpin
    INNER JOIN public.scopus_titles st 
            ON tpin.scp=st.scp
    INNER JOIN public.scopus_abstracts sa 
            ON tpin.scp=sa.scp
            AND sa.abstract_language='eng'
            AND st.language='English';
            
COMMENT ON TABLE theta_plus.imm2000_2004_title_abstracts IS
   'All titles and abstracts for seed articles from 2000 to 2004 and their citing and cited references'
COMMENT ON COLUMN theta_plus.imm2000_2004_title_abstracts.scp IS
  'SCPs of all seed articles from 2000 to 2004 and their citing and cited references';
COMMENT ON COLUMN theta_plus.imm2000_2004_title_abstracts.title IS
  'Titles of all seed articles from 2000 to 2004 and their citing and cited references';
COMMENT ON COLUMN theta_plus.imm2000_2004_title_abstracts.abstract_text IS
  'Abstracts of all seed articles from 2000 to 2004 and their citing and cited references';

-- total seed set count
-- imm2000_2004
-- [18395, 17114, 16550, 16291, 17323]