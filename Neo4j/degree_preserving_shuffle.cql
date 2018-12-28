// The Hunger method: x swaps (per # of relationships)
// Assumes all relationships of the same type
CALL apoc.periodic.iterate(
  "MATCH ()-[r]->() RETURN r",
  "// Retrieve a random relationship
  MATCH (u)-[r1]->(v)
  WITH *
  ORDER BY rand()
  LIMIT 1
  // Retrieve a second random relationship that is eligible for swapping
  MATCH (x)-[r2]->(y)
  WHERE x <> u AND y <> v
    AND NOT exists((u)-->(y))
    AND NOT exists((x)-->(v))
  WITH *
  ORDER BY rand()
  LIMIT 1
  // Execute the swap
  DELETE r1, r2
  WITH *
  CALL apoc.create.relationship(u, type(r1), {}, y) YIELD rel
  WITH x, r1, v, rel AS nr1
  CALL apoc.create.relationship(x, type(r1), {}, v) YIELD rel
  RETURN nr1, rel AS nr2",
  {}
);

// The Hunger method: 1 swap
// Assumes all relationships of the same type
// Retrieve a random relationship
MATCH (u)-[r1]->(v)
WITH *
ORDER BY rand()
LIMIT 1
// Retrieve a second random relationship that is eligible for swapping
MATCH (x)-[r2]->(y)
WHERE x <> u AND y <> v
  AND NOT exists((u)-->(y))
  AND NOT exists((x)-->(v))
WITH *
ORDER BY rand()
LIMIT 1
// Execute the swap
DELETE r1, r2
WITH *
CALL apoc.create.relationship(u, type(r1), {}, y) YIELD rel
WITH x, r1, v, rel AS nr1
CALL apoc.create.relationship(x, type(r1), {}, v) YIELD rel
RETURN nr1, rel AS nr2
;