# Master Script for Immunology and Metabolism datasets (1985) data
# George Chacko 2/27/2019
# This script is derived from the following workflows: ON ERNIE server

# Generate WoS year slice per Jenkins job in ERNIE: 'dataset1985.csv' 
# Calculate z_scores after 1000 simulations in PostgreSQL-SPARK: 'spark1000_1985_permute.csv'
# Calculate citation counts for WoS year slice per Jenkins job: 'dataset1985_cit_counts.csv'
# Clean up spark1000_1985_permute.csv by stripping +/-Inf z_scores, then calculate median, 10th, 
# and first percentile zscores grouped by source_id (publication) ..
# -> 'd1000_85_zsc_med.csv'
# merge with citation counts to generate: 'd1000_85_pubwise_zsc_med.csv'

# Create imm85 dataset by subsetting WoS year slice using imm85 source_ids, run 1000 simulations,
# calculate median, 10th, and first percentiles and merge with citation data to 
# generate:'imm85_pubwise_zsc_med.csv'

# Create metab95 dataset by subsetting WoS year slice using metab85 source_ids, run 1000 simulations, 
# calculate median, 10th, and first percentiles and merge with citation data to 
# generate:'metab85_pubwise_zsc_med.csv'

# List of input files
# dataset1985.csv, dataset1985_cit_counts.csv, dataset_metab1985_permute.csv  
# imm85_wosids.csv, dataset_imm1985.csv, dataset_imm1985_permute.csv
# metab85_wosids.csv, dataset_metab1985.csv, dataset_metab1985_permute.csv 

# List of output files: 
# d1000_85_pubwise_zsc_med.csv (network background = WoS), 
# imm85_pubwise_zsc_med.csv (network background= imm85)
# metab85_pubwise_zsc_med.csv (network background=metab85)
# The above steps have been captured in init_process_85.R

# Download to local machine for graphics using sftp
rm(list=ls())
library(data.table); library(dplyr); library(ggplot2);
setwd('~/Desktop/p1000_calcs')
# creates categorically labeled (HC/HN) pubs
source('state_85.R')
# remove all files except the following four to keep workspace clean
rm(list=setdiff(ls(), c("cat_d85","cat_imm85","cat_metab85","cat_d85_sub_imm", "cat_d85_sub_metab")))
# imm85: z_scores for imm85 pubs using imm85 background
# d85_sub_imm: z_scores for imm85 pubs using d85(WoS1985) z_scores # metab85: z_scores for metab85 pubs using metab85 background
# d85_sub_metab: z_scores for metab85 pubs using d85(WoS1985) z_scores

# d85 is whole year slice
print(dim(cat_d85))
print(head(cat_d85,5))
setDT(cat_d85)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d85$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d85[citation_count>=a])[1]
x <- cat_d85 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d85 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d85)[1]))) %>% mutate(class='all')
z_d85 <-rbind(z,y)
z_d85 <<- z_d85 %>% mutate(gp=paste0(conventionality,novelty))
z_d85 <- z_d85 %>% mutate(bg=' d85')
z_d85 <- z_d85 %>% arrange(class)
z_d85$class <- factor(z_d85$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_d85 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_d85 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='d85_x4.csv')

# Imm85 background is imm85
print(dim(cat_imm85))
print(head(cat_imm85,5))
setDT(cat_imm85)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_imm85$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_imm85[citation_count>=a])[1]
x <- cat_imm85 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_imm85 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_imm85)[1]))) %>% mutate(class='all')
z_imm <-rbind(z,y)
z_imm <<- z_imm %>% mutate(gp=paste0(conventionality,novelty))
z_imm <- z_imm %>% mutate(bg=' imm85')
z_imm <- z_imm %>% arrange(class)
z_imm$class <- factor(z_imm$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_imm %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_imm %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='imm85_x4.csv')

# Imm85, background is cat_d85_sub_imm
print(dim(cat_d85_sub_imm))
print(head(cat_d85_sub_imm,5))
setDT(cat_d85_sub_imm)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d85_sub_imm$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d85_sub_imm[citation_count>=a])[1]
x <- cat_d85_sub_imm %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d85_sub_imm %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d85_sub_imm)[1]))) %>% mutate(class='all')
z_imm_sub_d85 <-rbind(z,y)
z_imm_sub_d85 <<- z_imm_sub_d85 %>% mutate(gp=paste0(conventionality,novelty))
z_imm_sub_d85 <- z_imm_sub_d85 %>% mutate(bg=' imm_sub_d85')
# insert missing rows on account of zero values
#t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='cs85')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='cs85')
#z_imm_sub_d85 <- rbind(z_imm_sub_d85,t1,t2)
z_imm_sub_d85 <- z_imm_sub_d85 %>% arrange(class)
z_imm_sub_d85$class <- factor(z_imm_sub_d85$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_imm_sub_d85 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_imm_sub_d85 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='imm_d85_x4.csv')

source('state_85.R')
rm(list=setdiff(ls(), c("cat_metab85","cat_d85_sub_metab" )))

# Metab85 background is Metab85
print(dim(cat_metab85))
print(head(cat_metab85,5))
setDT(cat_metab85)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_metab85$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_metab85[citation_count>=a])[1]
x <- cat_metab85 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_metab85 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_metab85)[1]))) %>% mutate(class='all')
z_metab <-rbind(z,y)
z_metab <<- z_metab %>% mutate(gp=paste0(conventionality,novelty))
z_metab <- z_metab %>% mutate(bg=' metab85')
# insert missing rows on account of zero values
##3t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='imm85')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='imm85')
#z_imm <- rbind(z_imm,t1,t2)
z_metab <- z_metab %>% arrange(class)
z_metab$class <- factor(z_metab$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_metab %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_metab %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='metab85_x4.csv',row.names=FALSE)

# Metab85, background is cat_d85_sub_metab
print(dim(cat_d85_sub_metab))
print(head(cat_d85_sub_metab,5))
setDT(cat_d85_sub_metab)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d85_sub_metab$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d85_sub_metab[citation_count>=a])[1]
x <- cat_d85_sub_metab %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d85_sub_metab %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d85_sub_metab)[1]))) %>% mutate(class='all')
z_metab_sub_d85 <-rbind(z,y)
z_metab_sub_d85 <<- z_metab_sub_d85 %>% mutate(gp=paste0(conventionality,novelty))
z_metab_sub_d85 <- z_metab_sub_d85 %>% mutate(bg=' imm_sub_d85')
# insert missing rows on account of zero values
#t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='cs85')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='cs85')
#z_imm_sub_d85 <- rbind(z_imm_sub_d85,t1,t2)
z_metab_sub_d85 <- z_metab_sub_d85 %>% arrange(class)
z_metab_sub_d85$class <- factor(z_metab_sub_d85$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_metab_sub_d85 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_metab_sub_d85 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='metab_d85_x4.csv',row.names=FALSE)

# clean up
rm(list=ls())
metab_d85 <- fread('metab_d85_x4.csv')
metab85 <- fread('metab85_x4.csv')
imm_d85 <- fread('imm_d85_x4.csv')
imm85 <- fread('imm85_x4.csv')
d85 <- fread('d85_x4.csv')

imm85 <- imm85 %>% mutate(gp='imm85')
imm_d85 <- imm_d85 %>% mutate(gp='imm_wos85')
metab85 <- metab85 %>% mutate(gp='metab85')
metab_d85 <- metab_d85 %>% mutate(gp='metab_wos85')
d85 <- d85 %>% mutate(gp='wos85')

fig_85 <- rbind(imm85,imm_d85,metab85,metab_d85,d85)
fig_85$class <- factor(fig_85$class,levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
fig_85$gp <- factor(fig_85$gp,levels=c("imm85","metab85","imm_wos85","metab_wos85","wos85"))
fwrite(fig_85,file='fig_85.csv',row.names=FALSE)

library(extrafont)
#loadfonts()
pdf('imm_metab_85.pdf')
qplot(class, value, group=gp, color=gp, data=fig_85, geom=c('line','point'),facets=variable~.,xlab="Citation Count Percentile Group",ylab="Percent of Publications") + theme(text=element_text(size=10,  family="Times New Roman"))
dev.off()








