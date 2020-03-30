#script for agglomerative clustering: generates boxplot in Fig 3(c)
# among others

setwd('~/Desktop/dblp'); library(data.table)
# clear workspace
rm(list=ls())
# read in source data
nl <- fread('cocitations2_nodelist_10plus.csv')
x <- fread('~/Desktop/dblp/dblp_cocit_clustering2_main_edgelist.csv')
# trim edgelist to clusters in nl (have >= 10 nodes/cluster)
x <- x[cited_1 %in% nl$cluster_no][cited_2 %in% nl$cluster_no]
# subset columns and sort intra-row for column 1 and 2
y <- cbind(t(apply(x[,-c(3:6)], 1, sort)),x[,4])
# update column name
colnames(y)[1:2] <- c('cluster_a','cluster_b')
# suppress duplicate rows
y <- unique(y)


# initialize supercounter (cluster numbering index)
supercounter <- max(c(max(y$cluster_a),max(y$cluster_b)))
mergetrace <- data.frame(); 
print(paste("Number of starting clusters is", length(nl$cluster_no),sep=" "))
print(paste("Number of starting nodes is", sum(nl$count),sep=" "))
print(paste("Number of unique clusters in edgelist is",length(union(y$cluster_a,y$cluster_b)),sep=" "))

# For calibrating, I used 100-1200 merges in increments of 100 (merge_select.pdf)
# notes added on 3/29/2020 George Chacko
# to generate the figure run the code below with 100-1200 iterations in 12 different runs
# collect the sizes for the top 20 clusters from each run and then generate a plot in ggplot2


###################################################################################################################################

# sample run for 1200 iterations (below)
# for (i in 1:1200){
# order by max_edge_val (desc) and restrict to 3 columns
# y1 <- y[order(-max_edge_value)]
# extract cluster_a and cluster_b identifiers from y as vector 
# s <- unname(unlist(y1[1,1:2]))
# y1[cluster_a==s[1],cluster_a:=supercounter+1]
# y1[cluster_a==s[2],cluster_a:=supercounter+1]
# y1[cluster_b==s[1],cluster_b:=supercounter+1]
# y1[cluster_b==s[2],cluster_b:=supercounter+1]
# z <- y1[cluster_a==supercounter+1 | cluster_b==supercounter+1][cluster_a!=cluster_b][order(-max_edge_value)]
#increment supercounter
# supercounter <- supercounter+1
# t <- c(s,supercounter)
# mergetrace <- rbind(mergetrace,t)
# rowsort cluster identifiers
# z1 <- data.frame(cbind(t((apply(z[,c(1:2)],1,sort))),z$max_edge_value))
# setDT(z1); colnames(z1) <- c('cluster_a','cluster_b','max_edge_val')
# z2 <- z1[,.(max_edge_value=max(max_edge_val)),by=c('cluster_a','cluster_b')]
# remove clusters merged into supercluster from data.frame
# y <- y[!cluster_a==s[1]][!cluster_a==s[2]][!cluster_b==s[1]][!cluster_b==s[2]]
# y <- rbind(y,z2)
# }
# print(dim(mergetrace))
# print(paste("After",i,"iterations,the number of clusters is", length(union(y$cluster_a,y$cluster_b)),sep=" "))
# nl_scp <- fread('nl_scp.csv')

# update cluster numbers for source_id(scp) counts
# for (i in 1:nrow(mergetrace)) {
# nl[cluster_no==mergetrace[[i,1]],cluster_no:=mergetrace[[i,3]]]
# nl[cluster_no==mergetrace[[i,2]],cluster_no:=mergetrace[[i,3]]]
# }

# colnames(mergetrace) <- c('cited_1','cited_2','merged_cluster')
# nl[,sum(count),by='cluster_no'][order(-V1)]
# v1200 <- nl[,sum(count),by='cluster_no'][order(-V1)][, head(.SD, 20)][,cluster_no]
# fwrite(data.frame(v1200),file='v1200.csv')
# rm(list=ls())
# v100 <- fread('v100.csv')
# v200 <- fread('v200.csv')
# v300 <- fread('v300.csv')
# v400 <- fread('v400.csv')
# v500 <- fread('v500.csv')
# v600 <- fread('v600.csv')
# v700 <- fread('v700.csv')
# v800 <- fread('v800.csv')
# v900 <- fread('v900.csv')
# v1000 <- fread('v1000.csv')
# v1100 <- fread('v1200.csv')
# v1100 <- fread('v1100.csv')
# v1200 <- fread('v1200.csv')
# big_v <_ cbind(v100,v200,v300,v400,v500,v600,v700,v800,v900,v1000,v1100,v1200)
# mbv <- melt(big_v) (can ignore warnings in this case)
# p1 <- qplot(variable,log(value),group=variable,data=mbv,geom="boxplot") (should get you 3(c))
#pdf('merge_select_3392020.pdf')
# print(p1)
# dev.off()

###################################################################################################################################

# resume running code for 600
# to build 20 clusters you need N-20 merges
for (i in 1:600){
# order by max_edge_val (desc) and restrict to 3 columns
y1 <- y[order(-max_edge_value)]
# extract cluster_a and cluster_b identifiers from y as vector 
s <- unname(unlist(y1[1,1:2]))
y1[cluster_a==s[1],cluster_a:=supercounter+1]
y1[cluster_a==s[2],cluster_a:=supercounter+1]
y1[cluster_b==s[1],cluster_b:=supercounter+1]
y1[cluster_b==s[2],cluster_b:=supercounter+1]
z <- y1[cluster_a==supercounter+1 | cluster_b==supercounter+1][cluster_a!=cluster_b][order(-max_edge_value)]
#increment supercounter
supercounter <- supercounter+1
t <- c(s,supercounter)
mergetrace <- rbind(mergetrace,t)
# rowsort cluster identifiers
z1 <- data.frame(cbind(t((apply(z[,c(1:2)],1,sort))),z$max_edge_value))
setDT(z1); colnames(z1) <- c('cluster_a','cluster_b','max_edge_val')
z2 <- z1[,.(max_edge_value=max(max_edge_val)),by=c('cluster_a','cluster_b')]
# remove clusters merged into supercluster from data.frame
y <- y[!cluster_a==s[1]][!cluster_a==s[2]][!cluster_b==s[1]][!cluster_b==s[2]]
y <- rbind(y,z2)
}
print(dim(mergetrace))
print(paste("After",i,"iterations,the number of clusters is", length(union(y$cluster_a,y$cluster_b)),sep=" "))
nl_scp <- fread('nl_scp.csv')

# update cluster numbers for source_id(scp) counts
for (i in 1:nrow(mergetrace)) {
nl[cluster_no==mergetrace[[i,1]],cluster_no:=mergetrace[[i,3]]]
nl[cluster_no==mergetrace[[i,2]],cluster_no:=mergetrace[[i,3]]]
}

colnames(mergetrace) <- c('cited_1','cited_2','merged_cluster')
nl[,sum(count),by='cluster_no'][order(-V1)]
v600 <- nl[,sum(count),by='cluster_no'][order(-V1)][, head(.SD, 20)][,cluster_no]
nl_scp_top20 <- nl_scp[cluster_no %in% nl[,sum(count),by='cluster_no'][order(-V1)][, 
head(.SD, 20)][,cluster_no]]
fwrite(nl_scp_top20,file='nl_scp_top20.csv')