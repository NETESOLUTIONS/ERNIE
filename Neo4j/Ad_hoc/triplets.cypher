/*
Find references a,b,c of this paper P (published between 1985 and 1995, article type = 'ar') which are
(1) published later than 1970
(2) have been cited by at least 254 times across all scopus
*/
MATCH (a:Publication)<--(p:Publication {node_id: 491043})-->(b:Publication),
      (p)-->(c:Publication)
  WHERE p.pub_year >= 1985 AND p.pub_year <= 1995 AND p.citation_type = 'ar'
  AND a.pub_year >= 1970 AND a.node_id <> p.node_id AND size(()-->(a)) >= 254
  AND b.pub_year >= 1970 AND b.node_id <> p.node_id AND size(()-->(b)) >= 254
  AND c.pub_year >= 1970 AND c.node_id <> p.node_id AND size(()-->(c)) >= 254
RETURN a.node_id AS a_scp, b.node_id AS b_scp, c.node_id AS c_scp;