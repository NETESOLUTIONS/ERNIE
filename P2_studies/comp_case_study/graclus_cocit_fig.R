# script to reconcile dc with co-c
# for S&B paper

rm(list=ls())
setwd('~/Desktop/dblp')
library(data.table)
x <- fread('graclus_cocitation_clusters.csv')
x1 <- x[order(graclus_cluster,-co_citation_nodes)]
nl <- fread('nl_scp_top20.csv')
nl1 <- nl[,.(cocit_cluster_total=length(source_id)),by='cluster_no']
merged <- merge(x1,nl1,by.x='co_citation_cluster',by.y='cluster_no')
merged[,perc:=round(100*co_citation_nodes/cocit_cluster_total)]
library(ggplot2)
pmerge <- merged[perc>=15][order(graclus_cluster)]
pdf('graclus_cocit_fig.pdf')
qplot(as.factor(graclus_cluster),as.factor(co_citation_cluster),data=pmerge,size=perc,xlab="Cluster ID (Direct Citation)",ylab="Cluster ID (Co-citation)")
dev.off()
system("cp graclus_cocit_fig.pdf ~/ernie_comp/Scientometrics")

tiff("graclus_cocit_fig.tif", res=600, compression = "lzw", height=8, width=8, units="in")
qplot(as.factor(graclus_cluster),as.factor(co_citation_cluster),data=pmerge,size=perc,xlab="Cluster ID (Direct Citation)",ylab="Cluster ID (Co-citation)")
dev.off()


