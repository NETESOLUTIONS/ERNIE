// E(x,y)/(|N(x)|*|N(y)|) Index
// 10 pairs: ? 7.1s
// *20 pairs: ? 4.4-7.1s*
// 25 pairs: ? 15.5-110.7s
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
RETURN x_scp AS cited_1, y_scp AS cited_2, case1_size, case2_size, count(E), nx_size, ny_size;

WITH $JDBC_conn_string AS db, $sql_query AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
WITH row.first_co_cited_year AS f_c_c_y, row.cited_1 AS x_scp, row.cited_2 AS y_scp
MATCH
  (x:Publication {node_id: x_scp})<--(y:Publication {node_id: y_scp})-[E]-(Ey:Publication)
  WHERE Ey.pub_year <= f_c_c_y
RETURN startNode(E).node_id AS citing, endNode(E).node_id AS cited, f_c_c_y, x_scp, y_scp;

// N(x, fccy)
WITH $JDBC_conn_string AS db, $sql_query AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
OPTIONAL MATCH (x:Publication {node_id: row.cited_1})<--(Nx:Publication)
  WHERE Nx.pub_year <= row.first_co_cited_year
RETURN Nx.node_id AS Nx_scp, Nx.pub_year, x.node_id AS x_scp;
// 3

// N(y, fccy)
WITH $JDBC_conn_string AS db, $sql_query AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
OPTIONAL MATCH (y:Publication {node_id: row.cited_2})<--(Ny:Publication)
  WHERE Ny.pub_year <= row.first_co_cited_year
RETURN Ny.node_id AS Ny_scp, Ny.pub_year, y.node_id AS y_scp;
// 1

// |N(x)|
// 2.4s
MATCH (x:Publication {node_id: '17538003'})<--(Nxy:Publication)-->(y:Publication {node_id: '18983824'})
WITH min(toInteger(Nxy.pub_year)) AS first_co_citation_year, x
MATCH (Nx:Publication)-->(x)
  WHERE toInteger(Nx.pub_year) <= first_co_citation_year
RETURN count(Nx);
// 22

// |N(y)|
// 0.04s
MATCH (x:Publication {node_id: '17538003'})<--(Nxy:Publication)-->(y:Publication {node_id: '18983824'})
WITH min(toInteger(Nxy.pub_year)) AS first_co_citation_year, y
MATCH (Ny:Publication)-->(y)
  WHERE toInteger(Ny.pub_year) <= first_co_citation_year
RETURN count(Ny);
// 5

// E(x,y)
// 1.1s
MATCH (x:Publication {node_id: '17538003'})<--(Nxy:Publication)-->(y:Publication {node_id: '18983824'})
WITH min(toInteger(Nxy.pub_year)) AS first_co_citation_year, x, y
OPTIONAL MATCH (x)<--(Ex:Publication)-[E]-(Ey:Publication)-->(y)
  WHERE toInteger(startNode(E).pub_year) <= first_co_citation_year
WITH collect(E) AS edges, first_co_citation_year, x, y
OPTIONAL MATCH (x)<--(y)<-[E]-(Ey:Publication)
  WHERE toInteger(startNode(E).pub_year) <= first_co_citation_year
WITH collect(E) + edges AS edges, first_co_citation_year, x, y
OPTIONAL MATCH (y)<--(x)<-[E]-(Ex:Publication)
  WHERE toInteger(startNode(E).pub_year) <= first_co_citation_year
WITH collect(E) + edges AS edges
UNWIND edges AS edge
RETURN count(DISTINCT edge);
// 14

// E(x,y) on N*(x) and N*(y) result set
MATCH (x:Publication {node_id: '17538003'})<--(Nxy:Publication)-->(y:Publication {node_id: '18983824'})
WITH min(toInteger(Nxy.pub_year)) AS first_co_citation_year, x, y
OPTIONAL MATCH (x)<--(Ex:Publication)-[E]-(Ey:Publication)-->(y)
  WHERE toInteger(startNode(E).pub_year) <= first_co_citation_year
WITH collect(E) AS edges, first_co_citation_year, x, y
OPTIONAL MATCH (x)<--(y)<-[E]-(Ey:Publication)
  WHERE toInteger(startNode(E).pub_year) <= first_co_citation_year
WITH collect(E) + edges AS edges, first_co_citation_year, x, y
OPTIONAL MATCH (y)<--(x)<-[E]-(Ex:Publication)
  WHERE toInteger(startNode(E).pub_year) <= first_co_citation_year
WITH collect(E) + edges AS edges
UNWIND edges AS edge
RETURN DISTINCT toInteger(startNode(edge).node_id), toInteger(endNode(edge).node_id);
// 14

// Year of the first co-citation
MATCH (x:Publication {node_id: '17538003'})<--(Nxy:Publication)-->(y:Publication {node_id: '18983824'})
RETURN min(toInteger(Nxy.pub_year));