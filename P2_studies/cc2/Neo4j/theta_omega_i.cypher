// Theta-Omega Index
// 10 pairs: 2.7s
// 20 pairs: 1.8s-72s
// 25 pairs: 11.0s
// *30 pairs: 5.0-8.0s*
// 40 pairs: 129.4s
WITH $JDBC_conn_string AS db, $sql_query AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
OPTIONAL MATCH (x:Publication {node_id: row.cited_1})<--(Nx:Publication)
  WHERE Nx.pub_year <= row.first_co_cited_year
WITH count(Nx) AS nx_size, row.first_co_cited_year AS f_c_c_y, row.cited_1 AS x_scp, row.cited_2 AS y_scp
OPTIONAL MATCH (y:Publication {node_id: y_scp})<--(Ny:Publication)
  WHERE Ny.pub_year <= f_c_c_y
WITH count(Ny) AS ny_size, nx_size, f_c_c_y, x_scp, y_scp
OPTIONAL MATCH
  (x:Publication {node_id: x_scp})<--(Ex:Publication)-[E]-(Ey:Publication)-->(y:Publication {node_id: y_scp})
  WHERE Ex.pub_year <= f_c_c_y AND Ey.pub_year <= f_c_c_y AND startNode(E).pub_year <= f_c_c_y
WITH count(E) AS case1_size, nx_size, ny_size, f_c_c_y, x_scp, y_scp
OPTIONAL MATCH
  (x:Publication {node_id: x_scp})<--(y:Publication {node_id: y_scp})<-[E]-(Ey:Publication)
  WHERE Ey.pub_year <= f_c_c_y
WITH count(E) AS case2_size, case1_size, nx_size, ny_size, f_c_c_y, x_scp, y_scp
OPTIONAL MATCH
  (y:Publication {node_id: y_scp})<--(x:Publication {node_id: x_scp})<-[E]-(Ex:Publication)
  WHERE Ex.pub_year <= f_c_c_y
RETURN x_scp AS cited_1, y_scp AS cited_2,
       toFloat(count(E) + case1_size + case2_size) / (nx_size * ny_size) AS e_co_citation_conditional_index;