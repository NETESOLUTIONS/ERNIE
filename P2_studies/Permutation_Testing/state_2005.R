# script to compare z_scores from whole year slice vs case study set
setwd('~/Desktop/p1000_calcs')
library(data.table)
library(dplyr)
rm(list=ls())

#192005 data
# Whole year slice
# High conventionality is > median of median z_scores
# High novelty is tenth percentile of < 0
d2005 <- fread('d1000_2005_pubwise_zsc_med.csv')
print(median(d2005$med))
cat_d2005 <- d2005 %>% mutate(conventionality=ifelse(med <= median(d2005$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d2005 <- cat_d2005 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d2005') %>% 
mutate(percent=floor(100*count/length(d2005$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# Immunology 2005 dataset
imm2005 <- fread('imm2005_pubwise_zsc_med.csv')
print(median(imm2005$med))
cat_imm2005 <- imm2005 %>% mutate(conventionality=ifelse(med <= median(imm2005$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_imm2005 <- cat_imm2005 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='imm2005') %>% 
mutate(percent=floor(100*count/length(imm2005$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# subset of d2005 based on imm2005 source_ids
d2005_sub_imm <- d2005[d2005$source_id %in% imm2005$source_id] # loses one source_id
print(median(d2005_sub_imm$med))
cat_d2005_sub_imm <- d2005_sub_imm %>% 
mutate(conventionality=ifelse(med <= median(d2005_sub_imm$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d2005_sub_imm <- cat_d2005_sub_imm %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d2005_sub_imm') %>% 
mutate(percent=floor(100*count/length(d2005_sub_imm$source_id)),category=paste0(conventionality,novelty)) %>% data.frame() %>% select(gp,category,percent)

# metabolism dataset 
metab2005 <- fread('metab2005_pubwise_zsc_med.csv')
cat_metab2005 <- metab2005 %>% 
mutate(conventionality=ifelse(med <= median(metab2005$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_metab2005 <- cat_metab2005 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='metab2005') %>% 
mutate(percent=floor(100*count/length(metab2005$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# subset of d2005 based on metab2005 source_ids
d2005_sub_metab <- d2005[d2005$source_id %in% metab2005$source_id]
cat_d2005_sub_metab <- d2005_sub_metab %>% 
mutate(conventionality=ifelse(med <= median(d2005_sub_metab$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d2005_sub_metab <- cat_d2005_sub_metab %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d2005_sub_metab') %>% 
mutate(percent=floor(100*count/length(d2005_sub_metab$source_id)),category=paste0(conventionality,novelty)) %>% data.frame() %>% select(gp,category,percent)

