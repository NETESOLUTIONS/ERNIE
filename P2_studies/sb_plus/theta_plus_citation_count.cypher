UNWIND $input_data AS row
MATCH (p)-->(a:Publication{node_id: row.scp})
WHERE a.pub_year <= p.pub_year AND p.pub_year <=a.pub_year + 10
RETURN a.node_id AS cited_paper, count(p) AS frequency
ORDER BY a.node_id
