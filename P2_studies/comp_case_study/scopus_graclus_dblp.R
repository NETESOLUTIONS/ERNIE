rm(list=ls())
library(data.table); library(ggplot2)
setwd('~/Desktop')
x <- fread('~/Desktop/select___from_public_dblp_graclus_2000_2.csv')
colnames(x) <- c('cluster','counts','ai','ct_m','cg_cad','cn_c',
'csa','cv_pr','h_a','hci','is','sp','sw','misc','all')
xn <- x[,.(cluster,
# countsn=100*counts/counts,
ai=round(100*ai/counts),
ct_m=round(100*ct_m/counts),
cg_cad=round(100*cg_cad/counts),
cn_c=round(100*cn_c/counts),
csa=round(100*csa/counts),
cv_pr=round(100*cv_pr/counts),
h_a=round(100*h_a/counts),
hci=round(100*hci/counts),
is=round(100*is/counts),
sp=round(100*sp/counts),
sw=round(100*sw/counts),
misc=round(100*misc/counts),
all=round(100*all/counts))]
xn <- xn[order(cluster)]
mxn <- melt(xn,id='cluster')
setwd('~/Desktop/clustering')

pdf('scopus_dblp_graclus.pdf',h=7.5,w=10.5)
ggplot(data = mxn, aes(x = as.factor(cluster), y = variable)) + geom_tile(aes(fill = value)) + 
scale_fill_gradient2(low = "darkblue", high = "darkgreen", guide = "colorbar") + 
ggtitle("DBLP Publications 2000-2015 \n Minor Subject Areas") + xlab("Graclus Cluster No") + 
ylab("Scopus CS Categories") +
labs(fill = "% Cluster \n Count")
dev.off()

msa <- fread('~/msa.csv')
msa <- msa[,.(sum(count)),by=c('cluster_20','minor_subject_area')][order(cluster_20,-V1)][V1>500][,head(.SD,5),cluster_20]
msa <- merge(msa,x[,c(1,2)],by.x='cluster_20',by.y='cluster')
msa[,prop:=V1/counts]

pdf('scopus_dblp_graclus2.pdf',h=7.5,w=10.5)
ggplot(data = msa, aes(x = as.factor(cluster_20), y = minor_subject_area)) + geom_tile(aes(fill = prop)) + 
scale_fill_gradient2(low = "yellow", high = "red", guide = "colorbar") + 
ggtitle("DBLP Publications 2000-2015 \n Minor Subject Areas") + xlab("Graclus Cluster No") + 
ylab("Scopus CS Categories") +
labs(fill = "% Cluster \n Count")
dev.off()

