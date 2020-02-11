/*
 Theta-Omega Prime Index: for a co-cited publication pair (x,y)

# Let fccy = min(co-citing paper publication year)
# Let X = the set of publications that cite x and published in a year <= fccy
# Let Y = the set of publications that cite y and published in a year <= fccy
# Let X' = X - Y (that is, minus the intersection) and Y' = Y - X.
# Then Theta-Omega Prime Index = |edges between X' and Y'| / (|X'| * |Y'|) if |X'| * |Y'| <> 0 else it is = 0.
*/
UNWIND $input_data AS row
WITH row.first_co_cited_year AS f_c_c_y, row.cited_1 AS x_scp, row.cited_2 AS y_scp
OPTIONAL MATCH (x:Publication {node_id: x_scp})<--(X_prime:Publication)
  WHERE X_prime.pub_year <= f_c_c_y AND NOT exists((:Publication {node_id: y_scp})<--(X_prime))
WITH count(X_prime) AS X_prime_size, f_c_c_y, x_scp, y_scp
OPTIONAL MATCH (y:Publication {node_id: y_scp})<--(Y_prime:Publication)
  WHERE Y_prime.pub_year <= f_c_c_y AND NOT exists((:Publication {node_id: x_scp})<--(Y_prime))
WITH count(Y_prime) AS Y_prime_size, X_prime_size, f_c_c_y, x_scp, y_scp
OPTIONAL MATCH
  (x:Publication {node_id: x_scp})<--(X_prime:Publication)-[e]-(Y_prime:Publication)-->(y:Publication {node_id: y_scp})
  WHERE startNode(e).pub_year <= f_c_c_y
RETURN x_scp AS cited_1, y_scp AS cited_2,
       CASE WHEN X_prime_size * Y_prime_size = 0 THEN 0
         ELSE toFloat(count(e)) / (X_prime_size * Y_prime_size)
         END
       AS theta_omega_prime_index;