// Mutually citing papers
MATCH (x)-->(y), (y)-->(x)
RETURN *
LIMIT 2;

// Self-citing papers
MATCH (x)-->(x)
RETURN *;

/*
{"pub_year":"2019","node_id":"85057159136"}}, {"pub_year":"2019","node_id":"85056585985"}
*/

// Count of edges
MATCH (x:Publication {node_id: "85057159136"})-[e]-(y:Publication {node_id: "85056585985"})
RETURN count(e);