UNWIND $input_data AS row
MATCH (a:Publication{node_id: row.cited_1})<--(p)-->(b:Publication{node_id:row.cited_2})
RETURN row.cited_1 AS cited_1, row.cited_2 AS cited_2, count(p) AS scopus_frequency;
