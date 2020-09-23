-- DDL script for base table:
-- Field - Immunology
-- Seed Year - 2002

SET search_path = theta_plus;

-- 
-- Get all immunology articles published in the year 2002
DROP TABLE IF EXISTS theta_plus.imm2002;

CREATE TABLE theta_plus.imm2002
TABLESPACE theta_plus_tbs AS
    SELECT sp.scp 
    FROM public.scopus_publications sp
    INNER JOIN public.scopus_publication_groups spg
        ON sp.scp=spg.sgr
        AND spg.pub_year=2002
        AND sp.citation_type='ar'
        AND sp.citation_language='English'
        AND sp.pub_type='core'
    INNER JOIN public.scopus_classes sc
        ON sp.scp=sc.scp
        AND sc.class_code='2403';

CREATE INDEX IF NOT EXISTS imm2002_idx
ON theta_plus.imm2002(scp)
TABLESPACE index_tbs;

COMMENT ON TABLE theta_plus.imm2002 IS
  'Seed article set for the year 2002 based on the following criteria:
   ASJC Code = 2403 (Immunology)
   Publication/Citation Type = "ar" (article)
   Language = English
   Scopus Publication Type = "core"';

COMMENT ON COLUMN theta_plus.imm2002.scp IS 'SCP of seed articles for the year 2002';

--
-- Get all the cited references of the immunology articles published in 2002
DROP TABLE IF EXISTS theta_plus.imm2002_cited;

CREATE TABLE theta_plus.imm2002_cited
TABLESPACE theta_plus_tbs AS
    SELECT tp.scp as citing, sr.ref_sgr AS cited
    FROM theta_plus.imm2002 tp
    INNER JOIN public.scopus_references sr 
        ON tp.scp = sr.scp;

CREATE INDEX IF NOT EXISTS imm2002_cited_idx
ON theta_plus.imm2002_cited(citing,cited)
TABLESPACE index_tbs;

COMMENT ON TABLE theta_plus.imm2002_cited IS
  'Cited references of all seed articles from 2002
   Note: This set is not limited to the ASJC criteria (field: immunology)';

COMMENT ON COLUMN theta_plus.imm2002_cited.citing IS 'SCP of seed articles from 2002';
COMMENT ON COLUMN theta_plus.imm2002_cited.cited IS 'SCP of cited references of seed articles from 2002';

--
-- Get all the citing references of the immunology articles published in 2002
DROP TABLE IF EXISTS theta_plus.imm2002_citing;

CREATE TABLE theta_plus.imm2002_citing 
TABLESPACE theta_plus_tbs AS
    SELECT sr.scp as citing, tp.scp AS cited 
    FROM theta_plus.imm2002 tp
    INNER JOIN public.scopus_references sr 
        ON tp.scp=sr.ref_sgr;

CREATE INDEX IF NOT EXISTS imm2002_citing_idx 
ON theta_plus.imm2002_citing(citing,cited)
TABLESPACE index_tbs;

COMMENT ON TABLE theta_plus.imm2002_citing IS
  'Citing references of all seed articles from 2002
   Note: This set is not limited to the ASJC criteria (field: immunology)';

COMMENT ON COLUMN theta_plus.imm2002_cited.citing IS 'SCP of citing references of seed articles from 2002';
COMMENT ON COLUMN theta_plus.imm2002_cited.cited IS 'SCP of seed articles from 2002';

--
-- Create table from the union of cited and citing references
DROP TABLE IF EXISTS theta_plus.imm2002_citing_cited;

CREATE TABLE theta_plus.imm2002_citing_cited
TABLESPACE theta_plus_tbs AS
    SELECT DISTINCT citing,cited from imm2002_cited 
    UNION
    SELECT DISTINCT citing,cited from imm2002_citing;
    
-- clean up Scopus data
DELETE FROM theta_plus.imm2002_citing_cited
WHERE citing=cited;

--remove all non-core publications by joining against
-- scopus publications and requiring type = core
-- and language = English
DROP TABLE IF EXISTS XX_imm2002;

ALTER TABLE theta_plus.imm2002_citing_cited
RENAME TO XX_imm2002;

CREATE TABLE theta_plus.imm2002_citing_cited AS

WITH cte AS(SELECT citing,cited FROM XX_imm2002
            INNER JOIN public.scopus_publications sp
                ON XX_imm2002.citing=sp.scp
                AND sp.citation_language='English'
                AND sp.pub_type='core')

SELECT citing,cited FROM cte
    INNER JOIN public.scopus_publications sp2
    ON cte.cited=sp2.scp
    AND sp2.citation_language='English'
    AND sp2.pub_type='core';

DROP TABLE XX_imm2002;

COMMENT ON TABLE theta_plus.imm2002_citing_cited IS
  'union of theta_plus.imm2002_citing and theta_plus.imm2002_cited tables';
COMMENT ON COLUMN theta_plus.imm2002_cited.citing IS 'SCP of seed articles from 2002 and their citing references';
COMMENT ON COLUMN theta_plus.imm2002_cited.cited IS 'SCP of seed articles from 2002 and their cited references';

--
-- Get all nodes in the 2002 dataset
DROP TABLE IF EXISTS theta_plus.imm2002_nodes;

CREATE TABLE theta_plus.imm2002_nodes
TABLESPACE theta_plus_tbs AS
    SELECT distinct citing as scp
    FROM theta_plus.imm2002_citing_cited
    UNION
    SELECT distinct cited
    FROM theta_plus.imm2002_citing_cited;

CREATE INDEX IF NOT EXISTS imm2002_nodes_idx ON theta_plus.imm2002_nodes(scp);

COMMENT ON TABLE theta_plus.imm2002_nodes IS
  'All seed articles from 2002 and their citing and cited references';
COMMENT ON COLUMN theta_plus.imm2002_nodes.scp IS
  'SCPs of all seed articles from 2002 and their citing and cited references';