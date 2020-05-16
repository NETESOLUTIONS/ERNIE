CREATE OR REPLACE VIEW nodes_test("node_id:ID", "pub_year:short", citation_type, "has_issn:boolean") AS
SELECT sp.scp AS "node_id:ID", spg.pub_year, sp.citation_type, (ss.issn_main != '') AS has_issn
  FROM scopus_publications sp
  JOIN scopus_publication_groups spg
       ON sp.sgr = spg.sgr
  LEFT JOIN scopus_sources ss
            ON ss.ernie_source_id = sp.ernie_source_id
 ORDER BY "node_id:ID"
 LIMIT 1000;

CREATE OR REPLACE VIEW edges(from_node_id, to_node_id) AS
SELECT sr.scp AS from_node_id, sp.scp AS to_node_id
  FROM
    -- from_node_id (sr.scp) is a valid node, enforced by an FK
    scopus_references sr
      -- Limit to_node_id to valid references only
    JOIN scopus_publications sp
         ON sp.sgr = sr.ref_sgr;

CREATE OR REPLACE VIEW edges_test AS
SELECT scp AS from_node_id, ref_sgr AS to_node_id
  FROM scopus_references
 WHERE scp IN (
   SELECT scp
     FROM nodes_test
 )
   AND ref_sgr IN (
   SELECT scp
     FROM nodes_test
 );
