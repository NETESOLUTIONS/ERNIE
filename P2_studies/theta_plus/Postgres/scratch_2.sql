CREATE TABLE chackoge.test_1985_cc_pairs
TABLESPACE sb_plus_tbs AS
WITH cte3 AS(
    WITH cte2 AS (
        -- get scps of type 'ar' and pub_year = 1985
        WITH cte1 AS(SELECT scp FROM public.scopus_publications sp
        INNER JOIN public.scopus_publication_groups spg
        ON sp.scp=spg.sgr
        AND spg.pub_year=1985 AND sp.citation_type='ar')
    -- restrict to scps with at least 5 references
    SELECT cte1.scp,count(sr.ref_sgr) FROM cte1
    INNER JOIN scopus_references sr
    ON cte1.scp=sr.scp group by cte1.scp
    HAVING count(ref_sgr) >=5)
-- get ref-sgrs for scps from cte2
SELECT cte2.scp,sr2.ref_sgr
FROM cte2 INNER JOIN scopus_references sr2
ON cte2.scp=sr2.scp)
-- finally fish out left-right ordered co-cited pairs
-- grouped by scp
SELECT f1.scp,f1.ref_sgr AS cited_1,f2.ref_sgr AS cited_2
  FROM cte3 f1
  JOIN cte3 f2 ON f1.scp = f2.scp AND f1.ref_sgr < f2.ref_sgr;

CREATE INDEX test_1985_cc_pairs_idx on chackoge.test_1985_cc_pairs(cited_1,cited_2) TABLESPACE index_tbs;

CREATE TABLE chackoge.test_1985_cc_pairs_unique
TABLESPACE sb_plus_tbs
AS SELECT DISTINCT cited_1,cited_2
FROM chackoge.test_1985_cc_pairs;

SELECT count(1) from chackoge.test_1985_cc_pairs_unique;

CREATE TABLE chackoge.test_1985_allconditions
-- 1985, ar, 5 references, and indexed
TABLESPACE sb_plus_tbs AS
WITH cte3 AS(
    WITH cte2 AS (
        WITH cte1 AS(
        -- get scps of type 'ar' and pub_year = 1985
        SELECT scp FROM public.scopus_publications sp
        INNER JOIN public.scopus_publication_groups spg
        ON sp.scp=spg.sgr
        AND spg.pub_year=1985 AND sp.citation_type='ar')
    -- restrict to scps with at least 5 references
    SELECT cte1.scp,count(sr.ref_sgr) FROM cte1
    INNER JOIN scopus_references sr
    ON cte1.scp=sr.scp group by cte1.scp
    HAVING count(ref_sgr) >=5)
-- get ref-sgrs for scps from cte2
SELECT cte2.scp,sr2.ref_sgr
FROM cte2 INNER JOIN scopus_references sr2
ON cte2.scp=sr2.scp) SELECT cte3.scp,cte3.ref_sgr from cte3
INNER JOIN scopus_publications sp3
ON cte3.ref_sgr=sp3.scp;

select count (distinct scp) from test_1985_allconditions;

create index test_1985_allconditions_idx on chackoge.test_1985_allconditions(scp,ref_sgr) tablespace index_tbs;

CREATE TABLE chackoge.est_1985_allconditions_cited_pairs
TABLESPACE sb_plus_tbs AS
SELECT f1.scp,f1.ref_sgr AS cited_1,f2.ref_sgr AS cited_2
  FROM test_1985_allconditions f1
  JOIN test_1985_allconditions f2 ON f1.scp = f2.scp AND f1.ref_sgr < f2.ref_sgr;

SELECT count(1) from est_1985_allconditions_cited_pairs: 75425709
SELECT count(1) from (select distinct cited_1,cited_2 from est_1985_allconditions_cited_pairs)c;

select * from scopus_publications where scp=2265756;
select * from scopus_titles where scp=2265756;
select ref_sgr from scopus_references where scp=2265756;

-- May 18, 2020
-- create table of direct citations between
-- co-cited nodes (all) in the t_o_p collection
DROP TABLE IF EXISTS theta_plus.t_o_p_nodes_dc;
CREATE TABLE theta_plus.t_o_p_nodes_dc TABLESPACE theta_plus_tbs AS
WITH ppe AS(
    WITH CTE AS (
    SELECT distinct cited_1 as scp from t_o_p_final_table
    UNION
    SELECT distinct cited_2 FROM t_o_p_final_table)
SELECT sr.scp,sr.ref_sgr from public.scopus_references sr
--restrict pubs to set of scps from t_o_p_final_table
WHERE sr.scp in (select scp from cte))
SELECT * FROM ppe
-- restrict refs to set of scps from t_o_p_final_table
WHERE ref_sgr in (
    SELECT distinct cited_1 as scp from t_o_p_final_table
    UNION SELECT distinct cited_2 FROM t_o_p_final_table);
CREATE INDEX t_o_p_nodes_dc_idx ON theta_plus.t_o_p_nodes_dc(scp,ref_sgr)
TABLESPACE index_tbs;

select count(1) from (select distinct scp from theta_plus.t_o_p_nodes_dc union select distinct ref_sgr from theta_plus.t_o_p_nodes_dc)c

select count(1) from theta_plus.t_o_p_nodes_dc

select abstract_text from scopus_abstracts where scp=75149149112



select scp from scopus_references where ref_sgr=75149149112

select distinct scp from scopus_references where scp in(
select distinct scp from scopus_references where ref_sgr=75149149112
)