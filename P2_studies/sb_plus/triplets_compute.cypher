UNWIND $input_data AS row
MATCH (a:Publication {node_id: row.cited_1})<--(p)-->(b:Publication {node_id: row.cited_2}), (p)-->(c:Publication)
WHERE a.node_id <> p.node_id AND b.node_id <> p.node_id AND c.node_id <> p.node_id AND c.node_id <> a.node_id AND c.node_id <> b.node_id AND c.pub_year <= p.pub_year AND a.pub_year <= p.pub_year AND b.pub_year <= p.pub_year AND p.citation_type = 'ar'
RETURN a.node_id AS scp1, b.node_id AS scp2, c.node_id AS scp3, COUNT(p) AS frequency;
