CREATE INDEX ON :Publication(endpoint);
CREATE INDEX ON :Publication(nida_support);
CREATE INDEX ON :Publication(other_hhs_support);

//region Starting from startref1 nodes
// 1) Shortest paths from startref1 to endref (count, avg length)
// 15.7s
MATCH p=allShortestPaths((a {endpoint: 'startref1'})-[*]->(b {endpoint: 'endref'}))
RETURN count(p), avg(length(p));
// 662, 4.66

// 2) Shortest paths passing through at least one nida_support node from startref1 to endref (count, avg length)
// 15.6s
MATCH p=allShortestPaths((a {endpoint: 'startref1'})-[*]->(b {endpoint: 'endref'}))
WITH p
WHERE any(x in nodes(p) WHERE x.nida_support)
RETURN count(p), avg(length(p));
// 0, null

// 3) Shortest paths passing through at least one other_hhs_support node from startref1 to endref (count, avg length)
// 16.2s
MATCH p=allShortestPaths((a {endpoint: 'startref1'})-[*]->(b {endpoint: 'endref'}))
WITH p
WHERE any(x in nodes(p) WHERE x.other_hhs_support)
RETURN count(p), avg(length(p));
// 465, 4.84

// 4) All possible paths from startref1 to endref <= 10 segments (count, avg length)
// TODO
// ?
MATCH p=(a {endpoint: 'startref1'})-[*..10]->(b {endpoint: 'endref'})
RETURN count(p), avg(length(p));
// ?

// 5) Overall PageRank stats for nodes in these paths: percentiles, min, max, mean, stdev
// TODO
MATCH p=allShortestPaths((a {endpoint: 'startref1'})-[*]->(b {endpoint: 'endref'}))
RETURN apoc.agg.statistics([x IN nodes(p) | x.pagerank]);

// Top 10 most frequently used nodes in *all* paths <= 10 segments
MATCH path=((a {endpoint: 'startref1'})-[*..10]->(b {endpoint: 'endref'}))
WITH nodes(path) AS nodes, relationships(path) AS edges
MATCH (n)-[r]-()
WHERE n IN nodes AND r IN edges
RETURN n, count(r)
ORDER BY count(r) DESC
LIMIT 10;
//endregion

//region Starting from startref2 nodes
// 1) Shortest paths from startref2 to endref (count, avg length)
// 21.2s
MATCH p=allShortestPaths((a {endpoint: 'startref2'})-[*]->(b {endpoint: 'endref'}))
RETURN count(p), avg(length(p));
// 1706, 5.28

// 2) Shortest paths passing through at least one nida_support node from startref2 to endref (count, avg length)
// 21.2s
MATCH p=allShortestPaths((a {endpoint: 'startref2'})-[*]->(b {endpoint: 'endref'}))
WITH p
WHERE any(x in nodes(p) WHERE x.nida_support)
RETURN count(p), avg(length(p));
// 0, null

// 3) Shortest paths passing through at least one other_hhs_support node from startref2 to endref (count, avg length)
// 21.3s
MATCH p=allShortestPaths((a {endpoint: 'startref2'})-[*]->(b {endpoint: 'endref'}))
WITH p
WHERE any(x in nodes(p) WHERE x.other_hhs_support)
RETURN count(p), avg(length(p));
// 945, 5.72

// 4) All possible paths from startref2 to endref <= 10 segments (count, avg length)
// 50m:54s
MATCH p=(a {endpoint: 'startref2'})-[*..10]->(b {endpoint: 'endref'})
RETURN count(p), avg(length(p));
// 156,832,151 9.80

// 5) Overall PageRank stats for nodes in these paths: percentiles, min, max, mean, stdev
// TODO

//endregion