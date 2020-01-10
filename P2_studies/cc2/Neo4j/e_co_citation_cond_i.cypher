// E(x,y)/(|N(x)|*|N(y)|) Index
// 10 pairs: 14.7s
// 20 pairs: 6.0s-8.6s
// *25 pairs: 6.1s-10.7s*
// 30 pairs: 15.9s
// 40 pairs: 46.0s
// 50 pairs: 30.7s
WITH $JDBC_conn_string AS db, $sql_query AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
MATCH (x:Publication {node_id: row.cited_1})<--(Nxy)-->(y:Publication {node_id: row.cited_2})
WITH min(Nxy.pub_year) AS first_co_citation_year, row.cited_1 AS x_scp, row.cited_2 AS y_scp
OPTIONAL MATCH (x:Publication {node_id: x_scp})<--(Nx:Publication)
  WHERE Nx.pub_year <= first_co_citation_year
WITH count(Nx) AS nx_size, first_co_citation_year, x_scp, y_scp
OPTIONAL MATCH (y:Publication {node_id: y_scp})<--(Ny:Publication)
  WHERE Ny.pub_year <= first_co_citation_year
WITH count(Ny) AS ny_size, nx_size, first_co_citation_year, x_scp, y_scp
OPTIONAL MATCH
  (x:Publication {node_id: x_scp})<--(Ex:Publication)-[E]-(Ey:Publication)-->(y:Publication {node_id: y_scp})
  WHERE startNode(E).pub_year <= first_co_citation_year
RETURN x_scp AS cited_1, y_scp AS cited_2, toFloat(count(E)) / (nx_size * ny_size) AS e_co_citation_conditional_index;