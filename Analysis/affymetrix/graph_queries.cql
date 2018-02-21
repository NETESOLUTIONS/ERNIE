// a) Shortest paths from each element in startref:true to endref:true (of length <= 2)
MATCH path=(:Publication {startref:true})-[*..2]->(:Publication {endref:true})
RETURN path;