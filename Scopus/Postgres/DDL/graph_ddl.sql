CREATE OR REPLACE VIEW nodes("node_id:ID", "pub_year:short", citation_type, "has_issn:boolean") AS
SELECT sp.scp AS "node_id:ID", spg.pub_year, sp.citation_type, (ss.issn_main != '') AS has_issn
  FROM scopus_publications sp
  JOIN scopus_publication_groups spg
       ON sp.sgr = spg.sgr
  LEFT JOIN scopus_sources ss
            ON ss.ernie_source_id = sp.ernie_source_id;

CREATE OR REPLACE VIEW edges AS
SELECT scp AS from_node_id, ref_sgr AS to_node_id
  FROM scopus_references
 WHERE ref_sgr IN (SELECT "node_id:ID" FROM nodes);
