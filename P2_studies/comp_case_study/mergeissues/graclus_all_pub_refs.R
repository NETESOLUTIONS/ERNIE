rm(list=ls())
library(data.table)
library(ggplot2)
setwd('~/Desktop/clustering')

# graclus_summary_all.csv
all <- fread('graclus_summary_all.csv')
all <- all[-(51:54),]
all[is.na(all)] <- 0
all <- data.frame(all)
m_all <- melt(all,id='cl_no')
m_all$cl_no <- factor(m_all$cl_no, levels=c(0,seq(1:49)))

pdf('graclus_all.pdf')
qplot(cl_no,log10(value),data=m_all[m_all$value > 0,],facets=variable~.,color=variable,ylab="cluster_size as log10(count)",main="analysis of all \n from graclus 10, 20, 30, 40, 50") + 
theme(axis.text.x=element_text(angle=-90, hjust=0))
dev.off()

# graclus_summary_pubs.csv
pubs <- fread('graclus_summary_pubs.csv')
pubs <- pubs[-(51:54),]
pubs[is.na(pubs)] <- 0
pubs <- data.frame(pubs)
m_pubs <- melt(pubs,id='cl_no')
m_pubs$cl_no <- factor(m_pubs$cl_no, levels=c(0,seq(1:49)))

pdf('graclus_pubs.pdf')
qplot(cl_no,log10(value),data=m_pubs[m_pubs$value > 0,],facets=variable~.,color=variable,ylab="cluster_size as log10(count)",main="analysis of pubs \n from graclus 10, 20, 30, 40, 50") + 
theme(axis.text.x=element_text(angle=-90, hjust=0))
dev.off()

# graclus_summary_refs.csv
refs <- fread('graclus_summary_refs.csv')
refs <- refs[-(51:54),]
refs[is.na(refs)] <- 0
refs <- data.frame(refs)
m_refs <- melt(refs,id='cl_no')
m_refs$cl_no <- factor(m_refs$cl_no, levels=c(0,seq(1:49)))

pdf('graclus_refs.pdf')
qplot(cl_no,log10(value),data=m_refs[m_refs$value > 0,],facets=variable~.,color=variable,ylab="cluster_size as log10(count)",main="analysis of refs \n from graclus 10, 20, 30, 40, 50") + 
theme(axis.text.x=element_text(angle=-90, hjust=0))
dev.off()

# replace 0 with NA to clean up summary results
all <- all[, lapply(.SD, function(x) replace(x, which(x==0), NA))]; all[1,1] <- '0'
summary(all)
pubs <- pubs[, lapply(.SD, function(x) replace(x, which(x==0), NA))]; pubs[1,1] <- '0'
summary(pubs)
refs <- refs[, lapply(.SD, function(x) replace(x, which(x==0), NA))]; refs[1,1] <- '0'
summary(refs)






