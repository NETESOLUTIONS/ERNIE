-- Immunology DDL for the year 2004

SET search_path = theta_plus;

-- Get all immunology articles published in the year 2004
DROP TABLE IF EXISTS theta_plus.imm2004;

CREATE TABLE theta_plus.imm2004
TABLESPACE theta_plus_tbs AS
    SELECT sp.scp 
    FROM public.scopus_publications sp
    INNER JOIN public.scopus_publication_groups spg
        ON sp.scp=spg.sgr
        AND spg.pub_year=2004
        AND sp.citation_type='ar'
        AND sp.citation_language='English'
        AND sp.pub_type='core'
    INNER JOIN public.scopus_classes sc
        ON sp.scp=sc.scp
        AND sc.class_code='2403';

CREATE INDEX IF NOT EXISTS imm2004_idx
ON theta_plus.imm2004(scp)
TABLESPACE index_tbs;

-- Get all the cited references of the immunology articles published in 2004
DROP TABLE IF EXISTS theta_plus.imm2004_cited;

CREATE TABLE theta_plus.imm2004_cited
TABLESPACE theta_plus_tbs AS
    SELECT tp.scp as citing, sr.ref_sgr AS cited
    FROM theta_plus.imm2004 tp
    INNER JOIN public.scopus_references sr 
        ON tp.scp = sr.scp;

CREATE INDEX IF NOT EXISTS imm2004_cited_idx
ON theta_plus.imm2004_cited(citing,cited)
TABLESPACE index_tbs;

-- Get all the citing references of the immunology articles published in 2004
DROP TABLE IF EXISTS theta_plus.imm2004_citing;

CREATE TABLE theta_plus.imm2004_citing 
TABLESPACE theta_plus_tbs AS
    SELECT sr.scp as citing, tp.scp AS cited 
    FROM theta_plus.imm2004 tp
    INNER JOIN public.scopus_references sr 
        ON tp.scp=sr.ref_sgr;

CREATE INDEX IF NOT EXISTS imm2004_citing_idx 
ON theta_plus.imm2004_citing(citing,cited)
TABLESPACE index_tbs;

-- Create table from the union of cited and citing references
DROP TABLE IF EXISTS theta_plus.imm2004_citing_cited;

CREATE TABLE theta_plus.imm2004_citing_cited
TABLESPACE theta_plus_tbs AS
    SELECT DISTINCT citing,cited from imm2004_cited 
    UNION
    SELECT DISTINCT citing,cited from imm2004_citing;
    
-- clean up Scopus data
DELETE FROM theta_plus.imm2004_citing_cited
WHERE citing=cited;

--remove all non-core publications by joining against
-- scopus publications and requiring type = core
-- and language = English
DROP TABLE IF EXISTS XX_imm2004;

ALTER TABLE theta_plus.imm2004_citing_cited
RENAME TO XX_imm2004;

CREATE TABLE theta_plus.imm2004_citing_cited AS

WITH cte AS(SELECT citing,cited FROM XX_imm2004
            INNER JOIN public.scopus_publications sp
                ON XX_imm2004.citing=sp.scp
                AND sp.citation_language='English'
                AND sp.pub_type='core')

SELECT citing,cited FROM cte
    INNER JOIN public.scopus_publications sp2
    ON cte.cited=sp2.scp
    AND sp2.citation_language='English'
    AND sp2.pub_type='core';

DROP TABLE XX_imm2004;

-- Get all nodes in the 2004 dataset
DROP TABLE IF EXISTS theta_plus.imm2004_nodes;

CREATE TABLE theta_plus.imm2004_nodes
TABLESPACE theta_plus_tbs AS
    SELECT distinct citing as scp
    FROM theta_plus.imm2004_citing_cited
    UNION
    SELECT distinct cited
    FROM theta_plus.imm2004_citing_cited;

CREATE INDEX IF NOT EXISTS imm2004_nodes_idx ON theta_plus.imm2004_nodes(scp);

-- Get all titles and abstracts
DROP TABLE IF EXISTS theta_plus.imm2004_title_abstracts;

CREATE TABLE theta_plus.imm2004_title_abstracts
TABLESPACE theta_plus_tbs AS
    SELECT tpin.scp,st.title,sa.abstract_text
    FROM theta_plus.imm2004_nodes tpin
    INNER JOIN public.scopus_titles st 
        ON tpin.scp=st.scp
    INNER JOIN public.scopus_abstracts sa 
        ON tpin.scp=sa.scp
        AND sa.abstract_language='eng'
        AND st.language='English';

/*
-- Merging with the citation counts table
DROP TABLE IF EXISTS theta_plus.imm2004_citation_counts;
CREATE TABLE theta_plus.imm2004_citation_counts
TABLESPACE theta_plus_tbs AS
SELECT ielu.scp, scc.citation_count, ielu.cluster_no
FROM theta_plus.imm2004_cluster_scp_list_unshuffled ielu
LEFT JOIN public.scopus_citation_counts scc
  ON ielu.scp = scc.scp;
*/


