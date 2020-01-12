// Jaccard Co-Citation* Conditional (<= first_co_citation_year) Index
// 100 pairs: 1.3-2.6-4.3s (732 records/min)
// *200 pairs: 3.0-5.0s-6.1s (851 records/min)*
// 400 pairs: 6.1-12.0s-21.2s
WITH $JDBC_conn_string AS db, $sql_query AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
OPTIONAL MATCH (x:Publication {node_id: row.cited_1})<--(Nxy)-->(y:Publication {node_id: row.cited_2})
  WHERE Nxy.pub_year <= row.first_co_cited_year
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