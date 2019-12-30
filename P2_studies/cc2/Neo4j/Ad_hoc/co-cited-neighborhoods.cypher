// E(x,y)/|N(x)|*|N(y)|
// 0.1s
MATCH (Nx)-->(x:Publication {node_id: '17538003'})
WITH count(Nx) AS cnx
MATCH (Ny)-->(y:Publication {node_id: '18983824'})
WITH cnx, count(Ny) AS cny
MATCH (x:Publication {node_id: '17538003'})<--(Nx)-[E]-(Ny)-->(y:Publication {node_id: '18983824'})
RETURN toFloat(count(E))/(cnx*cny);

// E(x,y)/|N(x)|*|N(y)|
// 1.0-1.1s
MATCH (Nx)-->(x:Publication {node_id: '17538003'})
WITH count(Nx) AS cnx, x
MATCH (Ny)-->(y:Publication {node_id: '18983824'})
WITH cnx, count(Ny) AS cny, x, y
MATCH (x)<--(Ex)-[E]-(Ey)-->(y)
RETURN toFloat(count(E))/(cnx*cny);

// |N(x)|
// 0.02s
MATCH (Nx)-->(x:Publication {node_id: '17538003'})
RETURN count(Nx);
// 792

// |N(y)|
// 0.02s
MATCH (Ny)-->(y:Publication {node_id: '18983824'})
RETURN count(Ny);
// 177

// E(x,y)
// 0.05s
MATCH (x:Publication {node_id: '17538003'})<--(Ex)-[E]-(Ey)-->(y:Publication {node_id: '18983824'})
RETURN count(E);
// 1166