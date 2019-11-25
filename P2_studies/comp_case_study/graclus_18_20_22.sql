-- Script to generate edgelists labeled with clusters from 
-- comp.dblp_graclus2 for 18, 20, and 22 cluster runs
-- Result were tested for the correct number of clusters
-- George Chacko 11/25/2019

DROP TABLE IF EXISTS comp.dblp_graclus2_edgelist_clusters_18;
CREATE TABLE comp.dblp_graclus2_edgelist_clusters_18 tablespace p2_studies_tbs 
AS WITH cte AS (SELECT a.source_id AS citing,a.cited_source_uid 
AS cited,b.cluster_18 AS citing_cluster 
FROM comp.dblp_graclus2_edgelist a 
INNER JOIN comp.dblp_graclus2 b ON a.source_id=b.source_id) 
SELECT cte.*,b.cluster_18 AS cited_cluster 
FROM cte INNER JOIN comp.dblp_graclus2 b ON cte.cited=b.source_id;
\COPY (SELECT * FROM comp.dblp_graclus2_edgelist_clusters_18) TO '/home/chackoge/dblp_graclus2_edgelist_clusters_18.csv' CSV HEADER DELIMITER ',';

DROP TABLE IF EXISTS comp.dblp_graclus2_edgelist_clusters_20;
CREATE TABLE comp.dblp_graclus2_edgelist_clusters_20 tablespace p2_studies_tbs 
AS WITH cte AS (SELECT a.source_id AS citing,a.cited_source_uid 
AS cited,b.cluster_20 AS citing_cluster 
FROM comp.dblp_graclus2_edgelist a 
INNER JOIN comp.dblp_graclus2 b ON a.source_id=b.source_id) 
SELECT cte.*,b.cluster_20 AS cited_cluster 
FROM cte INNER JOIN comp.dblp_graclus2 b ON cte.cited=b.source_id;
\COPY (SELECT * FROM comp.dblp_graclus2_edgelist_clusters_20 ) TO '/home/chackoge/dblp_graclus2_edgelist_clusters_20.csv' CSV HEADER DELIMITER ',';

DROP TABLE IF EXISTS comp.dblp_graclus2_edgelist_clusters_22;
CREATE TABLE comp.dblp_graclus2_edgelist_clusters_22 tablespace p2_studies_tbs 
AS WITH cte AS (SELECT a.source_id AS citing,a.cited_source_uid 
AS cited,b.cluster_22 AS citing_cluster 
FROM comp.dblp_graclus2_edgelist a 
INNER JOIN comp.dblp_graclus2 b ON a.source_id=b.source_id) 
SELECT cte.*,b.cluster_22 AS cited_cluster 
FROM cte INNER JOIN comp.dblp_graclus2 b ON cte.cited=b.source_id;
\COPY (
SELECT * FROM comp.dblp_graclus2_edgelist_clusters_22) TO '/home/chackoge/dblp_graclus2_edgelist_clusters_22.csv' CSV HEADER DELIMITER ',';




