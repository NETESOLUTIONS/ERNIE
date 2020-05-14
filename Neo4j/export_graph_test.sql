\set ON_ERROR_STOP on
\set ECHO all

\if :{?schema}
SET search_path = :schema;
\endif

-- JetBrains IDEs: start execution from here
SET TIMEZONE = 'US/Eastern';
/*
 Nodes: LIMIT 10
 Edges:
 1st query:
 SQL for nodes and their attributes
 Each node has the cluster number it belongs to, publication year
 2nd query:
 SQL for edge list
 In this case only edges where a publications is citing another publication are selected
 */

-- SET SEARCH_PATH TO public;

-- --1st query

-- DROP VIEW IF EXISTS nodes_test;

-- CREATE VIEW nodes_test AS
-- SELECT sp.scp, pub_year, pub_type
--   FROM scopus_publications sp
--   JOIN scopus_publication_groups spg ON sp.sgr = spg.sgr
-- ORDERBY scp
-- LIMIT 1000;

-- SELECT COUNT(1)
--   FROM nodes_test;
-- -- 1000

-- -- 2nd query

-- DROP VIEW IF EXISTS edges_test;

-- CREATE VIEW edges_test AS
-- SELECT scp AS from_node_id, ref_sgr AS to_node_id
--   FROM scopus_references
--  WHERE scp IN (SELECT scp FROM nodes_test) --
--    AND ref_sgr IN (SELECT scp FROM nodes_test);

-- SELECT COUNT(1)
--   FROM edges_test;
-- --- 5


\copy (SELECT * FROM nodes_test) TO 'nodes.csv' (FORMAT CSV, HEADER ON)
\copy (SELECT from_node_id AS ":START_ID", to_node_id AS ":END_ID" FROM edges_test) TO 'edges.csv' (FORMAT CSV, HEADER ON)
