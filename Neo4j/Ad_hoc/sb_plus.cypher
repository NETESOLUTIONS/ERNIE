/*
Specify parameter: e.g.

Neo4j UI:
:param scp => 75149149112

JetBrains IDEs / Graph Database Support plug-in
{
  "scp": 75149149112
}
*/

MATCH (c:Publication)-[r:CITES]->(d:Publication)
  WHERE c.pub_year = 1985 AND c.citation_type = 'ar' AND d.pub_year <= 1985 AND c.node_id <> d.node_id
  AND c.node_id IN [13033105, 21923086, 21823196, 22006539, 21846363]
WITH c.node_id AS scp, count(r) AS citations
MATCH (a:Publication)<-[r1:CITES]-(c:Publication {node_id: scp})-[r2:CITES]->(b:Publication)
  WHERE a.node_id <> c.node_id AND b.node_id <> c.node_id AND a.pub_year <= 1985 AND b.pub_year <= 1985
  AND a.node_id < b.node_id AND citations >= 5
WITH a.node_id AS cited_1, b.node_id AS cited_2, count(scp) AS frequency
  WHERE frequency >= 4
RETURN *
  ORDER BY frequency DESC;

MATCH (c:Publication)-[r:CITES]->(d:Publication)
  WHERE c.pub_year = 1985 AND c.citation_type = 'ar' AND d.pub_year <= 1985 AND c.node_id <> d.node_id
  AND c.node_id IN [13033105, 21923086, 21823196, 22006539, 21846363]
WITH c.node_id AS scp, count(r) AS citations
MATCH (a:Publication)<-[r1:CITES]-(c:Publication {node_id: scp})-[r2:CITES]->(b:Publication)
  WHERE a.node_id <> c.node_id AND b.node_id <> c.node_id AND a.pub_year <= 1985 AND b.pub_year <= 1985
  AND a.node_id < b.node_id AND citations >= 5
RETURN a.node_id AS cited_1, b.node_id AS cited_2, count(scp) AS frequency
  ORDER BY frequency DESC;

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


//test for node c.node_id = 125
CALL apoc.periodic.iterate(
"MATCH (c:Publication)-[r:CITES]->(d:Publication)
  WHERE c.pub_year = 1985 AND c.citation_type = 'ar' AND d.pub_year <= 1985 AND c.node_id <> d.node_id AND c.node_id = 125
WITH c.node_id AS scp, count(r) AS citations
MATCH (a:Publication)<-[]-(c:Publication {node_id: scp})-[]->(b:Publication)
  WHERE a.node_id <> c.node_id AND b.node_id <> c.node_id AND a.pub_year <= 1985 AND b.pub_year <= 1985 AND a.node_id < b.node_id AND citations >= 5
RETURN a.node_id AS cited_1, b.node_id AS cited_2",
"CALL apoc.export.csv.query('UNWIND $batch AS batch WITH batch.cited_1 AS cited_1, batch.cited_2 AS cited_2
MATCH (a:Publication {node_id: cited_1})<-[]-(e:Publication)-[]->(b:Publication {node_id: cited_2})
RETURN cited_1, cited_2, count(e) as frequency',
'/neo4j_data1/sb_plus/sb-plus-batch-' + $_batch[0].cited_1 + '-' + $_batch[0].cited_2 + '.csv', {params: {batch: $_batch}})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data", {
    batchSize: 10, parallel: true, batchMode: 'BATCH_SINGLE'})
