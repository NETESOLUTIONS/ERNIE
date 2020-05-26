DROP TABLE IF EXISTS theta_plus.imm1995_testcase_asjc2403;
CREATE TABLE theta_plus.imm1995_testcase_asjc2403
TABLESPACE theta_plus_tbs AS
SELECT sp.scp FROM scopus_publications sp
INNER JOIN scopus_publication_groups spg
ON sp.scp=spg.sgr
AND spg.pub_year=1995
AND sp.citation_type='ar'
AND sp.citation_language='English'
INNER JOIN scopus_classes sc
ON sp.scp=sc.scp
AND sc.class_code='2403';
CREATE INDEX imm1995_testcase_asjc_idx ON theta_plus.imm1995_testcase_asjc2403(scp)
TABLESPACE index_tbs;

DROP TABLE IF EXISTS theta_plus.imm1995_testcase_cited;
CREATE TABLE theta_plus.imm1995_testcase_cited
TABLESPACE theta_plus_tbs AS
SELECT tp.scp as citing,sr.ref_sgr as cited from theta_plus.imm1995_testcase_asjc2403 tp
INNER JOIN scopus_references sr on tp.scp = sr.scp;
CREATE INDEX imm1995_testcase_cited_idx ON theta_plus.imm1995_testcase_cited(citing,cited)
TABLESPACE index_tbs;

DROP TABLE IF EXISTS theta_plus.imm1995_testcase_citing;
CREATE TABLE theta_plus.imm1995_testcase_citing TABLESPACE theta_plus_tbs AS
SELECT sr.scp as citing,tp.scp as cited FROM theta_plus.imm1995_testcase_asjc2403 tp
INNER JOIN scopus_references sr on tp.scp=sr.ref_sgr;
CREATE INDEX imm1995_testcase_citing_idx ON theta_plus.imm1995_testcase_citing(citing,cited)
TABLESPACE index_tbs;

select count(1) from imm1995_testcase_asjc2403;
select count(1) from imm1995_testcase_cited;
select count(1) from imm1995_testcase_citing;

DROP TABLE IF EXISTS theta_plus.imm1995_testcase_asjc2403_citing_cited;
CREATE TABLE theta_plus.imm1995_testcase_asjc2403_citing_cited
TABLESPACE theta_plus_tbs AS
SELECT DISTINCT citing,cited from imm1995_testcase_cited UNION
SELECT DISTINCT citing,cited from imm1995_testcase_citing;
SELECT count(1) from imm1995_testcase_asjc2403_citing_cited;

-- clean up Scopus data
DELETE FROM theta_plus.imm1995_testcase_asjc2403_citing_cited
WHERE citing=cited;

DROP TABLE IF EXISTS theta_plus.imm1995_nodes;
CREATE TABLE theta_plus.imm1995_nodes
TABLESPACE theta_plus_tbs AS
SELECT distinct citing as scp
FROM theta_plus.imm1995_testcase_asjc2403_citing_cited
UNION
SELECT distinct cited
FROM theta_plus.imm1995_testcase_asjc2403_citing_cited;

DROP TABLE IF EXISTS theta_plus.imm1995_title_abstracts;
CREATE TABLE theta_plus.imm1995_title_abstracts
TABLESPACE theta_plus_tbs AS
SELECT tpin.scp,st.title,sa.abstract_text
FROM theta_plus.imm1995_nodes tpin
INNER JOIN scopus_titles st ON tpin.scp=st.scp
INNER JOIN scopus_abstracts sa ON tpin.scp=sa.scp
AND sa.abstract_language='eng'
AND st.language='English';

select scp,title from theta_plus.imm1995_title_abstracts limit 5;
select count(1) from theta_plus.imm1995_title_abstracts;

