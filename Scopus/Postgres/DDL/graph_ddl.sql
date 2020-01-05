CREATE OR REPLACE VIEW nodes("node_id:ID", "pub_year:short") AS
SELECT sp.scp AS "node_id:ID", spg.pub_year
  FROM
    scopus_publications sp
      JOIN scopus_publication_groups spg ON sp.sgr = spg.sgr;

CREATE OR REPLACE VIEW edges(from_node_id, to_node_id) AS
SELECT sr.scp AS from_node_id, sp.scp AS to_node_id
  FROM
    -- from_node_id (sr.scp) is a valid node, enforced by an FK
    scopus_references sr
      -- Limit to_node_id to valid references only
      JOIN scopus_publications sp ON sp.sgr = sr.ref_sgr;
