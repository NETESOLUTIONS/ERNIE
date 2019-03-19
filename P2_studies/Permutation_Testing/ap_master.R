# Master Script for Applied Physics datasets (1985, 1995, 2005) data
# George Chacko 2/27/2019
# This script is derived from the following workflows: ON ERNIE server

# Generate WoS year slice per Jenkins job in ERNIE: 'dataset2005.csv' 
# Calculate z_scores after 1000 simulations in PostgreSQL-SPARK: 'spark1000_2005_permute.csv'
# Calculate citation counts for WoS year slice per Jenkins job: 'dataset2005_cit_counts.csv'
# Clean up spark1000_2005_permute.csv by stripping +/-Inf z_scores, then calculate median, 10th, 
# and first percentile zscores grouped by source_id (publication) ..
# -> 'd1000_2005_zsc_med.csv'
# merge with citation counts to generate: 'd1000_2005_pubwise_zsc_med.csv'

# Example: Create ap2005 dataset by subsetting WoS year slice using ap2005 source_ids, 
# run 1000 simulations, calculate median, 10th, and first percentiles and merge with 
# citation data to generate:'ap2005_pubwise_zsc_med.csv'

# Sample list of input files
# dataset2005.csv, dataset2005_cit_counts.csv, dataset_metab2005_permute.csv  
# ap2005_wosids.csv, dataset_ap2005.csv, dataset_ap2005_permute.csv
# metab2005_wosids.csv, dataset_metab2005.csv, dataset_metab2005_permute.csv 

# List of output files: 
# d1000_2005_pubwise_zsc_med.csv (network background = WoS), 
# ap2005_pubwise_zsc_med.csv (network background= ap2005)
# metab2005_pubwise_zsc_med.csv (network background=metab2005)
# Download to local machine for graphics using sftp

rm(list=ls())
library(data.table); library(dplyr); library(ggplot2);
setwd('~/Desktop/p1000_calcs')
# creates categorically labeled (HC/HN) pubs
source('state_ap.R')
# remove all files except the following four to keep workspace clean
rm(list=setdiff(ls(), c("cat_ap2005","cat_ap1995","cat_ap1985", 
"cat_d1985", "cat_d1985_sub_ap", "cat_d1995_sub_ap", 
"cat_d2005_sub_ap","cat_d2005","cat_d1995")))

# WoS Slices
# d2005 is whole year slice
print(dim(cat_d2005))
print(head(cat_d2005,5))
setDT(cat_d2005)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d2005$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d2005[citation_count>=a])[1]
x <- cat_d2005 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d2005 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d2005)[1]))) %>% mutate(class='all')
z_d2005 <-rbind(z,y)
z_d2005 <- z_d2005 %>% mutate(gp=paste0(conventionality,novelty))
z_d2005 <- z_d2005 %>% mutate(bg=' d2005')
z_d2005 <- z_d2005 %>% arrange(class)
z_d2005$class <- factor(z_d2005$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_d2005 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_d2005 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='d2005_x4.csv')

# d1995 is whole year slice
print(dim(cat_d1995))
print(head(cat_d1995,5))
setDT(cat_d1995)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d1995$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d1995[citation_count>=a])[1]
x <- cat_d1995 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d1995 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d1995)[1]))) %>% mutate(class='all')
z_d1995 <-rbind(z,y)
z_d1995 <- z_d1995 %>% mutate(gp=paste0(conventionality,novelty))
z_d1995 <- z_d1995 %>% mutate(bg=' d1995')
z_d1995 <- z_d1995 %>% arrange(class)
z_d1995$class <- factor(z_d1995$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_d1995 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_d1995 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='d1995_x4.csv')

# d1985 is whole year slice
print(dim(cat_d1985))
print(head(cat_d1985,5))
setDT(cat_d1985)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d1985$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d1985[citation_count>=a])[1]
x <- cat_d1985 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d1985 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d1985)[1]))) %>% mutate(class='all')
z_d1985 <-rbind(z,y)
z_d1985 <- z_d1985 %>% mutate(gp=paste0(conventionality,novelty))
z_d1985 <- z_d1985 %>% mutate(bg=' d1985')
z_d1985 <- z_d1985 %>% arrange(class)
z_d1985$class <- factor(z_d1985$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_d1985 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_d1985 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='d1985_x4.csv')

# Applied Physics Slices

# ap2005 background is ap2005
print(dim(cat_ap2005))
print(head(cat_ap2005,5))
setDT(cat_ap2005)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_ap2005$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_ap2005[citation_count>=a])[1]
x <- cat_ap2005 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_ap2005 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_ap2005)[1]))) %>% mutate(class='all')
z_ap <-rbind(z,y)
z_ap <- z_ap %>% mutate(gp=paste0(conventionality,novelty))
z_ap <- z_ap %>% mutate(bg=' ap2005')
z_ap <- z_ap %>% arrange(class)
z_ap$class <- factor(z_ap$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_ap %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_ap %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='ap2005_x4.csv')

# ap1995 background is ap1995
print(dim(cat_ap1995))
print(head(cat_ap1995,5))
setDT(cat_ap1995)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_ap1995$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_ap1995[citation_count>=a])[1]
x <- cat_ap1995 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_ap1995 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_ap1995)[1]))) %>% mutate(class='all')
z_ap <-rbind(z,y)
z_ap <- z_ap %>% mutate(gp=paste0(conventionality,novelty))
z_ap <- z_ap %>% mutate(bg=' ap1995')
z_ap <- z_ap %>% arrange(class)
z_ap$class <- factor(z_ap$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_ap %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_ap %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='ap1995_x4.csv')

# ap1985 background is ap1985
print(dim(cat_ap1985))
print(head(cat_ap1985,5))
setDT(cat_ap1985)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_ap1985$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_ap1985[citation_count>=a])[1]
x <- cat_ap1985 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_ap1985 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_ap1985)[1]))) %>% mutate(class='all')
z_ap <-rbind(z,y)
z_ap <- z_ap %>% mutate(gp=paste0(conventionality,novelty))
z_ap <- z_ap %>% mutate(bg=' ap1985')
z_ap <- z_ap %>% arrange(class)
z_ap$class <- factor(z_ap$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_ap %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_ap %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='ap1985_x4.csv')

# Applied Physics with WoS background

# ap2005, background is cat_d2005_sub_ap
print(dim(cat_d2005_sub_ap))
print(head(cat_d2005_sub_ap,5))
setDT(cat_d2005_sub_ap)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d2005_sub_ap$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d2005_sub_ap[citation_count>=a])[1]
x <- cat_d2005_sub_ap %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d2005_sub_ap %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d2005_sub_ap)[1]))) %>% mutate(class='all')
z_ap_sub_d2005 <-rbind(z,y)
z_ap_sub_d2005 <- z_ap_sub_d2005 %>% mutate(gp=paste0(conventionality,novelty))
z_ap_sub_d2005 <- z_ap_sub_d2005 %>% mutate(bg=' ap_sub_d2005')
z_ap_sub_d2005 <- z_ap_sub_d2005 %>% arrange(class)
z_ap_sub_d2005$class <- factor(z_ap_sub_d2005$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_ap_sub_d2005 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_ap_sub_d2005 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='ap_d2005_x4.csv')

# ap1995, background is cat_d1995_sub_ap
print(dim(cat_d1995_sub_ap))
print(head(cat_d1995_sub_ap,5))
setDT(cat_d1995_sub_ap)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d1995_sub_ap$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d1995_sub_ap[citation_count>=a])[1]
x <- cat_d1995_sub_ap %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d1995_sub_ap %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d1995_sub_ap)[1]))) %>% mutate(class='all')
z_ap_sub_d1995 <-rbind(z,y)
z_ap_sub_d1995 <- z_ap_sub_d1995 %>% mutate(gp=paste0(conventionality,novelty))
z_ap_sub_d1995 <- z_ap_sub_d1995 %>% mutate(bg=' ap_sub_d1995')
z_ap_sub_d1995 <- z_ap_sub_d1995 %>% arrange(class)
z_ap_sub_d1995$class <- factor(z_ap_sub_d1995$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_ap_sub_d1995 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_ap_sub_d1995 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='ap_d1995_x4.csv')

# ap1985, background is cat_d1985_sub_ap
print(dim(cat_d1985_sub_ap))
print(head(cat_d1985_sub_ap,5))
setDT(cat_d1985_sub_ap)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d1985_sub_ap$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d1985_sub_ap[citation_count>=a])[1]
x <- cat_d1985_sub_ap %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d1985_sub_ap %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d1985_sub_ap)[1]))) %>% mutate(class='all')
z_ap_sub_d1985 <-rbind(z,y)
z_ap_sub_d1985 <- z_ap_sub_d1985 %>% mutate(gp=paste0(conventionality,novelty))
z_ap_sub_d1985 <- z_ap_sub_d1985 %>% mutate(bg=' ap_sub_d1985')
z_ap_sub_d1985 <- z_ap_sub_d1985 %>% arrange(class)
z_ap_sub_d1985$class <- factor(z_ap_sub_d1985$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_ap_sub_d1985 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_ap_sub_d1985 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='ap_d1985_x4.csv')

# clean up workspace
rm(list=ls())
# read relevant data back in 

ap_2005_x4 <- fread('ap2005_x4.csv')
ap_1995_x4 <- fread('ap1995_x4.csv')
ap_1985_x4 <- fread('ap1985_x4.csv')

ap_d2005_x4 <- fread('ap_d2005_x4.csv')
ap_d1995_x4 <- fread('ap_d1995_x4.csv')
ap_d1985_x4 <- fread('ap_d1985_x4.csv')

d2005_x4 <- fread('d2005_x4.csv')
d1995_x4 <- fread('d1995_x4.csv')
d1985_x4 <- fread('d1985_x4.csv')

# add extra fields for faceting by group

ap_2005_x4[,`:=`(gp='ap',year=2005)]
ap_1995_x4[,`:=`(gp='ap',year=1995)]
ap_1985_x4[,`:=`(gp='ap',year=1985)]

ap_d2005_x4[,`:=`(gp='ap_wos',year=2005)]
ap_d1995_x4[,`:=`(gp='ap_wos',year=1995)]
ap_d1985_x4[,`:=`(gp='ap_wos',year=1985)]

d2005_x4[,`:=`(gp='wos',year=2005)]
d1995_x4[,`:=`(gp='wos',year=1995)]
d1985_x4[,`:=`(gp='wos',year=1985)]

all_physics <- rbind(ap_2005_x4,
ap_1995_x4,
ap_1985_x4,
ap_d2005_x4,
ap_d1995_x4,
ap_d1985_x4,
d2005_x4,
d1995_x4,
d1985_x4)

all_physics$class <- factor(all_physics$class,levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))

library(ggplot2); library(extrafont)
pdf('fig2.pdf')
qplot(class, value, group=gp, color=gp, data=all_physics, geom=c('line','point'),facets=variable~year,xlab="Citation Count Percentile Group",ylab="Percent of Publications") + theme(text=element_text(size=10,  family="Times New Roman")) + theme(axis.text.x = element_text(angle = -70, hjust = 0))
dev.off()




