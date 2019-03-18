# Master Script for Immunology and Metabolism datasets (1995) data
# George Chacko 2/27/2019
# This script is derived from the following workflows: ON ERNIE server

# Generate WoS year slice per Jenkins job in ERNIE: 'dataset1995.csv' 
# Calculate z_scores after 1000 simulations in PostgreSQL-SPARK: 'spark1000_1995_permute.csv'
# Calculate citation counts for WoS year slice per Jenkins job: 'dataset1995_cit_counts.csv'
# Clean up spark1000_1995_permute.csv by stripping +/-Inf z_scores, then calculate median, 10th, 
# and first percentile zscores grouped by source_id (publication) ..
# -> 'd1000_95_zsc_med.csv'
# merge with citation counts to generate: 'd1000_95_pubwise_zsc_med.csv'

# Create imm95 dataset by subsetting WoS year slice using imm95 source_ids, run 1000 simulations,
# calculate median, 10th, and first percentiles and merge with citation data to 
# generate:'imm95_pubwise_zsc_med.csv'

# Create metab95 dataset by subsetting WoS year slice using metab95 source_ids, run 1000 simulations, 
# calculate median, 10th, and first percentiles and merge with citation data to 
# generate:'metab95_pubwise_zsc_med.csv'

# List of input files
# dataset1995.csv, dataset1995_cit_counts.csv, dataset_metab1995_permute.csv  
# imm95_wosids.csv, dataset_imm1995.csv, dataset_imm1995_permute.csv
# metab95_wosids.csv, dataset_metab1995.csv, dataset_metab1995_permute.csv 

# List of output files: 
# d1000_95_pubwise_zsc_med.csv (network background = WoS), 
# imm95_pubwise_zsc_med.csv (network background= imm95)
# metab95_pubwise_zsc_med.csv (network background=metab95)
# The above steps have been captured in init_process_95.R

# Download to local machine for graphics using sftp
rm(list=ls())
library(data.table); library(dplyr); library(ggplot2);
setwd('~/Desktop/p1000_calcs')
# creates categorically labeled (HC/HN) pubs
source('state_95.R')
# remove all files except the following four to keep workspace clean
rm(list=setdiff(ls(), c("cat_imm95","cat_metab95","cat_d95_sub_imm", "cat_d95_sub_metab")))
# imm95: z_scores for imm95 pubs using imm95 background
# d95_sub_imm: z_scores for imm95 pubs using d95(WoS1995) z_scores # metab95: z_scores for metab95 pubs using metab95 background
# d95_sub_metab: z_scores for metab95 pubs using d95(WoS1995) z_scores

# Imm95 background is imm95
print(dim(cat_imm95))
print(head(cat_imm95,5))
setDT(cat_imm95)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_imm95$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_imm95[citation_count>=a])[1]
x <- cat_imm95 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_imm95 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_imm95)[1]))) %>% mutate(class='all')
z_imm <-rbind(z,y)
z_imm <<- z_imm %>% mutate(gp=paste0(conventionality,novelty))
z_imm <- z_imm %>% mutate(bg=' imm95')
z_imm <- z_imm %>% arrange(class)
z_imm$class <- factor(z_imm$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_imm %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_imm %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='imm95_x4.csv')

# Imm95, background is cat_d95_sub_imm
print(dim(cat_d95_sub_imm))
print(head(cat_d95_sub_imm,5))
setDT(cat_d95_sub_imm)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d95_sub_imm$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d95_sub_imm[citation_count>=a])[1]
x <- cat_d95_sub_imm %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d95_sub_imm %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d95_sub_imm)[1]))) %>% mutate(class='all')
z_imm_sub_d95 <-rbind(z,y)
z_imm_sub_d95 <<- z_imm_sub_d95 %>% mutate(gp=paste0(conventionality,novelty))
z_imm_sub_d95 <- z_imm_sub_d95 %>% mutate(bg=' imm_sub_d95')
# insert missing rows on account of zero values
#t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='cs95')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='cs95')
#z_imm_sub_d95 <- rbind(z_imm_sub_d95,t1,t2)
z_imm_sub_d95 <- z_imm_sub_d95 %>% arrange(class)
z_imm_sub_d95$class <- factor(z_imm_sub_d95$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_imm_sub_d95 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_imm_sub_d95 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='imm_d95_x4.csv')

source('state_95.R')
rm(list=setdiff(ls(), c("cat_metab95","cat_d95_sub_metab" )))

# Metab95 background is Metab95
print(dim(cat_metab95))
print(head(cat_metab95,5))
setDT(cat_metab95)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_metab95$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_metab95[citation_count>=a])[1]
x <- cat_metab95 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_metab95 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_metab95)[1]))) %>% mutate(class='all')
z_metab <-rbind(z,y)
z_metab <<- z_metab %>% mutate(gp=paste0(conventionality,novelty))
z_metab <- z_metab %>% mutate(bg=' metab95')
# insert missing rows on account of zero values
##3t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='imm95')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='imm95')
#z_imm <- rbind(z_imm,t1,t2)
z_metab <- z_metab %>% arrange(class)
z_metab$class <- factor(z_metab$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_metab %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_metab %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='metab95_x4.csv',row.names=FALSE)

# Metab95, background is cat_d95_sub_metab
print(dim(cat_d95_sub_metab))
print(head(cat_d95_sub_metab,5))
setDT(cat_d95_sub_metab)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d95_sub_metab$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d95_sub_metab[citation_count>=a])[1]
x <- cat_d95_sub_metab %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d95_sub_metab %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d95_sub_metab)[1]))) %>% mutate(class='all')
z_metab_sub_d95 <-rbind(z,y)
z_metab_sub_d95 <<- z_metab_sub_d95 %>% mutate(gp=paste0(conventionality,novelty))
z_metab_sub_d95 <- z_metab_sub_d95 %>% mutate(bg=' imm_sub_d95')
# insert missing rows on account of zero values
#t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='cs95')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='cs95')
#z_imm_sub_d95 <- rbind(z_imm_sub_d95,t1,t2)
z_metab_sub_d95 <- z_metab_sub_d95 %>% arrange(class)
z_metab_sub_d95$class <- factor(z_metab_sub_d95$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_metab_sub_d95 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_metab_sub_d95 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='metab_d95_x4.csv',row.names=FALSE)

# clean up
rm(list=ls())
metab_d95 <- fread('metab_d95_x4.csv')
metab95 <- fread('metab95_x4.csv')
imm_d95 <- fread('imm_d95_x4.csv')
imm95 <- fread('imm95_x4.csv')

imm95 <- imm95 %>% mutate(gp='imm95')
imm_d95 <- imm_d95 %>% mutate(gp='imm_wos95')
metab95 <- metab95 %>% mutate(gp='metab95')
metab_d95 <- metab_d95 %>% mutate(gp='metab_wos95')


fig2 <- rbind(imm95,imm_d95,metab95,metab_d95)
fig2$class <- factor(fig2$class,levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))


library(extrafont)
loadfonts()

pdf('imm_metab_95.pdf')
qplot(class, value, group=gp, color=gp, data=fig2, geom=c('line','point'),facets=variable~.,xlab="Citation Count Percentile Group",ylab="Percent of Publications") + theme(text=element_text(size=10,  family="Times New Roman"))
dev.off()








