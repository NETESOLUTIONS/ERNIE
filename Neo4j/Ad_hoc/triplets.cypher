/*
Find references a,b,c of this paper P (published between 1985 and 1995, article type = 'ar') which are
(1) published later than 1970
(2) have been cited by at least 254 times across all scopus
*/
MATCH (a:Publication)<--(p:Publication)-->(b:Publication), (p)-->(c:Publication)
  WHERE p.pub_year = 1995 AND p.citation_type = 'ar'
  AND a.pub_year >= 1970 AND a.pub_year <= 1995 AND a.node_id <> p.node_id AND size(()-->(a)) >= 254
  AND b.pub_year >= 1970 AND b.pub_year <= 1995 AND b.node_id <> p.node_id AND size(()-->(b)) >= 254
  AND c.pub_year >= 1970 AND c.pub_year <= 1995 AND c.node_id <> p.node_id AND size(()-->(c)) >= 254
  AND a.node_id < b.node_id < c.node_id
RETURN p.node_id as citing_paper, a.node_id AS scp1, b.node_id AS scp2, c.node_id AS scp3, size(()-->(a)) as scp1_citations, size(()-->(b)) as scp2_citations, size(()-->(c)) as scp3_citations;
