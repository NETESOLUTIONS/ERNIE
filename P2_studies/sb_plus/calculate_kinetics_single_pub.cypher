UNWIND $input_data AS row
MATCH (p)-->(a:Publication{node_id: row.cited_paper})
WHERE a.pub_year <= p.pub_year AND p.pub_year IS NOT NULL AND p.pub_year <= 2018
RETURN a.node_id AS cited_paper, p.pub_year AS year, count(p) AS frequency
ORDER BY a.node_id, p.pub_year;
