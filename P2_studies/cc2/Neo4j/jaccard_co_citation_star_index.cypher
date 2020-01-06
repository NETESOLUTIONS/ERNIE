// Jaccard Co-Citation* Index
WITH collect({x_scp: row.cited_1, y_scp: row.cited_2}) AS pairs
CALL apoc.cypher.mapParallel2('
  MATCH (x:Publication {node_id: _.x_scp})<--(Nxy)-->(y:Publication {node_id: _.y_scp})
  WITH count(Nxy) AS intersect_size, _.x_scp AS x_scp, _.y_scp AS y_scp
  OPTIONAL MATCH (x:Publication {node_id: x_scp})<--(Nx:Publication)
    WHERE Nx.node_id <> y_scp
  WITH collect(Nx) AS nx_list, intersect_size, x_scp, y_scp
  OPTIONAL MATCH (y:Publication {node_id: y_scp})<--(Ny:Publication)
    WHERE Ny.node_id <> x_scp
  WITH nx_list + collect(Ny) AS union_list, intersect_size, x_scp, y_scp
  UNWIND union_list AS union_node
  RETURN x_scp, y_scp, toFloat(intersect_size) / (count(DISTINCT union_node) + 2) AS jaccard_index;',
{}, pairs, 8) YIELD value
RETURN value.x_scp AS cited_1, value.y_scp AS cited_2, value.jaccard_index AS jaccard_co_citation_star_index;