MATCH (c:Publication)-[r:CITES]->(b:Publication)
  WHERE c.citation_type = 'ar' AND c.pub_year = 1985 AND b.pub_year <= 1985
WITH c.node_id AS scp, count(r) AS citations
MATCH ()
WHERE citations >= 50
RETURN sum(citations) AS total_citations;

// 7m:52s
MATCH (c:Publication)-[r:CITES]->(b:Publication)
  WHERE c.citation_type = 'ar' AND c.pub_year = 1985 AND b.pub_year <= 1985
WITH c.node_id AS scp, count(r) AS citations
MATCH (c:Publication)
WHERE c.node_id = scp AND citations >= 50
RETURN sum(citations) AS total_citations;
// 540070

MATCH (c:Publication {node_id: 1557355})-[:CITES]->(b:Publication)
  WHERE b.node_id <> c.node_id AND c.citation_type = 'ar' AND c.pub_year = 1985 AND b.pub_year <= 1985
WITH b, c
MATCH (c:Publication)-[:CITES]->(b:Publication)
  WHERE size((c)-->()) >= 50
RETURN count([c, b]);
