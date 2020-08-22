UNWIND $input_data AS row
MATCH (a:Publication {node_id: row.scp1})<--(p)-->(b:Publication {node_id: row.scp2}), (p)-->(c:Publication {node_id: row.scp3})
WHERE a.node_id <> p.node_id AND b.node_id <> p.node_id AND c.node_id <> p.node_id AND c.pub_year <= p.pub_year AND a.pub_year <= p.pub_year AND b.pub_year <= p.pub_year AND p.citation_type = 'ar' 
RETURN a.node_id AS scp1, b.node_id as scp2, c.node_id as scp3, p.node_id AS citing_paper;
