// Jaccard Co-Citation* Index
// 50 pairs: 2.20s
// *75 pairs: 1.56s*
// 100 pairs: 7.13s ()
WITH $JDBC_conn_string AS db, $sql_query AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
MATCH (x:Publication {node_id: row.cited_1})<--(Nxy)-->(y:Publication {node_id: row.cited_2})
WITH
  count(Nxy) AS intersect_size, row.cited_1 AS x_scp, row.cited_2 AS y_scp
OPTIONAL MATCH (x:Publication {node_id: x_scp})<--(Nx:Publication)
  WHERE Nx.node_id <> y_scp
WITH collect(Nx) AS nx_list, intersect_size, x_scp, y_scp
OPTIONAL MATCH (y:Publication {node_id: y_scp})<--(Ny:Publication)
  WHERE Ny.node_id <> x_scp
WITH nx_list + collect(Ny) AS union_list, intersect_size, x_scp, y_scp
UNWIND union_list AS union_node
RETURN x_scp AS cited_1, y_scp AS cited_2,
       toFloat(intersect_size) / (count(DISTINCT union_node) + 2) AS jaccard_co_citation_star_index;