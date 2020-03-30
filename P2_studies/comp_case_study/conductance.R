# script for conductance measurements plot
# in S&B paper

rm(list=ls())
setwd('~/Desktop/dblp')
x <- fread('~/Desktop/dblp/dblp_graclus2_edgelist_clusters_18.csv')
x1 <- x[citing_cluster!=cited_cluster,.(ext_out=length(citing)),by='citing_cluster'][order(citing_cluster)]
x2 <- x[citing_cluster!=cited_cluster,.(ext_in=length(citing)),by='cited_cluster'][order(cited_cluster)]
x3 <- x[citing_cluster==cited_cluster,.(int_edges=length(citing)),by='cited_cluster'][order(cited_cluster)]
x4 <- merge(x1,x2,by.x='citing_cluster',by.y='cited_cluster')
x5 <- merge(x4,x3,by.x='citing_cluster',by.y='cited_cluster')
x5[,`:=`(boundary=ext_out+ext_in,volume=ext_out+ext_in+2*int_edges),by='citing_cluster']
x5[,two_m:=dim(x)[1]*2]
x5[,alt_denom:=two_m-volume]
x5[,denom:=min(alt_denom,volume),by='citing_cluster']
x5[,conductance:=round(boundary/denom,2)]
colnames(x5)[1] <- 'cluster'
g18 <- x5[order(conductance)]

x <- fread('~/Desktop/dblp/dblp_graclus2_edgelist_clusters_20.csv')
x1 <- x[citing_cluster!=cited_cluster,.(ext_out=length(citing)),by='citing_cluster'][order(citing_cluster)]
x2 <- x[citing_cluster!=cited_cluster,.(ext_in=length(citing)),by='cited_cluster'][order(cited_cluster)]
x3 <- x[citing_cluster==cited_cluster,.(int_edges=length(citing)),by='cited_cluster'][order(cited_cluster)]
x4 <- merge(x1,x2,by.x='citing_cluster',by.y='cited_cluster')
x5 <- merge(x4,x3,by.x='citing_cluster',by.y='cited_cluster')
x5[,`:=`(boundary=ext_out+ext_in,volume=ext_out+ext_in+2*int_edges),by='citing_cluster']
x5[,two_m:=dim(x)[1]*2]
x5[,alt_denom:=two_m-volume]
x5[,denom:=min(alt_denom,volume),by='citing_cluster']
x5[,conductance:=round(boundary/denom,2)]
colnames(x5)[1] <- 'cluster'
g20 <- x5[order(conductance)]

x <- fread('~/Desktop/dblp/dblp_graclus2_edgelist_clusters_22.csv')
x1 <- x[citing_cluster!=cited_cluster,.(ext_out=length(citing)),by='citing_cluster'][order(citing_cluster)]
x2 <- x[citing_cluster!=cited_cluster,.(ext_in=length(citing)),by='cited_cluster'][order(cited_cluster)]
x3 <- x[citing_cluster==cited_cluster,.(int_edges=length(citing)),by='cited_cluster'][order(cited_cluster)]
x4 <- merge(x1,x2,by.x='citing_cluster',by.y='cited_cluster')
x5 <- merge(x4,x3,by.x='citing_cluster',by.y='cited_cluster')
x5[,`:=`(boundary=ext_out+ext_in,volume=ext_out+ext_in+2*int_edges),by='citing_cluster']
x5[,two_m:=dim(x)[1]*2]
x5[,alt_denom:=two_m-volume]
x5[,denom:=min(alt_denom,volume),by='citing_cluster']
x5[,conductance:=round(boundary/denom,2)]
colnames(x5)[1] <- 'cluster'
g22 <- x5[order(conductance)]

rm(x);rm(x1);rm(x2);rm(x3);rm(x4);rm(x5);

g18 <- g18[,.(cluster,conductance)]
g20 <- g20[,.(cluster,conductance)]
g22 <- g22[,.(cluster,conductance)]

g22_20 <- merge(g22,g20,by.x='cluster',by.y='cluster',all.x=T)
g22_20_18 <- merge(g22_20,g18,by.x='cluster',by.y='cluster',all.x=T)
# g22_20_18[is.na(g22_20_18)] <- 0
colnames(g22_20_18) <- c('cluster','grac_22','grac_20','grac_18')
mg <- melt(g22_20_18,id='cluster')
pdf('graclus_comparison.pdf')
qplot(as.factor(cluster),value,group=variable,data=mg,color=variable,geom=c('line','point'),ylab="conductance",xlab='cluster')
dev.off()

tiff("graclus_comparison.tif", res=600, compression = "lzw", height=8, width=7, units="in")
qplot(as.factor(cluster),value,group=variable,data=mg,color=variable,geom=c('line','point'),ylab="conductance",xlab='cluster')
dev.off()

