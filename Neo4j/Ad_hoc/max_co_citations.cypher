/*
Specify parameter: e.g.

Neo4j UI:
:param scp => 75149149112

JetBrains IDEs / Graph Database Support plug-in
{
  "scp": 75149149112
}
*/

// 0.05s
MATCH (p:Publication {node_id: $scp})<--(c:Publication)-[r]->(x:Publication)
RETURN x.node_id AS scp, count(r) AS co_citations
ORDER BY co_citations DESC, scp
LIMIT 10;

// 0.05s
MATCH (p:Publication {node_id: $scp})<--(c:Publication)
MATCH (x:Publication)<-[r]-(c)
WHERE x.node_id <> $scp
RETURN x.node_id AS scp, count(r) AS co_citations
ORDER BY co_citations DESC, scp
LIMIT 10;

// 0.1s
MATCH (p:Publication {node_id: $scp})<--(c:Publication)
WITH collect(c.node_id) AS citing_pubs
MATCH (x:Publication)<-[r]-(c:Publication)
WHERE x.node_id <> $scp AND c.node_id IN citing_pubs
RETURN x.node_id AS scp, count(r) AS co_citations
ORDER BY co_citations DESC, scp
LIMIT 10;

// 0.1s
MATCH (p:Publication {node_id: $scp})<--(c:Publication)
WITH collect(c.node_id) AS citing_pubs
MATCH (x:Publication)<-[r]-(c:Publication)
WHERE x.node_id <> $scp AND c.node_id IN citing_pubs
RETURN x.node_id AS scp, size(collect(r)) AS co_citations
ORDER BY co_citations DESC, scp
LIMIT 25;

// 37.8s
MATCH (p:Publication {node_id: $scp})<--(c:Publication)
WITH collect(c) AS citing_pubs
MATCH (x:Publication)<-[r]-(c:Publication)
WHERE c IN citing_pubs
RETURN x.node_id AS scp, size(collect(r)) AS co_citations
ORDER BY co_citations DESC
LIMIT 5;