/*
 Theta-Omega Prime Index: for a co-cited publication pair (x,y)

# Let fccy = min(co-citing paper publication year)
# Let X = the set of publications that cite x and published in a year <= fccy
# Let Y = the set of publications that cite Y and published in a year <= fccy
# Let X' = X - Y (that is, minus intersection) and Y' = Y - X.
# Then Theta-Omega Prime Index = |edges between X' and Y'| / (|X'| * |Y'|) if |X'| * |Y'| <> 0 else it is = 0.
*/
UNWIND $input_data AS row
OPTIONAL MATCH (x:Publication {node_id: row.cited_1})<--(X_prime:Publication)
  WHERE X_prime.pub_year <= row.first_co_cited_year AND NOT exists((:Publication {node_id: row.cited_2})<--(X_prime))
OPTIONAL MATCH (y:Publication {node_id: row.cited_2})<--(Y_prime:Publication)
  WHERE Y_prime.pub_year <= row.first_co_cited_year AND NOT exists((:Publication {node_id: row.cited_1})<--(Y_prime))
OPTIONAL MATCH (X_prime)-[e]-(Y_prime)
  WHERE startNode(e).pub_year <= row.first_co_cited_year
RETURN row.cited_1 AS cited_1, row.cited_2 AS cited_2,
       CASE WHEN count(X_prime) * count(Y_prime) = 0 THEN 0
         ELSE toFloat(count(e)) / (count(X_prime) * count(Y_prime))
         END
       AS theta_omega_prime_index;