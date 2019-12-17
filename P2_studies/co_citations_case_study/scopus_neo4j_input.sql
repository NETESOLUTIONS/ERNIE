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

DROP VIEW IF EXISTS nodes;

CREATE VIEW nodes AS
SELECT sp.scp AS "node_id:ID", pub_year
FROM scopus_publications sp
         JOIN scopus_publication_groups spg ON sp.sgr = spg.sgr;

SELECT COUNT(1)
FROM nodes;
-- 633,165

-- 2nd query

DROP VIEW IF EXISTS edges;

CREATE VIEW edges AS
SELECT scp AS from_node_id, ref_sgr AS to_node_id
FROM scopus_references
WHERE scp IN (SELECT "node_id:ID" FROM nodes) --
  AND ref_sgr IN (SELECT "node_id:ID" FROM nodes);

/*
SELECT source_id AS from_node_id, cited_source_uid AS to_node_id
  FROM dblp_dataset
 WHERE cited_source_uid IN (
   SELECT source_id FROM dblp_graclus WHERE publication = TRUE AND citation_count IS NOT NULL AND pub_year IS NOT NULL
 );
*/

SELECT COUNT(1)
FROM edges;
-- 1,395,462