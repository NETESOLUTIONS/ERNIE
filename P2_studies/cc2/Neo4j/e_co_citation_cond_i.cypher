// E(x,y)/(|N(x)|*|N(y)|) Index
// 10 pairs: 20.5s (29 records/min)
// 20 pairs: 31.9s (38 records/min)
// 50 pairs: 65.8s (46 records/min)
// 100 pairs: 85.7s (70 records/min)
// 150 pairs: ?
// 200 pairs: 754.2s (16 records/min)
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
RETURN x_scp AS cited_1, y_scp AS cited_2, toFloat(count(E)) / (nx_size * ny_size) AS e_index;