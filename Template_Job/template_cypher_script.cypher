MATCH (n:Publication)
RETURN n.has_issn, n.pub_year, n.citation_type, n.node_id AS scp
  LIMIT 10;