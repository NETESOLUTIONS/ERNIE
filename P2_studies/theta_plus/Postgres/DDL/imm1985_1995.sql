-- DDL script for base table:
-- Field - Immunology
-- Seed Years - 1985-1995

SET SEARCH_PATH = theta_plus;
--
-- create union of edge lists across 11 years
DROP TABLE IF EXISTS theta_plus.imm1985_1995_citing_cited;
CREATE TABLE theta_plus.imm1985_1995_citing_cited TABLESPACE theta_plus_tbs AS
SELECT * FROM imm1985_citing_cited UNION
SELECT * FROM imm1986_citing_cited UNION
SELECT * FROM imm1987_citing_cited UNION
SELECT * FROM imm1988_citing_cited UNION
SELECT * FROM imm1989_citing_cited UNION
SELECT * FROM imm1990_citing_cited UNION
SELECT * FROM imm1991_citing_cited UNION
SELECT * FROM imm1992_citing_cited UNION
SELECT * FROM imm1993_citing_cited UNION
SELECT * FROM imm1994_citing_cited UNION
SELECT * FROM imm1995_citing_cited;

CREATE INDEX imm1985_1995_citing_cited_idx ON theta_plus.imm1985_1995_citing_cited(citing,cited) TABLESPACE index_tbs;

COMMENT ON TABLE theta_plus.imm1985_1995_citing_cited IS
  'Union of theta_plus.imm1985_citing_cited through theta_plus.imm1995_citing_cited tables';
COMMENT ON COLUMN theta_plus.imm1985_1995_cited.citing IS 'SCP of seed articles from 1985 to 1995 and their citing references';
COMMENT ON COLUMN theta_plus.imm1985_1995_cited.cited IS 'SCP of seed articles from 1985 to 1995 and their cited references';

--
-- Get all nodes in the 1985-1995 dataset
DROP TABLE IF EXISTS theta_plus.imm1985_1995_nodes;
CREATE TABLE theta_plus.imm1985_1995_nodes
TABLESPACE theta_plus_tbs AS
SELECT distinct citing as scp
FROM theta_plus.imm1985_1995_citing_cited
UNION
SELECT distinct cited
FROM theta_plus.imm1985_1995_citing_cited;
CREATE INDEX imm1985_1995_nodes_idx ON theta_plus.imm1985_1995_nodes(scp);

COMMENT ON TABLE theta_plus.imm1985_1995_nodes IS
  'All seed articles from 1985 to 1995 and their citing and cited references';
COMMENT ON COLUMN theta_plus.imm1985_1995_nodes.scp IS
  'SCPs of all seed articles from 1985 to 1995 and their citing and cited references';
  
--
-- Get all titles and abstracts for the 1985-1995 dataset
DROP TABLE IF EXISTS theta_plus.imm1985_1995_title_abstracts;
CREATE TABLE theta_plus.imm1985_1995_title_abstracts
TABLESPACE theta_plus_tbs AS
SELECT tpin.scp,st.title,sa.abstract_text
FROM theta_plus.imm1985_1995_nodes tpin
INNER JOIN public.scopus_titles st ON tpin.scp=st.scp
INNER JOIN public.scopus_abstracts sa ON tpin.scp=sa.scp
AND sa.abstract_language='eng'
AND st.language='English';
CREATE INDEX imm1985_1995_title_abstracts_idx ON theta_plus.imm1985_1995_title_abstracts(scp);

COMMENT ON TABLE theta_plus.imm1985_1995_title_abstracts IS
   'All titles and abstracts for seed articles from 1985 to 1995 and their citing and cited references'
COMMENT ON COLUMN theta_plus.imm1985_1995_title_abstracts.scp IS
  'SCPs of all seed articles from 1985 to 1995 and their citing and cited references';
COMMENT ON COLUMN theta_plus.imm1985_1995_title_abstracts.title IS
  'Titles of all seed articles from 1985 to 1995 and their citing and cited references';
COMMENT ON COLUMN theta_plus.imm1985_1995_title_abstracts.abstract_text IS
  'Abstracts of all seed articles from 1985 to 1995 and their citing and cited references';
  
-- total seed set count
-- imm1985_1995
-- [11220, 11206, 11534, 12302, 13128, 13207, 13624, 14372, 14654, 15303, 16465]