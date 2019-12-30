setwd('/Users/george/Desktop/clustering')
rm(list=ls())
library(data.table); library(ggplot2)

# read in Sitaram's data
x <- fread('leiden_graclus_30_1996_2018_metadata.csv')
x[is.na(x)] <-0 # L0 is smallest cluster and L29 is the largest one

# exclude cited references which are not also pubs
xpubs <- x[publication=='t'] # 36.31% of original number of rows, cluster_no label and cluster size are no longer correlated

# total citations
y<- xpubs[,.(no_pubs=length(source_id),total_citations=sum(citation_count)),by='cluster_no_leiden'][,ratio:=total_citations/no_pubs]
z<- xpubs[,.(no_pubs=length(source_id),total_citations=sum(citation_count)),by='cluster_no_graclus'][,ratio:=total_citations/no_pubs]

y$cluster_no_leiden <- factor(y$cluster_no_leiden,levels=c("L0", "L1", "L2", "L3", "L4","L5","L6", "L7", "L8", "L9","L10", 
"L11" ,"L12", "L13", "L14" ,"L15", "L16", "L17", "L18" ,"L19","L20", "L21", "L22", "L23", "L24", "L25", "L26", "L27", "L28","L29"))
z$cluster_no_graclus <- factor(z$cluster_no_graclus,levels=c("G0", "G1", "G2", "G3", "G4","G5","G6", "G7", "G8", "G9","G10", 
"G11" ,"G12", "G13", "G14" ,"G15", "G16", "G17", "G18" ,"G19","G20", "G21", "G22", "G23", "G24", "G25", "G26", "G27", "G28","G29"))

qplot(cluster_no_leiden,total_citations,data=y,size=no_pubs,group=1)
qplot(cluster_no_graclus,total_citations,data=z,size=no_pubs,group=1)

# Q3 using global quantile measurement
xpubs_q75 <- xpubs[citation_count > quantile(xpubs$citation_count,0.75)]

y<- xpubs_q75[,.(no_pubs=length(source_id),total_citations=sum(citation_count)),by='cluster_no_leiden'][,avg_citations:=total_citations/no_pubs]
y$cluster_no_leiden <- factor(y$cluster_no_leiden,levels=c("L0", "L1", "L2", "L3", "L4","L5","L6", "L7", "L8", "L9","L10", 
"L11" ,"L12", "L13", "L14" ,"L15", "L16", "L17", "L18" ,"L19","L20", "L21", "L22", "L23", "L24", "L25", "L26", "L27", "L28","L29"))
qplot(cluster_no_leiden,avg_citations,data=y,size=no_pubs,group=1,main='Global Q75 citation_count set\n Leiden Clusters',ylab='avg_citations/pub')

z<- xpubs_q75[,.(no_pubs=length(source_id),total_citations=sum(citation_count)),by='cluster_no_graclus'][,avg_citations:=total_citations/no_pubs]
z$cluster_no_graclus <- factor(z$cluster_no_graclus,levels=c("G0", "G1", "G2", "G3", "G4","G5","G6", "G7", "G8", "G9","G10", 
"G11" ,"G12", "G13", "G14" ,"G15", "G16", "G17", "G18" ,"G19","G20", "G21", "G22", "G23", "G24", "G25", "G26", "G27", "G28","G29"))
qplot(cluster_no_graclus,avg_citations,data=z,size=no_pubs,group=1,main='Global Q75 citation_count set\n Graclus Clusters',ylab='avg_citations/pub')

# 90th percentile
xpubs_q90 <- xpubs[citation_count > quantile(xpubs$citation_count,0.90)]

y<- xpubs_q90[,.(no_pubs=length(source_id),total_citations=sum(citation_count)),by='cluster_no_leiden'][,avg_citations:=total_citations/no_pubs]
y$cluster_no_leiden <- factor(y$cluster_no_leiden,levels=c("L0", "L1", "L2", "L3", "L4","L5","L6", "L7", "L8", "L9","L10", 
"L11" ,"L12", "L13", "L14" ,"L15", "L16", "L17", "L18" ,"L19","L20", "L21", "L22", "L23", "L24", "L25", "L26", "L27", "L28","L29"))
qplot(cluster_no_leiden,avg_citations,data=y,size=no_pubs,group=1,main='Global Q90 citation_count set\n Leiden Clusters',ylab='avg_citations/pub')

z<- xpubs_q90[,.(no_pubs=length(source_id),total_citations=sum(citation_count)),by='cluster_no_graclus'][,avg_citations:=total_citations/no_pubs]
z$cluster_no_graclus <- factor(z$cluster_no_graclus,levels=c("G0", "G1", "G2", "G3", "G4","G5","G6", "G7", "G8", "G9","G10", 
"G11" ,"G12", "G13", "G14" ,"G15", "G16", "G17", "G18" ,"G19","G20", "G21", "G22", "G23", "G24", "G25", "G26", "G27", "G28","G29"))
qplot(cluster_no_graclus,avg_citations,data=z,size=no_pubs,group=1,main='Global Q90 citation_count set\n Graclus Clusters',ylab='avg_citations/pub')

# Use this expression to fish out the top 20 highly cited articles in each cluster- you need to manually enter the cluster number

temp <- xpubs_q90[order(cluster_no_leiden,-citation_count)][cluster_no_leiden=='L29'][, .SD[1:20]][,.(source_id)];toString(temp$source_id)

### overlay dblp data

rf_pubs <- fread('rankfilter_pubs.csv')
rf_pubs[, names(rf_pubs)[5:6] := NULL] # get rid of Excel artifact columns
merge <- merge(y,rf_pubs,by.x='cluster_no_leiden',by.y='Cluster')
merge$cluster_no_leiden <- factor(merge$cluster_no_leiden,levels=c("L0", "L1", "L2", "L3", "L4","L5","L6", "L7", "L8", "L9","L10", 
"L11" ,"L12", "L13", "L14" ,"L15", "L16", "L17", "L18" ,"L19","L20", "L21", "L22", "L23", "L24", "L25", "L26", "L27", "L28","L29"))
cdf <- ecdf(merge$no_pubs)
merge[,no_pub_perc:=round(100*cdf(no_pubs),1)]
merge[,frac_dblp :=round(100*pubs_95th/no_pubs)]

pdf('frac_dblp_95.pdf',h=5,w=7)
qplot(cluster_no_leiden,no_pubs,data=merge,size=frac_dblp,main="Leiden Clusters \n cluster size and frac_dblp") + geom_hline(yintercept=c(43478,169912), linetype="dashed", color = "red") + annotate(geom="text", label='Q1', x=1, y=43478, vjust=-1) + annotate(geom="text", label='Q3', x=1, y=169912, vjust=-1)
dev.off()

