CREATE OR REPLACE VIEW nodes_test("node_id:ID", "pub_year:short", citation_type, "has_issn:boolean") AS
SELECT sp.scp AS "node_id:ID", spg.pub_year, sp.citation_type, (ss.issn_main != '') AS has_issn
  FROM scopus_publications sp
  JOIN scopus_publication_groups spg
       ON sp.sgr = spg.sgr
  LEFT JOIN scopus_sources ss
            ON ss.ernie_source_id = sp.ernie_source_id
 ORDER BY "node_id:ID"
 -- LIMIT 1000;

CREATE OR REPLACE VIEW edges_test AS
SELECT scp AS from_node_id, ref_sgr AS to_node_id
  FROM scopus_references
 WHERE scp IN (SELECT "node_id:ID" FROM nodes_test2)
   AND ref_sgr IN (SELECT "node_id:ID" FROM nodes_test2);
