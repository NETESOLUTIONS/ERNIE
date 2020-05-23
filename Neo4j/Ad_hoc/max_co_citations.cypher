// 0.1s
MATCH (p:Publication {node_id: $scp})<--(c:Publication)
WITH collect(c.node_id) AS citing_pubs
MATCH (x:Publication)<-[r]-(c:Publication)
WHERE x.node_id <> $scp AND c.node_id IN citing_pubs
RETURN x.node_id AS scp, size(collect(r)) AS co_citations
ORDER BY co_citations DESC, scp
LIMIT 10;

// 37.8s
MATCH (p:Publication {node_id: 75149149112})<--(c:Publication)
WITH collect(c) AS citing_pubs
MATCH (x:Publication)<-[r]-(c:Publication)
WHERE c IN citing_pubs
RETURN x.node_id AS scp, size(collect(r)) AS co_citations
ORDER BY co_citations DESC
LIMIT 5;