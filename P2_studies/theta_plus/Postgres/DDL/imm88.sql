-- DDL script for base table:
-- Field - Immunology
-- Seed Year - 1988

SET search_path = theta_plus;

--

DROP TABLE IF EXISTS theta_plus.imm1988;
CREATE TABLE theta_plus.imm1988
TABLESPACE theta_plus_tbs AS
SELECT sp.scp FROM public.scopus_publications sp
INNER JOIN public.scopus_publication_groups spg
ON sp.scp=spg.sgr
AND spg.pub_year=1988
AND sp.citation_type='ar'
AND sp.citation_language='English'
AND sp.pub_type='core'
INNER JOIN public.scopus_classes sc
ON sp.scp=sc.scp
AND sc.class_code='2403';
CREATE INDEX imm1988_idx
ON theta_plus.imm1988(scp)
TABLESPACE index_tbs;

COMMENT ON TABLE theta_plus.imm1988 IS
  'Seed article set for the year 1988 based on the following criteria:
   ASJC Code = 2403 (Immunology)
   Publication/Citation Type = "ar" (article)
   Language = English
   Scopus Publication Type = "core"';

COMMENT ON COLUMN theta_plus.imm1988.scp IS 'SCP of seed articles for the year 1988';

--

DROP TABLE IF EXISTS theta_plus.imm1988_cited;
DROP TABLE IF EXISTS theta_plus.imm1988_cited;
CREATE TABLE theta_plus.imm1988_cited
TABLESPACE theta_plus_tbs AS
SELECT tp.scp as citing,sr.ref_sgr AS cited
FROM theta_plus.imm1988 tp
INNER JOIN public.scopus_references sr on tp.scp = sr.scp;
CREATE INDEX imm1988_cited_idx
ON theta_plus.imm1988_cited(citing,cited)
TABLESPACE index_tbs;

COMMENT ON TABLE theta_plus.imm1988_cited IS
  'Cited references of all seed articles from 1988
   Note: This set is not limited to the ASJC criteria (field: immunology)';

COMMENT ON COLUMN theta_plus.imm1988_cited.citing IS 'SCP of seed articles from 1988';
COMMENT ON COLUMN theta_plus.imm1988_cited.cited IS 'SCP of cited references of seed articles from 1988';

--

DROP TABLE IF EXISTS theta_plus.imm1988_citing;
CREATE TABLE theta_plus.imm1988_citing TABLESPACE theta_plus_tbs AS
SELECT sr.scp as citing,tp.scp as cited FROM theta_plus.imm1988 tp
INNER JOIN public.scopus_references sr on tp.scp=sr.ref_sgr;
CREATE INDEX imm1988_citing_idx ON theta_plus.imm1988_citing(citing,cited)
TABLESPACE index_tbs;

COMMENT ON TABLE theta_plus.imm1988_citing IS
  'Citing references of all seed articles from 1988
   Note: This set is not limited to the ASJC criteria (field: immunology)';

COMMENT ON COLUMN theta_plus.imm1988_cited.citing IS 'SCP of citing references of seed articles from 1988';
COMMENT ON COLUMN theta_plus.imm1988_cited.cited IS 'SCP of seed articles from 1988';

select count(1) from imm1988;
select count(1) from imm1988_cited;
select count(1) from imm1988_citing;

--

DROP TABLE IF EXISTS theta_plus.imm1988_citing_cited;
CREATE TABLE theta_plus.imm1988_citing_cited
TABLESPACE theta_plus_tbs AS
SELECT DISTINCT citing,cited from imm1988_cited UNION
SELECT DISTINCT citing,cited from imm1988_citing;
SELECT count(1) from imm1988_citing_cited;

-- clean up Scopus data
DELETE FROM theta_plus.imm1988_citing_cited
WHERE citing=cited;

--remove all non-core publications by joining against
-- scopus publications and requiring type = core
-- and language = English
DROP TABLE IF EXISTS XX;
ALTER TABLE theta_plus.imm1988_citing_cited
RENAME TO XX;

CREATE TABLE theta_plus.imm1988_citing_cited AS
WITH cte AS(SELECT citing,cited FROM XX
INNER JOIN public.scopus_publications sp
ON XX.citing=sp.scp
AND sp.citation_language='English'
AND sp.pub_type='core')
SELECT citing,cited FROM cte
INNER JOIN public.scopus_publications sp2
ON cte.cited=sp2.scp
AND sp2.citation_language='English'
AND sp2.pub_type='core';
DROP TABLE XX;

COMMENT ON TABLE theta_plus.imm1988_citing_cited IS
  'union of theta_plus.imm1988_citing and theta_plus.imm1988_cited tables';
COMMENT ON COLUMN theta_plus.imm1988_cited.citing IS 'SCP of seed articles from 1988 and their citing references';
COMMENT ON COLUMN theta_plus.imm1988_cited.cited IS 'SCP of seed articles from 1988 and their cited references';

--

DROP TABLE IF EXISTS theta_plus.imm1988_nodes;
CREATE TABLE theta_plus.imm1988_nodes
TABLESPACE theta_plus_tbs AS
SELECT distinct citing as scp
FROM theta_plus.imm1988_citing_cited
UNION
SELECT distinct cited
FROM theta_plus.imm1988_citing_cited;
CREATE INDEX imm1988_nodes_idx ON theta_plus.imm1988_nodes(scp);

COMMENT ON TABLE theta_plus.imm1988_nodes IS
  'All seed articles from 1988 and their citing and cited references';
COMMENT ON COLUMN theta_plus.imm1988_nodes.scp IS
  'SCPs of all seed articles from 1988 and their citing and cited references';

--

-- Merging with the citation counts table
DROP TABLE IF EXISTS theta_plus.imm1988_citation_counts;
CREATE TABLE theta_plus.imm1988_citation_counts
TABLESPACE theta_plus_tbs AS
SELECT cslu.scp, scc.citation_count, cslu.cluster_no
FROM theta_plus.imm1988_cluster_scp_list_unshuffled cslu
LEFT JOIN public.scopus_citation_counts scc
  ON cslu.scp = scc.scp;

COMMENT ON TABLE theta_plus.imm1988_citation_counts IS
  'All seed articles from 1988 and their Scopus citation counts and publish year';
COMMENT ON COLUMN theta_plus.imm1988_citation_counts.scp IS
  'SCPs of all seed articles from 1988 and their citing and cited references';
COMMENT ON COLUMN theta_plus.imm1988_citation_counts.citation_count IS
  'Scopus citation count of all seed articles from 1988 and their citing and cited references';
COMMENT ON COLUMN theta_plus.imm1988_citation_counts.cluster_no IS
  'MCL (unshuffled) cluster number of all seed articles from 1988 and their citing and cited references';
