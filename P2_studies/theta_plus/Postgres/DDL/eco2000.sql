-- DDL script for base table:
-- Field - Ecology
-- Seed Year - 2000

SET search_path = theta_plus_ecology_ecology;

SELECT count(*)
FROM public.scopus_asjc_pubs
WHERE class_code ='1105'; -- Ecology, Evolution, Behavior and Systematics

SELECT count(*)
FROM public.scopus_asjc_pubs
WHERE class_code ='2302'; -- Ecological Modelling

SELECT count(*)
FROM public.scopus_asjc_pubs
WHERE class_code ='2303'; -- Ecology

--
-- Get all ecology articles published in the year 2000
DROP TABLE IF EXISTS theta_plus_ecology_ecology.eco2000;

CREATE TABLE theta_plus_ecology_ecology.eco2000
TABLESPACE theta_plus_ecology_tbs AS
SELECT sp.scp 
FROM public.scopus_publications sp
INNER JOIN public.scopus_publication_groups spg
    ON sp.scp=spg.sgr
    AND spg.pub_year=2000
    AND sp.citation_type='ar'
    AND sp.citation_language='English'
    AND sp.pub_type='core'
INNER JOIN public.scopus_classes sc
    ON sp.scp=sc.scp
    AND sc.class_code IN ('1105', '2302', '2303');
    
CREATE INDEX eco2000_idx
    ON theta_plus_ecology_ecology.eco2000(scp)
TABLESPACE index_tbs;

COMMENT ON TABLE theta_plus_ecology.eco2000 IS
  'Seed article set for the year 2000 based on the following criteria:
   ASJC Code = 1105, 2302, 2303 (Ecology)
   Publication/Citation Type = "ar" (article)
   Language = English
   Scopus Publication Type = "core"';

COMMENT ON COLUMN theta_plus_ecology.eco2000.scp IS 'SCP of seed articles for the year 2000';

--
-- Get all the cited references of the ecology articles published in 2000
DROP TABLE IF EXISTS theta_plus_ecology_ecology.eco2000_cited;

CREATE TABLE theta_plus_ecology_ecology.eco2000_cited
TABLESPACE theta_plus_ecology_tbs AS
SELECT eco.scp AS citing,sr.ref_sgr AS cited
FROM theta_plus_ecology_ecology.eco2000 eco
INNER JOIN public.scopus_references sr 
    ON eco.scp = sr.scp;

CREATE INDEX eco2000_cited_idx
    ON theta_plus_ecology_ecology.eco2000_cited(citing,cited)
TABLESPACE index_tbs;

COMMENT ON TABLE theta_plus_ecology.eco2000_cited IS
  'Cited references of all seed articles from 2000
   Note: This set is not limited to the ASJC criteria (field: ecounology)';

COMMENT ON COLUMN theta_plus_ecology.eco2000_cited.citing IS 'SCP of seed articles from 2000';
COMMENT ON COLUMN theta_plus_ecology.eco2000_cited.cited IS 'SCP of cited references of seed articles from 2000';

--
-- Get all the citing references of the ecology articles published in 2000
DROP TABLE IF EXISTS theta_plus_ecology_ecology.eco2000_citing;

CREATE TABLE theta_plus_ecology_ecology.eco2000_citing 
TABLESPACE theta_plus_ecology_tbs AS
SELECT sr.scp AS citing,eco.scp AS cited 
FROM theta_plus_ecology_ecology.eco2000 eco
INNER JOIN public.scopus_references sr 
    ON eco.scp=sr.ref_sgr;

CREATE INDEX eco2000_citing_idx 
ON theta_plus_ecology_ecology.eco2000_citing(citing,cited)
TABLESPACE index_tbs;

COMMENT ON TABLE theta_plus_ecology.eco2000_citing IS
  'Citing references of all seed articles from 2000
   Note: This set is not limited to the ASJC criteria (field: ecounology)';

COMMENT ON COLUMN theta_plus_ecology.eco2000_cited.citing IS 'SCP of citing references of seed articles from 2000';
COMMENT ON COLUMN theta_plus_ecology.eco2000_cited.cited IS 'SCP of seed articles from 2000';

--
-- Create table from the union of cited and citing references
DROP TABLE IF EXISTS theta_plus_ecology_ecology.eco2000_citing_cited;

CREATE TABLE theta_plus_ecology_ecology.eco2000_citing_cited
TABLESPACE theta_plus_ecology_tbs AS
SELECT DISTINCT citing,cited from theta_plus_ecology_ecology.eco2000_cited 
UNION
SELECT DISTINCT citing,cited from theta_plus_ecology_ecology.eco2000_citing;


-- clean up Scopus data
DELETE FROM theta_plus_ecology_ecology.eco2000_citing_cited
WHERE citing=cited;

--remove all non-core publications by joining against
-- scopus publications and requiring type = core
-- and language = English
DROP TABLE IF EXISTS XX_eco2000;
ALTER TABLE theta_plus_ecology_ecology.eco2000_citing_cited
RENAME TO XX_eco2000;

CREATE TABLE theta_plus_ecology_ecology.eco2000_citing_cited AS
WITH cte AS(SELECT citing,cited FROM XX_eco2000
INNER JOIN public.scopus_publications sp
ON XX_eco2000.citing=sp.scp
AND sp.citation_language='English'
AND sp.pub_type='core')
SELECT citing,cited FROM cte
INNER JOIN public.scopus_publications sp2
ON cte.cited=sp2.scp
AND sp2.citation_language='English'
AND sp2.pub_type='core';
DROP TABLE XX_eco2000;

COMMENT ON TABLE theta_plus_ecology.eco2000_citing_cited IS
  'union of theta_plus_ecology.eco2000_citing and theta_plus_ecology.eco2000_cited tables';
COMMENT ON COLUMN theta_plus_ecology.eco2000_cited.citing IS 'SCP of seed articles from 2000 and their citing references';
COMMENT ON COLUMN theta_plus_ecology.eco2000_cited.cited IS 'SCP of seed articles from 2000 and their cited references';

--
-- Get all nodes in the 2000 dataset
DROP TABLE IF EXISTS theta_plus_ecology_ecology.eco2000_nodes;

CREATE TABLE theta_plus_ecology_ecology.eco2000_nodes
TABLESPACE theta_plus_ecology_tbs AS
SELECT DISTINCT citing AS scp
FROM theta_plus_ecology_ecology.eco2000_citing_cited
UNION
SELECT DISTINCT cited
FROM theta_plus_ecology_ecology.eco2000_citing_cited;

CREATE INDEX eco2000_nodes_idx 
    ON theta_plus_ecology_ecology.eco2000_nodes(scp);

COMMENT ON TABLE theta_plus_ecology.eco2000_nodes IS
  'All seed articles from 2000 and their citing and cited references';
COMMENT ON COLUMN theta_plus_ecology.eco2000_nodes.scp IS
  'SCPs of all seed articles from 2000 and their citing and cited references';