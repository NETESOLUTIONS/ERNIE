UNWIND $input_data AS csvFile
MATCH (a:Publication{node_id:toInteger(csvFile[0])})<-[r:CITES]-(p:Publication)-[x:CITES]->(b:Publication{node_id:toInteger(csvFile[1])})
RETURN a.node_id AS cited_1,b.node_id AS cited_2, count(p) AS scopus_frequency;
