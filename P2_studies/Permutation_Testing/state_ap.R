# script to compare z_scores from whole year slice vs case study set
# which is applied physics in this case

setwd('~/Desktop/p1000_calcs')
library(data.table)
library(dplyr)
rm(list=ls())


# Whole year slice
# High conventionality is > median of median z_scores
# High novelty is tenth percentile of < 0

#2005 WoS data
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

#1995 WoS Data
d1995 <- fread('d1000_1995_pubwise_zsc_med.csv')
print(median(d1995$med))
cat_d1995 <- d1995 %>% mutate(conventionality=ifelse(med <= median(d1995$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d1995 <- cat_d1995 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d1995') %>% 
mutate(percent=floor(100*count/length(d1995$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

#1985 WoS Data
d1985 <- fread('d1000_1985_pubwise_zsc_med.csv')
print(median(d1985$med))
cat_d1985 <- d1985 %>% mutate(conventionality=ifelse(med <= median(d1985$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d1985 <- cat_d1985 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d1985') %>% 
mutate(percent=floor(100*count/length(d1985$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# AP 2005 dataset
ap2005 <- fread('ap2005_pubwise_zsc_med.csv')
print(median(ap2005$med))
cat_ap2005 <- ap2005 %>% mutate(conventionality=ifelse(med <= median(ap2005$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_ap2005 <- cat_ap2005 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='ap2005') %>% 
mutate(percent=floor(100*count/length(ap2005$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# subset of d2005 based on ap2005 source_ids
d2005_sub_ap <- d2005[d2005$source_id %in% ap2005$source_id] 
print(median(d2005_sub_ap$med))
cat_d2005_sub_ap <- d2005_sub_ap %>% 
mutate(conventionality=ifelse(med <= median(d2005_sub_ap$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d2005_sub_ap <- cat_d2005_sub_ap %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d2005_sub_ap') %>% 
mutate(percent=floor(100*count/length(d2005_sub_ap$source_id)),category=paste0(conventionality,novelty)) %>% data.frame() %>% select(gp,category,percent)

# AP 1995 dataset
ap1995 <- fread('ap1995_pubwise_zsc_med.csv')
print(median(ap1995$med))
cat_ap1995 <- ap1995 %>% mutate(conventionality=ifelse(med <= median(ap1995$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_ap1995 <- cat_ap1995 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='ap1995') %>% 
mutate(percent=floor(100*count/length(ap1995$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# subset of d1995 based on ap1995 source_ids
d1995_sub_ap <- d1995[d1995$source_id %in% ap1995$source_id] # loses one source_id
print(median(d1995_sub_ap$med))
cat_d1995_sub_ap <- d1995_sub_ap %>% 
mutate(conventionality=ifelse(med <= median(d1995_sub_ap$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d1995_sub_ap <- cat_d1995_sub_ap %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d1995_sub_ap') %>% 
mutate(percent=floor(100*count/length(d1995_sub_ap$source_id)),category=paste0(conventionality,novelty)) %>% data.frame() %>% select(gp,category,percent)

# AP 1985 dataset
ap1985 <- fread('ap1985_pubwise_zsc_med.csv')
print(median(ap1985$med))
cat_ap1985 <- ap1985 %>% mutate(conventionality=ifelse(med <= median(ap1985$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_ap1985 <- cat_ap1985 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='ap1985') %>% 
mutate(percent=floor(100*count/length(ap1985$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# subset of d1985 based on ap1985 source_ids
d1985_sub_ap <- d1985[d1985$source_id %in% ap1985$source_id] # loses one source_id
print(median(d1985_sub_ap$med))
cat_d1985_sub_ap <- d1985_sub_ap %>% 
mutate(conventionality=ifelse(med <= median(d1985_sub_ap$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d1985_sub_ap <- cat_d1985_sub_ap %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d1985_sub_ap') %>% 
mutate(percent=floor(100*count/length(d1985_sub_ap$source_id)),category=paste0(conventionality,novelty)) %>% data.frame() %>% select(gp,category,percent)
