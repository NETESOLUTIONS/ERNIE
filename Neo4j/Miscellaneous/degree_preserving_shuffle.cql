// See "Degree-Preserving Edge-Swap" (https://gist.github.com/dhimmel/f69730d8bdfb880c15ed)

// Optimized swap using ids: x swaps (x <= the number of relationships: a swap could be randomly missed)
// Assumes all relationships are of the same type
CALL apoc.periodic.iterate(
'MATCH ()-[r]->()
WITH collect(id(r)) AS r_ids
UNWIND r_ids AS id
RETURN *',
'// Retrieve 2 random edges eligible for swapping
MATCH (u)-[r1]->(v), (x)-[r2]->(y)
  WHERE id(r1) = r_ids[toInteger(rand() * size(r_ids))]
  AND id(r2) = r_ids[toInteger(rand() * size(r_ids))]
  AND x <> u AND y <> v
  AND NOT exists((u)-->(y))
  AND NOT exists((x)-->(v))
// Execute the swap
DELETE r1, r2
WITH *
CALL apoc.create.relationship(u, type(r1), {}, y) YIELD rel
WITH x, r1, v, rel AS nr1
CALL apoc.create.relationship(x, type(r1), {}, v) YIELD rel
RETURN nr1, rel AS nr2',
{}
);
// 0.78-0.223s on (100, 109) citation network

// The Hunger method: x swaps (x = the number of relationships)
// Assumes all relationships are of the same type
CALL apoc.periodic.iterate(
'MATCH ()-[r]->() RETURN r',
'// Retrieve a random relationship
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
RETURN nr1, rel AS nr2',
{}
);
// 0.149-0.292s on (100, 109) citation network

// Optimized swap using ids: 1 swap (could be randomly missed)
// Assumes all relationships are of the same type
MATCH ()-[r]->()
WITH collect(id(r)) AS r_ids
// Retrieve 2 random edges eligible for swapping
MATCH (u)-[r1]->(v), (x)-[r2]->(y)
  WHERE id(r1) = r_ids[toInteger(rand() * size(r_ids))]
  AND id(r2) = r_ids[toInteger(rand() * size(r_ids))]
  AND x <> u AND y <> v
  AND NOT exists((u)-->(y))
  AND NOT exists((x)-->(v))
// Execute the swap
DELETE r1, r2
WITH *
CALL apoc.create.relationship(u, type(r1), {}, y) YIELD rel
WITH x, r1, v, rel AS nr1
CALL apoc.create.relationship(x, type(r1), {}, v) YIELD rel
RETURN nr1, rel AS nr2
;

// The Hunger method: 1 swap
// Assumes all relationships are of the same type
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

// Node degrees
MATCH (n)
RETURN
  n,
  size((n)<--()) AS in_degree,
  size((n)-->()) AS out_degree
;