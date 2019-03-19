# script to compare z_scores from whole year slice vs case study set
setwd('~/Desktop/p1000_calcs')
library(data.table)
library(dplyr)
rm(list=ls())

#1995 data
# Whole year slice
# High conventionality is > median of median z_scores
# High novelty is tenth percentile of < 0
d95 <- fread('d1000_1995_pubwise_zsc_med.csv')
print(median(d95$med))
cat_d95 <- d95 %>% mutate(conventionality=ifelse(med <= median(d95$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d95 <- cat_d95 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d95') %>% 
mutate(percent=floor(100*count/length(d95$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# Immunology 95 dataset
imm95 <- fread('imm95_pubwise_zsc_med.csv')
print(median(imm95$med))
cat_imm95 <- imm95 %>% mutate(conventionality=ifelse(med <= median(imm95$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_imm95 <- cat_imm95 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='imm95') %>% 
mutate(percent=floor(100*count/length(imm95$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# subset of d95 based on imm95 source_ids
d95_sub_imm <- d95[d95$source_id %in% imm95$source_id] # loses one source_id
print(median(d95_sub_imm$med))
cat_d95_sub_imm <- d95_sub_imm %>% 
mutate(conventionality=ifelse(med <= median(d95_sub_imm$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d95_sub_imm <- cat_d95_sub_imm %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d95_sub_imm') %>% 
mutate(percent=floor(100*count/length(d95_sub_imm$source_id)),category=paste0(conventionality,novelty)) %>% data.frame() %>% select(gp,category,percent)

# metabolism dataset 
metab95 <- fread('metab95_pubwise_zsc_med.csv')
cat_metab95 <- metab95 %>% 
mutate(conventionality=ifelse(med <= median(metab95$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_metab95 <- cat_metab95 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='metab95') %>% 
mutate(percent=floor(100*count/length(metab95$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# subset of d95 based on metab95 source_ids
d95_sub_metab <- d95[d95$source_id %in% metab95$source_id]
cat_d95_sub_metab <- d95_sub_metab %>% 
mutate(conventionality=ifelse(med <= median(d95_sub_metab$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d95_sub_metab <- cat_d95_sub_metab %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d95_sub_metab') %>% 
mutate(percent=floor(100*count/length(d95_sub_metab$source_id)),category=paste0(conventionality,novelty)) %>% data.frame() %>% select(gp,category,percent)

