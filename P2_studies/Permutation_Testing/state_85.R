# script to compare z_scores from whole year slice vs case study set
setwd('~/Desktop/p1000_calcs')
library(data.table)
library(dplyr)
rm(list=ls())

#1985 data
# Whole year slice
# High conventionality is > median of median z_scores
# High novelty is tenth percentile of < 0
d85 <- fread('d1000_1985_pubwise_zsc_med.csv')
print(median(d85$med))
cat_d85 <- d85 %>% mutate(conventionality=ifelse(med <= median(d85$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d85 <- cat_d85 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d85') %>% 
mutate(percent=floor(100*count/length(d85$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# Immunology 85 dataset
imm85 <- fread('imm85_pubwise_zsc_med.csv')
print(median(imm85$med))
cat_imm85 <- imm85 %>% mutate(conventionality=ifelse(med <= median(imm85$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_imm85 <- cat_imm85 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='imm85') %>% 
mutate(percent=floor(100*count/length(imm85$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# subset of d85 based on imm85 source_ids
d85_sub_imm <- d85[d85$source_id %in% imm85$source_id] # loses one source_id
print(median(d85_sub_imm$med))
cat_d85_sub_imm <- d85_sub_imm %>% 
mutate(conventionality=ifelse(med <= median(d85_sub_imm$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d85_sub_imm <- cat_d85_sub_imm %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d85_sub_imm') %>% 
mutate(percent=floor(100*count/length(d85_sub_imm$source_id)),category=paste0(conventionality,novelty)) %>% data.frame() %>% select(gp,category,percent)

# metabolism dataset 
metab85 <- fread('metab85_pubwise_zsc_med.csv')
cat_metab85 <- metab85 %>% 
mutate(conventionality=ifelse(med <= median(metab85$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_metab85 <- cat_metab85 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='metab85') %>% 
mutate(percent=floor(100*count/length(metab85$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# subset of d85 based on metab85 source_ids
d85_sub_metab <- d85[d85$source_id %in% metab85$source_id]
cat_d85_sub_metab <- d85_sub_metab %>% 
mutate(conventionality=ifelse(med <= median(d85_sub_metab$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d85_sub_metab <- cat_d85_sub_metab %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d85_sub_metab') %>% 
mutate(percent=floor(100*count/length(d85_sub_metab$source_id)),category=paste0(conventionality,novelty)) %>% data.frame() %>% select(gp,category,percent)

