rm(list=ls())
setwd('~/Desktop/clustering/')
library(data.table); library(ggplot2)
y <- fread('graclus_leiden_data.csv')
yy <- y[,.(length(source_id)),by=c('cluster_no_leiden','cluster_no_graclus')]
yyy <- rbind(yy,data.frame('L11',"G17",0),data.frame("L11","G23",0),use.names=FALSE)
yl <- y[,.(suml=length(source_id)),by='cluster_no_leiden']
yg <- y[,.(sumg=length(source_id)),by='cluster_no_graclus']
yyy <- merge(yyy,yl,by.x='cluster_no_leiden',by.y='cluster_no_leiden')
yyy <- merge(yyy,yg,by.x='cluster_no_graclus',by.y='cluster_no_graclus') 
yyy$cluster_no_graclus <- factor(yyy$cluster_no_graclus,levels=c("G0", "G1", "G2", "G3", "G4","G5","G6", "G7", "G8", "G9","G10", "G11" ,"G12", "G13", "G14" ,"G15", "G16", "G17", "G18" ,"G19","G20", "G21", "G22", "G23", "G24", "G25", "G26", "G27", "G28","G29"))
yyy$cluster_no_leiden <- factor(yyy$cluster_no_leiden,levels=c("L0", "L1", "L2", "L3", "L4","L5","L6", "L7", "L8", "L9","L10", "L11" ,"L12", "L13", "L14" ,"L15", "L16", "L17", "L18" ,"L19","L20", "L21", "L22", "L23", "L24", "L25", "L26", "L27", "L28","L29"))
qplot(cluster_no_graclus,cluster_no_leiden,data=yyy,size=V1,color=V1/sumg)
