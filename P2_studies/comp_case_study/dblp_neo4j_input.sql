\set ON_ERROR_STOP on
\set ECHO all


/*

 Nodes: 634100

 Edges: 1395722

 1st query:
 SQL for nodes and their attributes
 Each node has the cluster number it belongs to, publication year and total citation count

 2nd query:
 SQL for edge list
 In this case only edges where a publications is citing another publication are selected

 */



SET SEARCH_PATH TO public;

--1st query

SELECT source_id, cluster_20 AS cluster_no, pub_year, citation_count
FROM dblp_graclus
WHERE publication = TRUE
  AND citation_count IS NOT NULL;

-- 2nd query

SELECT source_id, 'citing' AS s_type, cited_source_uid, 'cited' AS csi_type
FROM dblp_dataset
WHERE cited_source_uid IN (
    SELECT source_id
    FROM dblp_graclus
    WHERE publication = TRUE
      AND citation_count IS NOT NULL
);
