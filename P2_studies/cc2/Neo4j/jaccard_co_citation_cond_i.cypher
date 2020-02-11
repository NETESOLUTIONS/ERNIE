/*
Jaccard Co-Citation Conditional (<= first_co_citation_year) Index

# Let fccy = min(co-citing paper publication year)
# Let X = the set of publications that cite x and published in a year <= fccy
# Let Y = the set of publications that cite y and published in a year <= fccy
# Let XY = X * Y (that is, the intersection)
# Then Jaccard Co-Citation Conditional Index = |XY| / (|X| + |Y| - |XY|)
*/
UNWIND $input_data AS row
OPTIONAL MATCH (x:Publication {node_id: row.cited_1})<--(X:Publication)
  WHERE X.pub_year <= row.first_co_cited_year
OPTIONAL MATCH (y:Publication {node_id: row.cited_2})<--(Y:Publication)
  WHERE Y.pub_year <= row.first_co_cited_year
OPTIONAL MATCH (XY:Publication)
  WHERE XY.node_id = X.node_id AND XY.node_id = Y.node_id
RETURN row.cited_1 AS cited_1, row.cited_2 AS cited_2,
       toFloat(count(XY)) / (count(X) + count(Y) - count(XY)) AS jaccard_co_citation_conditional_index;