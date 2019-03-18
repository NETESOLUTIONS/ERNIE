# This script combines the data in fig_85, fig_95, and fig_2005.

setwd('~/Desktop/p1000_calcs')
rm(list=ls())
library(data.table); library(ggplot2); library(extrafont)

fig_85 <- fread('fig_85.csv')
fig_85[,`:=`(year='1985')]


fig_95 <- fread('fig_95.csv')
fig_95[,`:=`(year='1995')]

fig_2005 <- fread('fig_2005.csv')
fig_2005[,`:=`(year='2005')]

fig <- rbind(fig_85,fig_95,fig_2005)
fig$gp  <- gsub('imm85','imm',fig$gp)
fig$gp  <- gsub('metab85','metab',fig$gp)
fig$gp  <- gsub('imm_wos85','imm_wos',fig$gp)
fig$gp  <- gsub('metab_wos85','metab_wos',fig$gp)
fig$gp  <- gsub('wos85','wos',fig$gp)

fig$gp  <- gsub('imm95','imm',fig$gp)
fig$gp  <- gsub('metab95','metab',fig$gp)
fig$gp  <- gsub('imm_wos95','imm_wos',fig$gp)
fig$gp  <- gsub('metab_wos95','metab_wos',fig$gp)
fig$gp  <- gsub('wos95','wos',fig$gp)

fig$gp  <- gsub('imm2005','imm',fig$gp)
fig$gp  <- gsub('metab2005','metab',fig$gp)
fig$gp  <- gsub('imm_wos2005','imm_wos',fig$gp)
fig$gp  <- gsub('metab_wos2005','metab_wos',fig$gp)
fig$gp  <- gsub('wos2005','wos',fig$gp)

fig$class <- factor(fig$class,levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))

pdf('fig1.pdf',height=5,width=7)
qplot(class, value, group=gp, color=gp, data=fig, geom=c('line','point'),facets=variable~year,xlab="Citation Count Percentile Group",ylab="Percent of Publications") + theme(text=element_text(size=10,  family="Times New Roman")) + theme(axis.text.x = element_text(angle = -70, hjust = 0))
dev.off()

