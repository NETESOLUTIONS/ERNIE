-- construct enriched data by including cited references of
-- citing papers not only edges to base dataset

-- first make sure that the imm90.sql script was run successfully.

-- DROP TABLE IF EXISTS theta_plus.imm1990;
-- CREATE TABLE theta_plus.imm1990
-- TABLESPACE theta_plus_tbs AS
-- SELECT sp.scp FROM public.scopus_publications sp
-- INNER JOIN public.scopus_publication_groups spg
-- ON sp.scp=spg.sgr
-- AND spg.pub_year=1990
-- AND sp.citation_type='ar'
-- AND sp.citation_language='English'
-- AND sp.pub_type='core'
-- INNER JOIN scopus_classes sc
-- ON sp.scp=sc.scp
-- AND sc.class_code='2403';
-- CREATE INDEX imm1990_idx
-- ON theta_plus.imm1990(scp)
-- TABLESPACE index_tbs;
--
-- DROP TABLE IF EXISTS theta_plus.imm1990_testcase_cited;
-- DROP TABLE IF EXISTS theta_plus.imm1990_cited;
-- CREATE TABLE theta_plus.imm1990_cited
-- TABLESPACE theta_plus_tbs AS
-- SELECT tp.scp as citing,sr.ref_sgr AS cited
-- FROM theta_plus.imm1990 tp
-- INNER JOIN scopus_references sr on tp.scp = sr.scp;
-- CREATE INDEX imm1990_cited_idx
-- ON theta_plus.imm1990_cited(citing,cited)
-- TABLESPACE index_tbs;
--
-- DROP TABLE IF EXISTS theta_plus.imm1990_citing;
-- CREATE TABLE theta_plus.imm1990_citing TABLESPACE theta_plus_tbs AS
-- SELECT sr.scp as citing,tp.scp as cited FROM theta_plus.imm1990 tp
-- INNER JOIN scopus_references sr on tp.scp=sr.ref_sgr;
-- CREATE INDEX imm1990_citing_idx ON theta_plus.imm1990_citing(citing,cited)
-- TABLESPACE index_tbs;

-- new table compared to imm90.sql
DROP TABLE IF EXISTS theta_plus.imm1990_citing_allrefs;
CREATE TABLE theta_plus.imm1990_citing_allrefs TABLESPACE theta_plus_tbs AS
SELECT tpic.citing, sr.ref_sgr as cited FROM theta_plus.imm1990_citing tpic
INNER JOIN public.scopus_references sr
ON tpic.citing=sr.scp;
CREATE INDEX imm1990_citing_allrefs_idx ON theta_plus.imm1990_citing_allrefs(citing,cited);

-- select count(1) from imm1990;
-- select count(1) from imm1990_cited;
-- select count(1) from imm1990_citing;

DROP TABLE IF EXISTS theta_plus.imm1990_citing_cited_enriched;
CREATE TABLE theta_plus.imm1990_citing_cited_enriched
TABLESPACE theta_plus_tbs AS
SELECT DISTINCT citing,cited from imm1990_cited UNION
SELECT DISTINCT citing,cited from imm1990_citing UNION
SELECT DISTINCT citing,cited from imm1990_citing_allrefs;
SELECT count(1) from imm1990_citing_cited;

-- clean up Scopus data
DELETE FROM theta_plus.imm1990_citing_cited_enriched
WHERE citing=cited;

--remove all non-core publications by joining against
-- scopus publications and requiring type = core
-- and language = English
DROP TABLE IF EXISTS XX;
ALTER TABLE theta_plus.imm1990_citing_cited_enriched
RENAME TO XX;

CREATE TABLE theta_plus.imm1990_citing_cited_enriched AS
WITH cte AS(SELECT citing,cited FROM XX
INNER JOIN scopus_publications sp
ON XX.citing=sp.scp
AND sp.citation_language='English'
AND sp.pub_type='core')
SELECT citing,cited FROM cte
INNER JOIN scopus_publications sp2
ON cte.cited=sp2.scp
AND sp2.citation_language='English'
AND sp2.pub_type='core';
DROP TABLE XX;

DROP TABLE IF EXISTS theta_plus.imm1990_nodes_enriched;
CREATE TABLE theta_plus.imm1990_nodes_enriched
TABLESPACE theta_plus_tbs AS
SELECT distinct citing as scp
FROM theta_plus.imm1990_citing_cited_enriched
UNION
SELECT distinct cited
FROM theta_plus.imm1990_citing_cited_enriched;
CREATE INDEX imm1990_nodes_idx ON theta_plus.imm1990_nodes_enriched(scp);

DROP TABLE IF EXISTS theta_plus.imm1990_title_abstracts_enriched;
CREATE TABLE theta_plus.imm1990_title_abstracts_enriched
TABLESPACE theta_plus_tbs AS
SELECT tpin.scp,st.title,sa.abstract_text
FROM theta_plus.imm1990_nodes tpin
INNER JOIN scopus_titles st ON tpin.scp=st.scp
INNER JOIN scopus_abstracts sa ON tpin.scp=sa.scp
AND sa.abstract_language='eng'
AND st.language='English';

select scp,title from theta_plus.imm1990_title_abstracts limit 5;
select count(1) from theta_plus.imm1990_title_abstracts;

-- commenting out the section below July 9, 2020 George Chacko
-- citation data to be replaced with Wenxi Zhao's Neo4j calculations

-- Merging with the citation counts table
-- DROP TABLE IF EXISTS theta_plus.imm1990_citation_counts_enriched;
-- CREATE TABLE theta_plus.imm1990_citation_counts_enriched
-- TABLESPACE theta_plus_tbs AS
-- SELECT ielu.scp, scc.citation_count, ielu.cluster_no
-- FROM theta_plus.imm1990_edge_list_unshuffled ielu
-- LEFT JOIN public.scopus_citation_counts scc
-- ON ielu.scp = scc.scp;

