# script for Graclus heatmap
# in S&B paper

rm(list=ls())
library(data.table); library(ggplot2)
setwd('~/Desktop/dblp')
x <- fread('dblp_graclus2_heatmap_data.csv')

# reduce to columns of interest
x1 <- x[,.(cluster_20,source_id,class_code,minor_subject_area)]
# pub counts per msa
x2 <- x1[,.(length(source_id)),by=c('cluster_20','minor_subject_area')]
# for normalizing counts to each cluster
x3 <- x[,.(totalpubs=length(unique(source_id))),by='cluster_20']
# merging x2 and x3
x4 <- merge(x2,x3,by.x='cluster_20',by.y='cluster_20')
# reduce x4 to those msas of at least 15%.
x4 <- x4[,perc:=round(100*V1/totalpubs)]
x4 <- x4[round(100*V1/totalpubs) >=15][,.(cluster_20,minor_subject_area,perc)]

pdf('scopus_dblp_graclus3.pdf',h=7.5,w=10.5)
qplot(as.factor(cluster_20),minor_subject_area,data=x4) + geom_tile(aes(fill = perc)) + 
scale_fill_gradient2(low = "grey", high = "black", guide = "colorbar") + 
ggtitle("DBLP Publications 1996-2015 \n ASJC Minor Subject Areas") + xlab("Cluster No") + 
ylab("ASJC Minor Subjects") +
labs(fill = "% Cluster \n Count")
dev.off()
system("cp scopus_dblp_graclus3.pdf ~/ernie_comp/Scientometrics")
