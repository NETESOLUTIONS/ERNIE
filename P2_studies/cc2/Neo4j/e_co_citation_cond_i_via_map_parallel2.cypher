// E(x,y)/(|N(x)|*|N(y)|) Index
// 10 pairs: 0.8s-1.8s-7.2s
// 20 pairs: 4.3s
// 25 pairs: 3.2-3.8s-9.2s
// *30 pairs: 2.7-3.4-7.4s*
// 40 pairs: FAILED
// 50 pairs: FAILED
WITH $JDBC_conn_string AS db, $sql_query AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
WITH collect({x_scp: row.cited_1, y_scp: row.cited_2}) AS pairs
CALL apoc.cypher.mapParallel2('
  MATCH (x:Publication {node_id: _.x_scp})<--(Nxy)-->(y:Publication {node_id: _.y_scp})
  WITH min(Nxy.pub_year) AS first_co_citation_year, _.x_scp AS x_scp, _.y_scp AS y_scp
  OPTIONAL MATCH (x:Publication {node_id: x_scp})<--(Nx:Publication)
    WHERE Nx.pub_year <= first_co_citation_year
  WITH count(Nx) AS nx_size, first_co_citation_year, x_scp, y_scp
  OPTIONAL MATCH (y:Publication {node_id: y_scp})<--(Ny:Publication)
    WHERE Ny.pub_year <= first_co_citation_year
  WITH count(Ny) AS ny_size, nx_size, first_co_citation_year, x_scp, y_scp
  OPTIONAL MATCH
    (x:Publication {node_id: x_scp})<--(Ex:Publication)-[E]-(Ey:Publication)-->(y:Publication {node_id: y_scp})
    WHERE startNode(E).pub_year <= first_co_citation_year
  RETURN x_scp, y_scp, toFloat(count(E)) / (nx_size * ny_size) AS e_index',
{}, pairs, 8) YIELD value
RETURN value.x_scp AS cited_1, value.y_scp AS cited_2, value.e_index AS e_index;