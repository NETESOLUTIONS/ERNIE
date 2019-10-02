-- script to match minor ASJC codes within Computer Science
-- to Graclus clusters constructed by Sitaram Devarakonda.
-- Only pubs are accounted for in this script see 'AND publication IS TRUE'
-- George Chacko 10/2/2019

-- create base table of counts
DROP TABLE IF EXISTS chackoge.dblp_graclus_2000_2015_counts;
DROP TABLE IF EXISTS public.dblp_graclus_2000_2015_counts;
CREATE TABLE public.dblp_graclus_2000_2015_counts AS
SELECT cluster_20,count(source_id)
FROM dblp_graclus
WHERE pub_year >=2000 AND pub_year <=2015
AND publication IS TRUE
group by cluster_20;

-- add columns
ALTER TABLE dblp_graclus_2000_2015_counts
ADD COLUMN ai_1702 int,
ADD COLUMN ct_m_1703 int,
ADD COLUMN cg_cad_1704 int,
ADD COLUMN cn_c_1705 int,
ADD COLUMN csa_1706 int,
ADD COLUMN cv_pr_1707 int,
ADD COLUMN h_a_1708 int,
ADD COLUMN hci_1709 int,
ADD COLUMN is_1710 int,
ADD COLUMN sp_1711 int,
ADD COLUMN sw_1712 int,
ADD COLUMN misc_1701 int,
ADD COLUMN all_1700 int;

-- begin loop of sorts

-- all_1700 
DROP TABLE IF EXISTS xxx;
CREATE TEMP TABLE  xxx 
AS WITH cte AS (
SELECT DISTINCT a.cluster_20,a.source_id 
FROM dblp_graclus a INNER JOIN scopus_classes b
ON a.source_id=b.scp where pub_year >=2000 AND pub_year <=2015 
AND publication is TRUE 
AND class_code='1700')
SELECT cluster_20,count(source_id) 
FROM cte GROUP BY cluster_20;

UPDATE public.dblp_graclus_2000_2015_counts
SET all_1700 = xxx.count
FROM xxx
WHERE dblp_graclus_2000_2015_counts.cluster_20 = xxx.cluster_20;

-- misc_1701
DROP TABLE IF EXISTS xxx;
CREATE TEMP TABLE xxx
AS WITH cte AS (
SELECT DISTINCT a.cluster_20,a.source_id
FROM dblp_graclus a INNER JOIN scopus_classes b
ON a.source_id=b.scp where pub_year >=2000 AND pub_year <=2015 
AND publication is TRUE
and class_code='1701')
SELECT cluster_20,count(source_id)
FROM cte GROUP BY cluster_20;

UPDATE public.dblp_graclus_2000_2015_counts
SET misc_1701 = xxx.count
FROM xxx
WHERE dblp_graclus_2000_2015_counts.cluster_20 = xxx.cluster_20;

--ai_1702
DROP TABLE IF EXISTS xxx;
CREATE TEMP TABLE xxx
AS WITH cte AS (
SELECT DISTINCT a.cluster_20,a.source_id
FROM dblp_graclus a INNER JOIN scopus_classes b
ON a.source_id=b.scp where pub_year >=2000 AND pub_year <=2015 
AND publication is TRUE
and class_code='1702')
SELECT cluster_20,count(source_id)
FROM cte GROUP BY cluster_20;

UPDATE public.dblp_graclus_2000_2015_counts
SET ai_1702 = xxx.count
FROM xxx
WHERE dblp_graclus_2000_2015_counts.cluster_20 = xxx.cluster_20;

-- ctm_1703
DROP TABLE IF EXISTS xxx;
CREATE TEMP TABLE xxx
AS WITH cte AS (
SELECT DISTINCT a.cluster_20,a.source_id
FROM dblp_graclus a INNER JOIN scopus_classes b
ON a.source_id=b.scp where pub_year >=2000 AND pub_year <=2015 
AND publication is TRUE
and class_code='1703')
SELECT cluster_20,count(source_id)
FROM cte GROUP BY cluster_20;

UPDATE public.dblp_graclus_2000_2015_counts
SET ct_m_1703 = xxx.count
FROM xxx
WHERE dblp_graclus_2000_2015_counts.cluster_20 = xxx.cluster_20;

-- cg_cad_1704
DROP TABLE IF EXISTS xxx;
CREATE TEMP TABLE xxx
AS WITH cte AS (
SELECT DISTINCT a.cluster_20,a.source_id
FROM dblp_graclus a INNER JOIN scopus_classes b
ON a.source_id=b.scp where pub_year >=2000 AND pub_year <=2015 
AND publication is TRUE
and class_code='1704')
SELECT cluster_20,count(source_id)
FROM cte GROUP BY cluster_20;

UPDATE public.dblp_graclus_2000_2015_counts
SET cg_cad_1704 = xxx.count
FROM xxx
WHERE dblp_graclus_2000_2015_counts.cluster_20 = xxx.cluster_20;

-- cn_c_1705
DROP TABLE IF EXISTS xxx;
CREATE TEMP TABLE xxx
AS WITH cte AS (
SELECT DISTINCT a.cluster_20,a.source_id
FROM dblp_graclus a INNER JOIN scopus_classes b
ON a.source_id=b.scp where pub_year >=2000 AND pub_year <=2015 
AND publication is TRUE
and class_code='1705')
SELECT cluster_20,count(source_id)
FROM cte GROUP BY cluster_20;

UPDATE public.dblp_graclus_2000_2015_counts
SET cn_c_1705 = xxx.count
FROM xxx
WHERE dblp_graclus_2000_2015_counts.cluster_20 = xxx.cluster_20;

-- csa_1706

DROP TABLE IF EXISTS xxx;
CREATE TEMP TABLE xxx
AS WITH cte AS (
SELECT DISTINCT a.cluster_20,a.source_id
FROM dblp_graclus a INNER JOIN scopus_classes b
ON a.source_id=b.scp where pub_year >=2000 AND pub_year <=2015 
AND publication is TRUE
and class_code='1706')
SELECT cluster_20,count(source_id)
FROM cte GROUP BY cluster_20;

UPDATE public.dblp_graclus_2000_2015_counts
SET csa_1706 = xxx.count
FROM xxx
WHERE dblp_graclus_2000_2015_counts.cluster_20 = xxx.cluster_20;

-- cv_pr_1707

DROP TABLE IF EXISTS xxx;
CREATE TEMP TABLE xxx
AS WITH cte AS (
SELECT DISTINCT a.cluster_20,a.source_id
FROM dblp_graclus a INNER JOIN scopus_classes b
ON a.source_id=b.scp where pub_year >=2000 AND pub_year <=2015 
AND publication is TRUE
and class_code='1707')
SELECT cluster_20,count(source_id)
FROM cte GROUP BY cluster_20;

UPDATE public.dblp_graclus_2000_2015_counts
SET cv_pr_1707 = xxx.count
FROM xxx
WHERE dblp_graclus_2000_2015_counts.cluster_20 = xxx.cluster_20;

-- h_a_1708

DROP TABLE IF EXISTS xxx;
CREATE TEMP TABLE xxx
AS WITH cte AS (
SELECT DISTINCT a.cluster_20,a.source_id
FROM dblp_graclus a INNER JOIN scopus_classes b
ON a.source_id=b.scp where pub_year >=2000 AND pub_year <=2015 
AND publication is TRUE
and class_code='1708')
SELECT cluster_20,count(source_id)
FROM cte GROUP BY cluster_20;

UPDATE public.dblp_graclus_2000_2015_counts
SET h_a_1708 = xxx.count
FROM xxx
WHERE dblp_graclus_2000_2015_counts.cluster_20 = xxx.cluster_20;

-- hci_1709

DROP TABLE IF EXISTS xxx;
CREATE TEMP TABLE xxx
AS WITH cte AS (
SELECT DISTINCT a.cluster_20,a.source_id
FROM dblp_graclus a INNER JOIN scopus_classes b
ON a.source_id=b.scp where pub_year >=2000 AND pub_year <=2015 
AND publication is TRUE
and class_code='1709')
SELECT cluster_20,count(source_id)
FROM cte GROUP BY cluster_20;

UPDATE public.dblp_graclus_2000_2015_counts
SET hci_1709 = xxx.count
FROM xxx
WHERE dblp_graclus_2000_2015_counts.cluster_20 = xxx.cluster_20;

-- is_1710

DROP TABLE IF EXISTS xxx;
CREATE TEMP TABLE xxx
AS WITH cte AS (
SELECT DISTINCT a.cluster_20,a.source_id
FROM dblp_graclus a INNER JOIN scopus_classes b
ON a.source_id=b.scp where pub_year >=2000 AND pub_year <=2015 
AND publication is TRUE
and class_code='1710')
SELECT cluster_20,count(source_id)
FROM cte GROUP BY cluster_20;

UPDATE public.dblp_graclus_2000_2015_counts
SET is_1710 = xxx.count
FROM xxx
WHERE dblp_graclus_2000_2015_counts.cluster_20 = xxx.cluster_20;

-- sp_1711

DROP TABLE IF EXISTS xxx;
CREATE TEMP TABLE xxx
AS WITH cte AS (
SELECT DISTINCT a.cluster_20,a.source_id
FROM dblp_graclus a INNER JOIN scopus_classes b
ON a.source_id=b.scp where pub_year >=2000 AND pub_year <=2015 
AND publication is TRUE
and class_code='1711')
SELECT cluster_20,count(source_id)
FROM cte GROUP BY cluster_20;

UPDATE public.dblp_graclus_2000_2015_counts
SET sp_1711 = xxx.count
FROM xxx
WHERE dblp_graclus_2000_2015_counts.cluster_20 = xxx.cluster_20;

-- sw_1712

DROP TABLE IF EXISTS xxx;
CREATE TEMP TABLE xxx
AS WITH cte AS (
SELECT DISTINCT a.cluster_20,a.source_id
FROM dblp_graclus a INNER JOIN scopus_classes b
ON a.source_id=b.scp where pub_year >=2000 AND pub_year <=2015 
AND publication is TRUE
and class_code='1712')
SELECT cluster_20,count(source_id)
FROM cte GROUP BY cluster_20;

UPDATE public.dblp_graclus_2000_2015_counts
SET sw_1712 = xxx.count
FROM xxx
WHERE dblp_graclus_2000_2015_counts.cluster_20 = xxx.cluster_20;

-- end loop of sorts



