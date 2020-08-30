lapply(dbListConnections(drv = dbDriver("PostgreSQL")), function(x) {dbDisconnect(conn = x)})
library(data.table); library(ggplot2);library(bit64)
# con <- dbConnect(RPostgres::Postgres(), host="localhost", dbname="ernie", user="", password="")
half_1985 <- dbGetQuery(con, "select * from imm1985_match_to_graclus_half_mclsize;")
half_1990 <- dbGetQuery(con, "select * from imm1990_match_to_graclus_half_mclsize;")
half_1995 <- dbGetQuery(con, "select * from imm1995_match_to_graclus_half_mclsize;")
# clean up integer64 types by converting to numeric

setDT(half_1985); setDT(half_1990); setDT(half_1995); 
half_1985[,names(half_1985):=lapply(.SD,as.numeric)]
half_1990[,names(half_1990):=lapply(.SD,as.numeric)]
half_1995[,names(half_1995):=lapply(.SD,as.numeric)]

# create focused subsets
f90_85 <- half_1985[intersect_union_ratio >=0.9 & mcl_cluster_size >=30 & graclus_cluster_size >=30]
f90_90 <- half_1990[intersect_union_ratio >=0.9 & mcl_cluster_size >=30 & graclus_cluster_size >=30]
f90_95 <- half_1995[intersect_union_ratio >=0.9 & mcl_cluster_size >=30 & graclus_cluster_size >=30]