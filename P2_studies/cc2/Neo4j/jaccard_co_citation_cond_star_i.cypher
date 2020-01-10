// Jaccard Co-Citation* Conditional (<= first_co_citation_year) Index
// 30 pairs: 7.1s (254 pairs/min)
// 50 pairs: 3.3s-8.5s (353-907 pairs/min)
// *100 pairs: 1.5s-4.1s-11.2s (536-1,473-3,932 pairs/min)*
// 150 pairs: 9.6s (936 pairs/min)
// 200 pairs: 14.3s-24.9s (483-834 pairs/min)
// 400 pairs: 56.5s (424.7 pairs/min)
// 1000 pairs: 2278s (26 pairs/min)
WITH $JDBC_conn_string AS db, $sql_query AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
MATCH (x:Publication {node_id: row.cited_1})<--(Nxy)-->(y:Publication {node_id: row.cited_2})
WITH
  count(Nxy) AS intersect_size, row.first_co_cited_year AS first_co_citation_year, row.cited_1 AS x_scp,
  row.cited_2 AS y_scp
OPTIONAL MATCH (x:Publication {node_id: x_scp})<--(Nx:Publication)
  WHERE Nx.node_id <> y_scp AND Nx.pub_year <= first_co_citation_year
WITH collect(Nx) AS nx_list, intersect_size, first_co_citation_year, x_scp, y_scp
OPTIONAL MATCH (y:Publication {node_id: y_scp})<--(Ny:Publication)
  WHERE Ny.node_id <> x_scp AND Ny.pub_year <= first_co_citation_year
WITH nx_list + collect(Ny) AS union_list, intersect_size, x_scp, y_scp
UNWIND union_list AS union_node
RETURN x_scp AS cited_1, y_scp AS cited_2,
       toFloat(intersect_size) / (count(DISTINCT union_node) + 2) AS jaccard_co_citation_conditional_star_index;