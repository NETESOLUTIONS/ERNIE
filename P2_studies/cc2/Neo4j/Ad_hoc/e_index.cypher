// E(x,y)/(|N(x)|*|N(y)|)
// 1.1s
MATCH (x:Publication {node_id: '17538003'})<--(Nxy:Publication)-->(y:Publication {node_id: '18983824'})
WITH min(toInteger(Nxy.pub_year)) AS first_co_citation_year, x, y
MATCH (Nx:Publication)-->(x)
  WHERE toInteger(Nx.pub_year) <= first_co_citation_year
WITH count(Nx) AS cnx, first_co_citation_year, x, y
MATCH (Ny:Publication)-->(y)
  WHERE toInteger(Ny.pub_year) <= first_co_citation_year
WITH count(Ny) AS cny, cnx, first_co_citation_year, x, y
MATCH (x)<--(Ex:Publication)-[E]-(Ey:Publication)-->(y)
  WHERE toInteger(startNode(E).pub_year) <= first_co_citation_year
RETURN toFloat(count(E)) / (cnx * cny);
// 0.08181818181818182

// |N(x)|
// 2.4s
MATCH (x:Publication {node_id: '17538003'})<--(Nxy:Publication)-->(y:Publication {node_id: '18983824'})
WITH min(toInteger(Nxy.pub_year)) AS first_co_citation_year, x
MATCH (Nx:Publication)-->(x)
  WHERE toInteger(Nx.pub_year) <= first_co_citation_year
RETURN count(Nx);
// 22

// |N(y)|
// 0.04s
MATCH (x:Publication {node_id: '17538003'})<--(Nxy:Publication)-->(y:Publication {node_id: '18983824'})
WITH min(toInteger(Nxy.pub_year)) AS first_co_citation_year, y
MATCH (Ny:Publication)-->(y)
  WHERE toInteger(Ny.pub_year) <= first_co_citation_year
RETURN count(Ny);
// 5

// E(x,y)
// 1.1s
MATCH (x:Publication {node_id: '17538003'})<--(Nxy:Publication)-->(y:Publication {node_id: '18983824'})
WITH min(toInteger(Nxy.pub_year)) AS first_co_citation_year, x, y
OPTIONAL MATCH (x)<--(Ex:Publication)-[E]-(Ey:Publication)-->(y)
  WHERE toInteger(startNode(E).pub_year) <= first_co_citation_year
WITH collect(E) AS edges, first_co_citation_year, x, y
OPTIONAL MATCH (x)<--(y)<-[E]-(Ey:Publication)
  WHERE toInteger(startNode(E).pub_year) <= first_co_citation_year
WITH collect(E) + edges AS edges, first_co_citation_year, x, y
OPTIONAL MATCH (y)<--(x)<-[E]-(Ex:Publication)
  WHERE toInteger(startNode(E).pub_year) <= first_co_citation_year
WITH collect(E) + edges AS edges
UNWIND edges AS edge
RETURN count(DISTINCT edge);
// 14

// E(x,y) on N*(x) and N*(y) result set
MATCH (x:Publication {node_id: '17538003'})<--(Nxy:Publication)-->(y:Publication {node_id: '18983824'})
WITH min(toInteger(Nxy.pub_year)) AS first_co_citation_year, x, y
OPTIONAL MATCH (x)<--(Ex:Publication)-[E]-(Ey:Publication)-->(y)
  WHERE toInteger(startNode(E).pub_year) <= first_co_citation_year
WITH collect(E) AS edges, first_co_citation_year, x, y
OPTIONAL MATCH (x)<--(y)<-[E]-(Ey:Publication)
  WHERE toInteger(startNode(E).pub_year) <= first_co_citation_year
WITH collect(E) + edges AS edges, first_co_citation_year, x, y
OPTIONAL MATCH (y)<--(x)<-[E]-(Ex:Publication)
  WHERE toInteger(startNode(E).pub_year) <= first_co_citation_year
WITH collect(E) + edges AS edges
UNWIND edges AS edge
RETURN DISTINCT toInteger(startNode(edge).node_id), toInteger(endNode(edge).node_id);
// 14

// Year of the first co-citation
MATCH (x:Publication {node_id: '17538003'})<--(Nxy:Publication)-->(y:Publication {node_id: '18983824'})
RETURN min(toInteger(Nxy.pub_year));