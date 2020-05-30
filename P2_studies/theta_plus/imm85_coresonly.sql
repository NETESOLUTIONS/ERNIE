-- Create base list of scps representing immunology (ASJC=2403)
-- articles published in English in 1985 of type *core*

DROP TABLE IF EXISTS theta_plus.imm1985_testcase_asjc2403_coresonly;
CREATE TABLE theta_plus.imm1985_testcase_asjc2403_coresonly
TABLESPACE theta_plus_tbs AS
SELECT sp.scp FROM scopus_publications sp
INNER JOIN scopus_publication_groups spg
ON sp.scp=spg.sgr
AND spg.pub_year=1985
AND sp.citation_type='ar'
AND sp.citation_language='English'
AND sp.pub_type='core'
INNER JOIN scopus_classes sc
ON sp.scp=sc.scp
AND sc.class_code='2403';
CREATE INDEX imm1985_testcase_asjc_coresonly_idx
ON theta_plus.imm1985_testcase_asjc2403_coresonly(scp)
TABLESPACE index_tbs;

-- Get publications cited by the base list
DROP TABLE IF EXISTS theta_plus.imm1985_testcase_cited_coresonly;
CREATE TABLE theta_plus.imm1985_testcase_cited_coresonly
TABLESPACE theta_plus_tbs AS
SELECT tp.scp as citing,sr.ref_sgr AS cited
FROM theta_plus.imm1985_testcase_asjc2403_coresonly tp
INNER JOIN scopus_references sr on tp.scp = sr.scp;
CREATE INDEX imm1985_testcase_cited__coresonly_idx
ON theta_plus.imm1985_testcase_cited_coresonly(citing,cited)
TABLESPACE index_tbs;

-- Get publications that cite the base list
DROP TABLE IF EXISTS theta_plus.imm1985_testcase_citing_coresonly;
CREATE TABLE theta_plus.imm1985_testcase_citing_coresonly TABLESPACE theta_plus_tbs AS
SELECT sr.scp as citing,tp.scp as cited
FROM theta_plus.imm1985_testcase_asjc2403_coresonly tp
INNER JOIN scopus_references sr on tp.scp=sr.ref_sgr;
CREATE INDEX imm1985_testcase_citing__coresonly_idx
ON theta_plus.imm1985_testcase_citing_coresonly(citing,cited)
TABLESPACE index_tbs;

-- combine citing and cited data
DROP TABLE IF EXISTS theta_plus.imm1985_testcase_asjc2403_citing_cited_coresonly;
CREATE TABLE theta_plus.imm1985_testcase_asjc2403_citing_cited_coresonly
TABLESPACE theta_plus_tbs AS
SELECT DISTINCT citing,cited from imm1985_testcase_cited_coresonly UNION
SELECT DISTINCT citing,cited from imm1985_testcase_citing_coresonly;
CREATE INDEX imm1985_testcase_asjc2403_citing_cited_coresonly_idx
ON theta_plus.imm1985_testcase_asjc2403_citing_cited_coresonly(citing,cited);

-- clean up combined table of self-citations
DELETE FROM theta_plus.imm1985_testcase_asjc2403_citing_cited_coresonly
WHERE citing=cited;

-- Remove all dummies from having fished out citing and cited
DROP TABLE IF EXISTS theta_plus.tpitacc_1985_nodummies;
CREATE TABLE theta_plus.tpitacc_1985_nodummies
TABLESPACE theta_plus_tbs AS
WITH cte AS(
SELECT tpitaccc.citing,tpitaccc.cited
FROM theta_plus.imm1985_testcase_asjc2403_citing_cited_coresonly tpitaccc
INNER JOIN scopus_publications sp
ON tpitaccc.citing=sp.scp
AND sp.pub_type='core')
SELECT cte.citing,cte.cited
FROM cte
INNER JOIN scopus_publications sp2
ON cte.cited=sp2.scp
AND sp2.pub_type='core';

select count(1) from theta_plus.tpitacc_1985_nodummies;
select count(1) from theta_plus.imm1985_testcase_asjc2403_citing_cited_coresonly;

DROP TABLE theta_plus.imm1985_testcase_asjc2403_citing_cited_coresonly;
ALTER TABLE theta_plus.tpitacc_1985_nodummies
RENAME TO imm1985_testcase_asjc2403_citing_cited_coresonly;
select count(1) from theta_plus.imm1985_testcase_asjc2403_citing_cited_coresonly;

DROP TABLE IF EXISTS theta_plus.imm1985_nodes_coresonly;
CREATE TABLE theta_plus.imm1985_nodes_coresonly
TABLESPACE theta_plus_tbs AS
SELECT distinct citing as scp
FROM theta_plus.imm1985_testcase_asjc2403_citing_cited_coresonly
UNION
SELECT distinct cited
FROM theta_plus.imm1985_testcase_asjc2403_citing_cited_coresonly;

DROP TABLE IF EXISTS theta_plus.imm1985_title_abstracts_coresonly;
CREATE TABLE theta_plus.imm1985_title_abstracts_coresonly
TABLESPACE theta_plus_tbs AS
SELECT tpin.scp,st.title,sa.abstract_text
FROM theta_plus.imm1985_nodes_coresonly tpin
INNER JOIN scopus_titles st ON tpin.scp=st.scp
INNER JOIN scopus_abstracts sa ON tpin.scp=sa.scp
AND sa.abstract_language='eng'
AND st.language='English';




