--Cypher query for generating publications that published in 1985, type "ar" and has at least 5 references, and then unique co-cited pairs:

MATCH (c:Publication)-[r:CITES]->(b:Publication)
WHERE c.citation_type = 'ar' AND c.pub_year = 1985 AND b.pub_year <= 1985 AND b.node_id <> c.node_id
WITH c.node_id AS scp, count(r) AS citations
MATCH (c:Publication)
WHERE c.node_id = scp AND citations >= 5
RETURN sum(citations) AS total_citations;

MATCH (c:Publication)-[r:CITES]->(d:Publication)
WHERE  c.pub_year = 1985 AND c.citation_type = 'ar' AND d.pub_year <=1985 AND c.node_id <> d.node_id
WITH c.node_id as scp, count(r) as citations
MATCH (a:Publication)<-[r1:CITES]-(c:Publication {node_id: scp})-[r2:CITES]->(b:Publication)
WHERE a.node_id <> c.node_id AND b.node_id <> c.node_id AND a.pub_year <= 1985 AND b.pub_year <= 1985 AND a.node_id < b.node_id AND citations >= 5
WITH a,b,c,citations
RETURN COUNT([c,a,b])
