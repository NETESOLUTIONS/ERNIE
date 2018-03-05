CREATE INDEX ON :Publication(startref);
CREATE INDEX ON :Publication(endref);
CREATE INDEX ON :Publication(nida_support);
CREATE INDEX ON :Publication(other_hhs_support);
CREATE INDEX ON :Publication(wos_id);

// a) Shortest paths from each element in startref:true to endref:true (of length <= 2)
MATCH path=({startref:true})-[*..2]->({endref:true})
RETURN path;

// b) top 10 most frequently used nodes in *all* paths (of length <= 4)
MATCH path=({startref:true})-[*..4]->({endref:true})
WITH nodes(path) AS nodes, relationships(path) AS edges
MATCH (n)-[r]-()
WHERE n IN nodes AND r IN edges
RETURN n, count(r)
ORDER BY count(r) DESC
LIMIT 10;

// c) Paths that go through at least one nida_support node (of length <= 5)
MATCH path=({startref:true})-[*..4]->(n {nida_support: true})-[*..4]->({endref:true})
WHERE length(path) <= 5
RETURN path;