// Jaccard Co-Citation* Index: |N(xy) = Co-citing set|/|NxUNy = N*(x) union with N*(y)| with Postgres query input
// 5 pairs: 21s-26s
WITH $DB_conn_string AS db,
     '
     SELECT cited_1, cited_2
     FROM cc2.ten_year_cocit_union_freq11_freqsum_bins
     WHERE bin = 1
     ORDER BY random()
     LIMIT ' + $pairs_limit AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
MATCH (x:Publication {node_id: row.cited_1})<--(Nxy)-->(y:Publication {node_id: row.cited_2})
WITH count(Nxy) AS intersect_size, row.cited_1 AS x_scp, row.cited_2 AS y_scp
MATCH (x:Publication {node_id: x_scp})<--(Nx:Publication)
  WHERE Nx.node_id <> y_scp
WITH collect(Nx) AS nx_list, intersect_size, x_scp, y_scp
MATCH (y:Publication {node_id: y_scp})<--(Ny:Publication)
  WHERE Ny.node_id <> x_scp
WITH nx_list + collect(Ny) AS union_list, intersect_size, x_scp, y_scp
UNWIND union_list AS union_node
RETURN x_scp AS cited_1, y_scp AS cited_2,
       toFloat(intersect_size) / (count(DISTINCT union_node) + 2) AS jaccard_co_citation_star_index;

CREATE INDEX ON :Publication(co_cited);
DROP INDEX ON :Publication(co_cited);

// 0.1s
MATCH (n:Publication)
  WHERE exists(n.co_cited)
SET n.co_cited = NULL;

// Pre-load data input data
// 5 pairs: 1.7s
WITH $DB_conn_string AS db,
     '
     SELECT cited_1, cited_2
     FROM cc2.ten_year_cocit_union_freq11_freqsum_bins
     WHERE bin = 1
     ORDER BY random()
     LIMIT ' + $pairs_limit AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
MATCH (x:Publication {node_id: row.cited_1})
SET x.co_cited = row.cited_2;

MATCH (n:Publication)
WHERE exists(n.co_cited)
RETURN *;

// Jaccard Co-Citation* Index: |N(xy) = Co-citing set|/|NxUNy = N*(x) union with N*(y)| with pre-loaded input
// 5 pairs: 108s-1306s
MATCH (x:Publication)<--(Nxy)-->(y:Publication)
WHERE x.co_cited = y.node_id
WITH count(Nxy) AS intersect_size, x.node_id AS x_scp, y.node_id AS y_scp
MATCH (x:Publication {node_id: x_scp})<--(Nx:Publication)
  WHERE Nx.node_id <> y_scp
WITH collect(Nx) AS nx_list, intersect_size, x_scp, y_scp
MATCH (y:Publication {node_id: y_scp})<--(Ny:Publication)
  WHERE Ny.node_id <> x_scp
WITH nx_list + collect(Ny) AS union_list, intersect_size, x_scp, y_scp
UNWIND union_list AS union_node
RETURN x_scp AS cited_1, y_scp AS cited_2,
       toFloat(intersect_size) / (count(DISTINCT union_node) + 2) AS jaccard_co_citation_star_index;

// Jaccard Co-Citation* Index: |N(xy) = Co-citing set|/|NxUNy = N*(x) union with N*(y)| with Postgres query input
// 5 pairs: 68-70s
// 20 pairs: 255s
WITH $DB_conn_string AS db,
     '
     SELECT cited_1, cited_2
     FROM cc2.ten_year_cocit_union_freq11_freqsum_bins
     WHERE bin = 1
     ORDER BY random()
     LIMIT ' + $pairs_limit AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
MATCH (x:Publication {node_id: row.cited_1})<--(Nxy)-->(y:Publication {node_id: row.cited_2})
WITH count(Nxy) AS intersect_size, x, y
MATCH (x)<--(Nx)
  WHERE Nx <> y
WITH collect(Nx) AS nx_list, intersect_size, x, y
MATCH (y)<--(Ny)
  WHERE Ny <> x
WITH nx_list + collect(Ny) AS union_list, intersect_size, x, y
UNWIND union_list AS union_node
RETURN x.node_id AS cited_1, y.node_id AS cited_2,
       toFloat(intersect_size) / (count(DISTINCT union_node) + 2) AS jaccard_co_citation_star_index;

// Jaccard Co-Citation* Index: |N(xy) = Co-citing set|/|NxUNy = N*(x) union with N*(y)| with Postgres query input
// 1 pair
// 0.1-?s
WITH $DB_conn_string AS db,
     '
     SELECT cited_1, cited_2
     FROM cc2.ten_year_cocit_union_freq11_freqsum_bins
     WHERE bin = 1
     ORDER BY cited_1, cited_2
     LIMIT 1' AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
MATCH (x:Publication {node_id: row.cited_1})<--(Nxy)-->(y:Publication {node_id: row.cited_2})
WITH count(Nxy) AS intersect_size, x, y
MATCH (x)<--(Nx)
  WHERE Nx <> y
WITH collect(Nx) AS nx_list, intersect_size, x, y
MATCH (y)<--(Ny)
  WHERE Ny <> x
WITH nx_list + collect(Ny) AS union_list, intersect_size, x, y
UNWIND union_list AS union_node
RETURN x.node_id AS cited_1, y.node_id AS cited_2,
       toFloat(intersect_size) / (count(DISTINCT union_node) + 2) AS jaccard_co_citation_star_index;

// Jaccard Co-Citation* Index: |N(xy) = Co-citing set|/|NxUNy = N*(x) union with N*(y)| with Postgres input
// 1.6-? s
WITH $DB_conn_string AS db,
     '
     SELECT x, y FROM
     (
       VALUES
         (9482260, 14949207)
     ) AS t(x, y)
     ' AS sql
CALL apoc.load.jdbc(db, sql) YIELD row
MATCH (x:Publication {node_id: row.x})<--(Nxy)-->(y:Publication {node_id: row.y})
WITH count(Nxy) AS intersect_size, x, y
MATCH (x)<--(Nx)
  WHERE Nx <> y
WITH collect(Nx) AS nx_list, intersect_size, x, y
MATCH (y)<--(Ny)
  WHERE Ny <> x
WITH nx_list + collect(Ny) AS union_list, intersect_size, x, y
UNWIND union_list AS union_node
RETURN x.node_id AS cited_1, y.node_id AS cited_2,
       toFloat(intersect_size) / (count(DISTINCT union_node) + 2) AS jaccard_co_citation_star_index;

// Jaccard Co-Citation* Index: |N(xy) = Co-citing set|/|NxUNy = N*(x) union with N*(y)|
/*
cited_1	cited_2   result                time (s)
9482260 14949207  0.13694410297201534   1.4-?
*/
MATCH (x:Publication {node_id: $cited_1})<--(Nxy)-->(y:Publication {node_id: $cited_2})
WITH count(Nxy) AS intersect_size, x, y
MATCH (x)<--(Nx)
  WHERE Nx <> y
WITH collect(Nx) AS nx_list, intersect_size, x, y
MATCH (y)<--(Ny)
  WHERE Ny <> x
WITH nx_list + collect(Ny) AS union_list, intersect_size, x, y
UNWIND union_list AS union_node
RETURN x.node_id AS cited_1, y.node_id AS cited_2,
       toFloat(intersect_size) / (count(DISTINCT union_node) + 2) AS jaccard_co_citation_star_index;

// Jaccard Co-Citation* Index: |N(xy) = Co-citing set|/|NxUNy = N*(x) union with N*(y)|
/*
cited_1	cited_2   result              time (s)
9482260 14949207  0.13694410297201534 610-661
*/
MATCH (x:Publication {node_id: $cited_1})<--(Nxy)-->(y:Publication {node_id: $cited_2})
WITH count(Nxy) AS intersect_size, x, y
MATCH (x)<--(Nx)
WITH collect(Nx) + x AS nx_list, intersect_size, x, y
MATCH (y)<--(Ny)
WITH nx_list + y + collect(Ny) AS union_list, intersect_size, x, y
UNWIND union_list AS union_node
RETURN x.node_id AS cited_1, y.node_id AS cited_2,
       toFloat(intersect_size) / count(DISTINCT union_node) AS jaccard_co_citation_star_index;

// Jaccard Co-Citation Index: |N(xy) = Co-citing set|/|NxUNy = N(x) union with N(y)|
/*
cited_1	cited_2     time (s)
474	    84870231656 0.9
2224	  1156126     0.7
2224	  33751141500 4.6
4532	  320221      1.1
4532	  371265      0.3

94582260 14949207   1.3-?
*/
MATCH (x:Publication {node_id: $cited_1})<--(Nxy)-->(y:Publication {node_id: $cited_2})
WITH count(Nxy) AS intersect_size, x, y
MATCH (x)<--(Nx)
WITH collect(Nx) AS nx_list, intersect_size, x, y
MATCH (y)<--(Ny)
WITH nx_list + collect(Ny) AS union_list, intersect_size, x, y
UNWIND union_list AS union_node
RETURN x.node_id AS cited_1, y.node_id AS cited_2,
       toFloat(intersect_size) / count(DISTINCT union_node) AS jaccard_co_citation_index;

// |NxUNy = N*(x) union with N*(y)|
// *runaway*
MATCH (NxUNy)
  WHERE exists((:Publication {node_id: '17538003'})<--(NxUNy)) OR exists((NxUNy)-->(:Publication {node_id: '18983824'}))
RETURN count(NxUNy);

// |N*(xy) = Co-citing set|
// 0.06s
MATCH (x:Publication {node_id: '17538003'})<--(Nxy)-->(y:Publication {node_id: '18983824'})
RETURN count(Nxy);
// 62

// E(x,y)/(|N(x)|*|N(y)|)
// 1.1s
MATCH (x:Publication {node_id: '17538003'})<--(Nxy:Publication)-->(y:Publication {node_id: '18983824'})
WITH min(toInteger(Nxy.pub_year)) AS first_co_citation_year, x, y
MATCH (Nx:Publication)-->(x)
  WHERE toInteger(Nx.pub_year) <= first_co_citation_year
WITH count(Nx) AS cnx, first_co_citation_year, x, y
MATCH (Ny:Publication)-->(y)
  WHERE toInteger(Ny.pub_year) <= first_co_citation_year
WITH count(Ny) AS cny, cnx, first_co_citation_year, x, y
MATCH (x)<--(Ex:Publication)-[E]-(Ey:Publication)-->(y)
  WHERE toInteger(startNode(E).pub_year) <= first_co_citation_year
RETURN toFloat(count(E)) / (cnx * cny);
// 0.08181818181818182

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