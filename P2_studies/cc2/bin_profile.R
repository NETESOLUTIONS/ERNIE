setwd('~/Desktop/cc2')
rm(list=ls()); library(data.table); library(ggplot2);library(gridExtra)
x <- fread('bin_profile.csv')
pdf('bin_profile.pdf')
qplot(bin,log(fsum),data=x,geom="boxplot",group=bin,ylab="ln(fsum)") +  
annotation_custom(tableGrob(x[,.(min=min(fsum),max=max(fsum),median=median(fsum),.N),by='bin'],
rows=NULL), xmin=1, xmax=3, ymin=6, ymax=8) + theme_bw()
dev.off()
system('cp bin_profile.pdf ~/cocitation_2/bin_profile.pdf')