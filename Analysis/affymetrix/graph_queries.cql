// region Setup
CREATE INDEX ON :Publication(endpoint);

CREATE INDEX ON :Publication(nida_support);

CREATE INDEX ON :Publication(other_hhs_support);

// Calculate and store PageRank
CALL algo.pageRank()
YIELD nodes, iterations, loadMillis, computeMillis, writeMillis, dampingFactor, write, writeProperty

// Calculate and store Betweenness Centrality
CALL algo.betweenness(null, null, {writeProperty: 'betweenness'})
YIELD nodes, minCentrality, maxCentrality, sumCentrality, loadMillis, computeMillis, writeMillis

// Calculate and store Closeness Centrality
CALL algo.closeness(null, null, {writeProperty: 'closeness'})
YIELD nodes, loadMillis, computeMillis, writeMillis

// PageRank statistics
MATCH (n)
RETURN apoc.agg.statistics(n.pagerank);
//{
//  "total": 372286,
//  "min": 0.14999961853027344,
//  "minNonZero": 0.14999961853027344,
//  "max": 21261.374999046326,
//  "mean": 0.6435025747443703,
//  "0.5": 0.14999961853027344,
//  "0.99": 4.725462913513184,
//  "0.75": 0.14999961853027344,
//  "0.9": 0.14999961853027344,
//  "0.95": 0.14999961853027344,
//  "stdev": 41.08246365590009
//}
// endregion

// region Testing
// Test sub-graph
MATCH p = (a {endpoint: 'startref1'})-->(n {publication_year: 2002})
  WHERE a.pagerank >= 0.19
RETURN p
// endregion

//region Starting from startref1 nodes
// 1) Shortest paths from startref1 to endref (count, avg length)
// 15.7s
MATCH p = allShortestPaths((a {endpoint: 'startref1'})-[*]->(b {endpoint: 'endref'}))
RETURN count(p), avg(length(p));
// 662, 4.66

// 2) Shortest paths passing through at least one nida_support node from startref1 to endref (count, avg length)
// 15.6s
MATCH p = allShortestPaths((a {endpoint: 'startref1'})-[*]->(b {endpoint: 'endref'}))
WITH p
  WHERE any(x IN nodes(p)
    WHERE x.nida_support)
RETURN count(p), avg(length(p));
// 0, null

// 3) Shortest paths passing through at least one other_hhs_support node from startref1 to endref (count, avg length)
// 16.2s
MATCH p = allShortestPaths((a {endpoint: 'startref1'})-[*]->(b {endpoint: 'endref'}))
WITH p
  WHERE any(x IN nodes(p)
    WHERE x.other_hhs_support)
RETURN count(p), avg(length(p));
// 465, 4.84

// 4) All possible paths from startref1 to endref <= 10 segments (count, avg length)
// 33m:01s
MATCH p = (a {endpoint: 'startref1'})-[*..10]->(b {endpoint: 'endref'})
RETURN count(p), avg(length(p));
// 128,597,162, 9.83

// 5) Overall PageRank stats for nodes in all shortest paths: percentiles, min, max, mean, stdev
// 10.3s
MATCH p = allShortestPaths((a {endpoint: 'startref1'})-[*]->(b {endpoint: 'endref'}))
UNWIND nodes(p) AS path_node
WITH DISTINCT path_node AS n
RETURN apoc.agg.statistics(n.pagerank);
//{
//  "total": 130,
//  "min": 0.14999961853027344,
//  "minNonZero": 0.14999961853027344,
//  "max": 21261.374999046326,
//  "mean": 464.0958069067735,
//  "0.5": 3.0050344467163086,
//  "0.99": 5554.593749046326,
//  "0.75": 66.22021389007568,
//  "0.9": 730.9999990463257,
//  "0.95": 2514.4374990463257,
//  "stdev": 2050.5156984354744
//}

// 6) Shortest paths passing through one or more high-value PageRank nodes (>= 99th percentile)
// 10.4s
MATCH p = allShortestPaths((a {endpoint: 'startref1'})-[*]->(b {endpoint: 'endref'}))
// WITH is required here otherwise WHERE predicates that apply to the shortest path pattern would be
// evaluated *before* deciding what the shortest matching path is.
WITH p
  WHERE any(x IN nodes(p)
    WHERE x <> a AND x <> b AND x.pagerank > 4.725)
RETURN count(p)
// 645

// Top 10 most frequently used nodes in *all* paths <= 10 segments
MATCH path = ((a {endpoint:'startref1'}) - [ *..10] - >(b {endpoint:'endref'}))

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
MATCH p = allShortestPaths((a {endpoint: 'startref2'})-[*]->(b {endpoint: 'endref'}))
RETURN count(p), avg(length(p));
// 1706, 5.28

// 2) Shortest paths passing through at least one nida_support node from startref2 to endref (count, avg length)
// 21.2s
MATCH p = allShortestPaths((a {endpoint: 'startref2'})-[*]->(b {endpoint: 'endref'}))
WITH p
  WHERE any(x IN nodes(p)
    WHERE x.nida_support)
RETURN count(p), avg(length(p));
// 0, null

// 3) Shortest paths passing through at least one other_hhs_support node from startref2 to endref (count, avg length)
// 21.3s
MATCH p = allShortestPaths((a {endpoint: 'startref2'})-[*]->(b {endpoint: 'endref'}))
WITH p
  WHERE any(x IN nodes(p)
    WHERE x.other_hhs_support)
RETURN count(p), avg(length(p));
// 945, 5.72

// 4) All possible paths from startref2 to endref <= 10 segments (count, avg length)
// 50m:54s
MATCH p = (a {endpoint: 'startref2'})-[*..10]->(b {endpoint: 'endref'})
RETURN count(p), avg(length(p));
// 156,832,151 9.80

// 5) Overall PageRank stats for nodes in these paths: percentiles, min, max, mean, stdev
// 13.3s
MATCH p = allShortestPaths((a {endpoint: 'startref2'})-[*]->(b {endpoint: 'endref'}))
UNWIND nodes(p) AS path_node
WITH DISTINCT path_node AS n
RETURN apoc.agg.statistics(n.pagerank)
//{
//  "total": 131,
//  "min": 0.14999961853027344,
//  "minNonZero": 0.14999961853027344,
//  "max": 21261.374999046326,
//  "mean": 470.6835533244009,
//  "0.5": 20.877440452575684,
//  "0.99": 5554.593749046326,
//  "0.75": 125.68212795257568,
//  "0.9": 730.9999990463257,
//  "0.95": 1933.3124990463257,
//  "stdev": 2041.2323204254258
//}

// 6) A sub-set of all shortest paths that pass through a high-value PageRank node (>= 99th percentile)
// 15.0s
MATCH p = allShortestPaths((a {endpoint: 'startref2'})-[*]->(b {endpoint: 'endref'}))
// WITH is required here otherwise WHERE predicates that apply to the shortest path pattern would be
// evaluated *before* deciding what the shortest matching path is.
WITH p
  WHERE any(x IN nodes(p)
    WHERE x <> a AND x <> b AND x.pagerank > 4.725)
RETURN count(p)
// 1699
//endregion