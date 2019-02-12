# script to compare z_scores from whole year slice vs case study set
setwd('~/Desktop/Fig1')
library(data.table)
library(dplyr)
rm(list=ls())

# Whole year slice
d95 <- fread('d95_pubwise_cit.csv')
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
# High conventionality is > median of median z_scores
# High novelty is tenth percentile of < 0
imm95 <- fread('imm95_pubwise_cit.csv')
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

#reduce number of columns hence `slim`
slim_imm95sub <- cat_imm95 %>% select(source_id,conventionality, novelty)
slim_d95sub_imm <- cat_d95_sub_imm %>% select(source_id,conventionality, novelty)
fat_imm <- merge(slim_imm95sub,slim_d95sub_imm,by.x='source_id',by.y='source_id')
colnames(fat_imm) <- c("source_id","conventionality.imm","novelty.imm","conventionality.wos","novelty.wos")
fat_s_imm <- fat_imm %>% mutate(state_change=ifelse(conventionality.imm==conventionality.wos & 
novelty.imm==novelty.wos,0,1))

setDT(fat_s_imm)
x <- fat_s_imm[state_change==1]
sc_imm95 <- imm95[imm95$source_id %in% x$source_id,]
sc_d95_sub_imm <- d95_sub_imm[d95_sub_imm$source_id %in% x$source_id,]
fwrite(sc_d95_sub_imm,file='sc_d95_sub_imm.csv',row.names=FALSE)
fwrite(sc_imm95,file='sc_imm95.csv',row.names=FALSE)
fwrite(d95_sub_imm,file='d95_sub.csv',row.names=FALSE)

# metabolism dataset 
metab95 <- fread('metab95_pubwise_cit.csv')
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

# comp_imm95_pubwise_cit.csv (size matched sample)
comp_imm95 <- fread('comp_imm95_pubwise_cit.csv')
cat_comp_imm95 <- comp_imm95 %>% 
mutate(conventionality=ifelse(med <= median(comp_imm95$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_comp_imm95 <- cat_comp_imm95 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='comp_imm95') %>% 
mutate(percent=floor(100*count/length(cat_comp_imm95$source_id)),category=paste0(conventionality,novelty)) %>% data.frame() %>% select(gp,category,percent)

# comp_metab95_pubwise_cit.csv (size matched sample)

###################################
#blast dataset (years 1995-2000)
bl95 <- fread('bl95_pubwise_cit.csv')
cat_bl95 <- bl95 %>% mutate(conventionality=ifelse(med <= median(bl95$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_bl95 <- cat_bl95 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='bl95') %>% 
mutate(percent=floor(100*count/length(bl95$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# subset of d95 based on bl95 source_ids
d95_sub_bl95 <- d95[d95$source_id %in% bl95$source_id] 
cat_d95_sub_bl95 <- d95_sub_bl95 %>% mutate(conventionality=ifelse(med <= median(d95_sub_bl95$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d95_sub_bl95 <- cat_d95_sub_bl95 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d95_sub_bl95') %>% 
mutate(percent=floor(100*count/length(d95_sub_bl95$source_id)),
category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

#cocit_search dataset (years 1990-2000)
cs95 <- fread('cs95_pubwise_cit.csv')
cat_cs95 <- cs95 %>% 
mutate(conventionality=ifelse(med <= median(cs95$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_cs95 <- cat_cs95 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='cs95') %>% 
mutate(percent=floor(100*count/length(cs95$source_id)),category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# subset of d95 based on cs95 source_ids
d95_sub_cs95 <- d95[d95$source_id %in% cs95$source_id] 
cat_d95_sub_cs95 <- d95_sub_cs95 %>% 
mutate(conventionality=ifelse(med <= median(d95_sub_cs95$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_d95_sub_cs95 <- cat_d95_sub_cs95 %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='d95_sub_cs95') %>% 
mutate(percent=floor(100*count/length(d95_sub_cs95$source_id)),
category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

CIT95 <- rbind(agg_bl95,agg_d95_sub_bl95,agg_cs95,agg_d95_sub_cs95)

ggplot(y,aes(category,count))  +   
geom_bar(aes(fill = gp), position = "dodge", width=0.5, stat="identity") + 
ggtitle("Comparison of Category Counts in Imm95 and Wos95 Background \n 97,531 publications") + xlab("Categories of Conventionality and Novelty") + ylab("Count of Publications")