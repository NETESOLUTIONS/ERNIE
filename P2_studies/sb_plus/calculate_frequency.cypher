UNWIND $input_data AS row
MATCH (a:Publication{node_id: row.cited_1})<-[r:CITES]-(p:Publication)-[x:CITES]->(b:Publication{node_id:row.cited_2})
RETURN a.node_id AS cited_1,b.node_id AS cited_2, count(p) AS scopus_frequency
