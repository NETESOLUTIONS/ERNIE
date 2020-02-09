// Jaccard Co-Citation Index
// 50 pairs: 0.6-0.7s (6.3s)
// 100 pairs: 3.5-3.7s (2.10s)
UNWIND $input_data AS row
MATCH (x:Publication {node_id: row.cited_1})<--(Nxy)-->(y:Publication {node_id: row.cited_2})
WITH
  count(Nxy) AS intersect_size, row.cited_1 AS x_scp, row.cited_2 AS y_scp
OPTIONAL MATCH (x:Publication {node_id: x_scp})<--(Nx:Publication)
WITH collect(Nx) AS nx_list, intersect_size, x_scp, y_scp
OPTIONAL MATCH (y:Publication {node_id: y_scp})<--(Ny:Publication)
WITH nx_list + collect(Ny) AS union_list, intersect_size, x_scp, y_scp
UNWIND union_list AS union_node
RETURN
  x_scp AS cited_1, y_scp AS cited_2, toFloat(intersect_size) / count(DISTINCT union_node) AS jaccard_co_citation_index;
