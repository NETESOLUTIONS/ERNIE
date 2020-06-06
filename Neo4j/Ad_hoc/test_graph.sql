CREATE OR REPLACE VIEW edges AS
SELECT sr.scp AS from_node_id, sr.ref_sgr AS to_node_id
  FROM scopus_references sr
  JOIN scopus_publications sp ON sp.scp = sr.ref_sgr
  -- Use any order for determinism
  ORDER BY sr.scp, sr.ref_sgr
  LIMIT 1000;

CREATE OR REPLACE VIEW nodes("node_id:ID", "pub_year:short", citation_type, "has_issn:boolean") AS
SELECT sp.scp AS "node_id:ID", spg.pub_year, sp.citation_type, (ss.issn_main != '') AS has_issn
  FROM scopus_publications sp
  JOIN scopus_publication_groups spg
       ON sp.sgr = spg.sgr
  LEFT JOIN scopus_sources ss
            ON ss.ernie_source_id = sp.ernie_source_id
  WHERE sp.scp IN (SELECT from_node_id FROM edges) OR sp.scp IN (SELECT to_node_id FROM edges);

SELECT *
FROM nodes;
-- 3m:34s

SELECT *
FROM edges;
-- 0.1s