/*
Specify parameter: e.g.

Neo4j UI:
:param scp => 75149149112

JetBrains IDEs / Graph Database Support plug-in
{
  "scp": 75149149112
}
*/
MATCH (a:Publication)<-[r1:CITES]-(c:Publication {node_id: $scp})-[r2:CITES]->(b:Publication)
  WHERE a.node_id <> c.node_id AND b.node_id <> c.node_id AND c.citation_type = 'ar'
  AND c.pub_year = 1985 AND a.pub_year <= 1985 AND b.pub_year <= 1985 AND a.node_id < b.node_id
WITH c.node_id AS scp, count(r1) + count(r2) AS citations
//LIMIT 10
MATCH (a:Publication)<-[r1:CITES]-(c:Publication {node_id: scp})-[r2:CITES]->(b:Publication)
WHERE citations >= 50 AND a.node_id <> c.node_id AND b.node_id <> c.node_id
  AND a.pub_year <= 1985 AND b.pub_year <= 1985 AND a.node_id < b.node_id
//RETURN a.node_id AS cited1_scp, b.node_id AS cited2_scp;
RETURN scp, COUNT([a.node_id, b.node_id]);


MATCH (a:Publication)<-[r1:CITES]-(c:Publication {node_id: $scp})-[r2:CITES]->(b:Publication)
  WHERE a.node_id <> c.node_id AND b.node_id <> c.node_id AND c.citation_type = 'ar'
  AND c.pub_year = 1985 AND a.pub_year <= 1985 AND b.pub_year <= 1985 AND a.node_id < b.node_id
RETURN c.node_id AS scp, count(r1) + count(r2) AS citations;

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
