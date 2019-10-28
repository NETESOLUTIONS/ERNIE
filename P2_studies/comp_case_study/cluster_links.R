rm(list=ls()); library(data.table); library(reshape2); library(ggplot2)
setwd('~/Desktop/dblp')
dc <- fread('dblp_direct_citations.csv')
bc <- fread('dblp_bibliographic_coupling.csv')
cc <- fread('dblp_co_citation.csv')
counts <- fread('dblp_graclus_counts.csv')
print("***")
print("analyzing dc- direct citation dataset")
print(" ")
print(paste0("dc - has the following number of unique citing scps: ",length(unique(dc$citing))))
print(paste0("dc - has the following number of unique cited scps: ",length(unique(dc$cited))))
print(paste0("Total edges: ",1317198))
print(paste0("Intra-cluster edges and %: ", dim(dc[citing_cluster == cited_cluster])[1]))
print(paste0("Percent intra-cluster edges: ", round(100*(dim(dc[citing_cluster == cited_cluster])[1])/dim(dc)[1],1)))
print(paste0("Inter-cluster edges and %: ",dim(dc[citing_cluster != cited_cluster])[1]))
print(paste0("Percent inter-cluster edges: ", round(100*(dim(dc[citing_cluster != cited_cluster])[1])/dim(dc)[1],1)))

print("***")
print("***")
print(" ")
p <- dc[citing_cluster!=cited_cluster,
.(dc_nodes=length(unique(cited)),dc_edges=length(cited)),by='cited_cluster'][order(cited_cluster)][,dc_ratio:=round(dc_edges/dc_nodes,3)]
p[,dc_rank:=rank(dc_ratio*-1,ties.method='average')]
print("Edge/node ratio clusters (inter-cluster citations only)")
print(p); 

print("***")
print("analyzing bc- bibliographic coupling dataset")
print(" ")
print(paste0("bc - has the following number of bibliographic coupling instances where citing and cited clusters are different: ",dim(bc)[1]))
print(paste0("bc - has the following number of unique bibliographically coupled targets: ",length(unique(bc$cited))))
q <- bc[,.(bc_nodes=length(unique(cited)),bc_edges=length(cited)),by='cited_cluster'][order(cited_cluster)][,
bc_ratio:=round(bc_edges/bc_nodes,3)]
q[,bc_rank:=rank(bc_ratio*-1,ties.method='average')]

print("***")
print("analyzing cc- co-citation dataset")
print(" ")
r <- cc[,.(cc_nodes=(length(unique(citing))),cc_edges=length(citing)),by='citing_cluster'][order(citing_cluster)][,cc_ratio:=round(cc_edges/cc_nodes,3)]
r[,cc_rank:=rank(cc_ratio*-1,ties.method='average')]

p1 <- p[,.(cited_cluster,dc_rank)]
q1 <- q[,.(cited_cluster,bc_rank)]
r1 <- r[,.(citing_cluster,cc_rank)]
p1q1 <- merge(p1,q1,by.x='cited_cluster',by.y='cited_cluster')
p1q1[,dev:=abs(dc_rank-bc_rank)]
merge(counts,p1q1,by.x='cluster_20',by.y='cited_cluster')



