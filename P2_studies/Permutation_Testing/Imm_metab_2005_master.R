# Master Script for Immunology and Metabolism datasets (2005) data
# George Chacko 2/27/2019
# This script is derived from the following workflows: ON ERNIE server

# Generate WoS year slice per Jenkins job in ERNIE: 'dataset2005.csv' 
# Calculate z_scores after 1000 simulations in PostgreSQL-SPARK: 'spark1000_2005_permute.csv'
# Calculate citation counts for WoS year slice per Jenkins job: 'dataset2005_cit_counts.csv'
# Clean up spark1000_2005_permute.csv by stripping +/-Inf z_scores, then calculate median, 10th, 
# and first percentile zscores grouped by source_id (publication) ..
# -> 'd1000_2005_zsc_med.csv'
# merge with citation counts to generate: 'd1000_2005_pubwise_zsc_med.csv'

# Create imm2005 dataset by subsetting WoS year slice using imm2005 source_ids, run 1000 simulations,
# calculate median, 10th, and first percentiles and merge with citation data to 
# generate:'imm2005_pubwise_zsc_med.csv'

# Create metab2005 dataset by subsetting WoS year slice using metab2005 source_ids, run 1000 simulations, 
# calculate median, 10th, and first percentiles and merge with citation data to 
# generate:'metab2005_pubwise_zsc_med.csv'

# Sample list of input files
# dataset2005.csv, dataset2005_cit_counts.csv, dataset_metab2005_permute.csv  
# imm2005_wosids.csv, dataset_imm2005.csv, dataset_imm2005_permute.csv
# metab2005_wosids.csv, dataset_metab2005.csv, dataset_metab2005_permute.csv 

# List of output files: 
# d1000_2005_pubwise_zsc_med.csv (network background = WoS), 
# imm2005_pubwise_zsc_med.csv (network background= imm2005)
# metab2005_pubwise_zsc_med.csv (network background=metab2005)
# The above steps have been captured in init_process_2005.R

# Download to local machine for graphics using sftp
rm(list=ls())
library(data.table); library(dplyr); library(ggplot2);
setwd('~/Desktop/p1000_calcs')
# creates categorically labeled (HC/HN) pubs
source('state_2005.R')
# remove all files except the following four to keep workspace clean
rm(list=setdiff(ls(), c("cat_imm2005","cat_metab2005","cat_d2005_sub_imm", "cat_d2005_sub_metab", "cat_d2005")))
# imm2005: z_scores for imm2005 pubs using imm2005 background
# d2005_sub_imm: z_scores for imm2005 pubs using d2005(WoS2005) z_scores # metab2005: z_scores for metab2005 pubs using metab2005 background
# d2005_sub_metab: z_scores for metab2005 pubs using d2005(WoS2005) z_scores

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
z_d2005 <<- z_d2005 %>% mutate(gp=paste0(conventionality,novelty))
z_d2005 <- z_d2005 %>% mutate(bg=' d2005')
z_d2005 <- z_d2005 %>% arrange(class)
z_d2005$class <- factor(z_d2005$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_d2005 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_d2005 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='d2005_x4.csv')

# Imm2005 background is imm2005
print(dim(cat_imm2005))
print(head(cat_imm2005,5))
setDT(cat_imm2005)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_imm2005$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_imm2005[citation_count>=a])[1]
x <- cat_imm2005 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_imm2005 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_imm2005)[1]))) %>% mutate(class='all')
z_imm <-rbind(z,y)
z_imm <<- z_imm %>% mutate(gp=paste0(conventionality,novelty))
z_imm <- z_imm %>% mutate(bg=' imm2005')
z_imm <- z_imm %>% arrange(class)
z_imm$class <- factor(z_imm$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_imm %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_imm %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='imm2005_x4.csv')

# Imm2005, background is cat_d2005_sub_imm
print(dim(cat_d2005_sub_imm))
print(head(cat_d2005_sub_imm,5))
setDT(cat_d2005_sub_imm)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d2005_sub_imm$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d2005_sub_imm[citation_count>=a])[1]
x <- cat_d2005_sub_imm %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d2005_sub_imm %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d2005_sub_imm)[1]))) %>% mutate(class='all')
z_imm_sub_d2005 <-rbind(z,y)
z_imm_sub_d2005 <<- z_imm_sub_d2005 %>% mutate(gp=paste0(conventionality,novelty))
z_imm_sub_d2005 <- z_imm_sub_d2005 %>% mutate(bg=' imm_sub_d2005')
# insert missing rows on account of zero values
#t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='cs2005')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='cs2005')
#z_imm_sub_d2005 <- rbind(z_imm_sub_d2005,t1,t2)
z_imm_sub_d2005 <- z_imm_sub_d2005 %>% arrange(class)
z_imm_sub_d2005$class <- factor(z_imm_sub_d2005$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_imm_sub_d2005 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_imm_sub_d2005 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='imm_d2005_x4.csv')

source('state_2005.R')
rm(list=setdiff(ls(), c("cat_metab2005","cat_d2005_sub_metab" )))

# Metab2005 background is Metab2005
print(dim(cat_metab2005))
print(head(cat_metab2005,5))
setDT(cat_metab2005)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_metab2005$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_metab2005[citation_count>=a])[1]
x <- cat_metab2005 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_metab2005 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_metab2005)[1]))) %>% mutate(class='all')
z_metab <-rbind(z,y)
z_metab <<- z_metab %>% mutate(gp=paste0(conventionality,novelty))
z_metab <- z_metab %>% mutate(bg=' metab2005')
# insert missing rows on account of zero values
##3t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='imm2005')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='imm2005')
#z_imm <- rbind(z_imm,t1,t2)
z_metab <- z_metab %>% arrange(class)
z_metab$class <- factor(z_metab$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_metab %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_metab %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='metab2005_x4.csv',row.names=FALSE)

# Metab2005, background is cat_d2005_sub_metab
print(dim(cat_d2005_sub_metab))
print(head(cat_d2005_sub_metab,5))
setDT(cat_d2005_sub_metab)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d2005_sub_metab$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d2005_sub_metab[citation_count>=a])[1]
x <- cat_d2005_sub_metab %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d2005_sub_metab %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d2005_sub_metab)[1]))) %>% mutate(class='all')
z_metab_sub_d2005 <-rbind(z,y)
z_metab_sub_d2005 <<- z_metab_sub_d2005 %>% mutate(gp=paste0(conventionality,novelty))
z_metab_sub_d2005 <- z_metab_sub_d2005 %>% mutate(bg=' imm_sub_d2005')
# insert missing rows on account of zero values
#t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='cs2005')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='cs2005')
#z_imm_sub_d2005 <- rbind(z_imm_sub_d2005,t1,t2)
z_metab_sub_d2005 <- z_metab_sub_d2005 %>% arrange(class)
z_metab_sub_d2005$class <- factor(z_metab_sub_d2005$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_metab_sub_d2005 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_metab_sub_d2005 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='metab_d2005_x4.csv',row.names=FALSE)

# clean up
rm(list=ls())
metab_d2005 <- fread('metab_d2005_x4.csv')
metab2005 <- fread('metab2005_x4.csv')
imm_d2005 <- fread('imm_d2005_x4.csv')
imm2005 <- fread('imm2005_x4.csv')
d2005 <- fread('d2005_x4.csv')

imm2005 <- imm2005 %>% mutate(gp='imm2005')
imm_d2005 <- imm_d2005 %>% mutate(gp='imm_wos2005')
metab2005 <- metab2005 %>% mutate(gp='metab2005')
metab_d2005 <- metab_d2005 %>% mutate(gp='metab_wos2005')
d2005 <- d2005 %>% mutate(gp='wos2005')


fig_2005 <- rbind(imm2005,imm_d2005,metab2005,metab_d2005,d2005)
fig_2005$class <- factor(fig_2005$class,levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
fig_2005$gp <- factor(fig_2005$gp,levels=c("imm2005","metab2005","imm_wos2005","metab_wos2005","wos2005"))
fwrite(fig_2005,file='fig_2005.csv',row.names=FALSE)


library(extrafont)
# loadfonts()

pdf('imm_metab_2005.pdf')
qplot(class, value, group=gp, color=gp, data=fig_2005, geom=c('line','point'),facets=variable~.,xlab="Citation Count Percentile Group",ylab="Percent of Publications") + theme(text=element_text(size=10,  family="Times New Roman"))
dev.off()








