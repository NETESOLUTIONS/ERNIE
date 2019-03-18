# script to compare z_scores from 1995 for imm, metab, physics

setwd("~/Desktop/p1000_calcs")
library(data.table); library(dplyr); library(ggplot2); library(extrafont)
rm(list = ls())

# imm95_pubwise_zsc_med.csv
imm95 <- fread('imm95_pubwise_zsc_med.csv')
# metab95_pubwise_zsc_med.csv
metab95 <- fread('metab95_pubwise_zsc_med.csv')
# ap1995_pubwise_zsc_med.csv
ap95 <- fread('ap1995_pubwise_zsc_med.csv')
# d1000_1995_pubwise_zsc_med.csv
wos95 <- fread('d1000_1995_pubwise_zsc_med.csv')

print(median(imm95$med))
cat_imm95 <- imm95 %>% 
mutate(conventionality = ifelse(med <= median(imm95$med), "LC", "HC")) %>% 
mutate(novelty = ifelse(ten >= 0, "LN", "HN"))
agg_imm95 <- cat_imm95 %>% 
group_by(conventionality, novelty) %>% 
summarize(count = length(source_id)) %>% 
mutate(gp = "imm95") %>% 
mutate(percent = round(100 * count/length(imm95$source_id)), 
  category = paste0(conventionality, novelty)) %>% 
data.frame() %>% select(gp, category, percent)

print(median(metab95$med))
cat_metab95 <- metab95 %>% 
mutate(conventionality = ifelse(med <= median(metab95$med), "LC", "HC")) %>% 
mutate(novelty = ifelse(ten >= 0, "LN", "HN"))
agg_metab95 <- cat_metab95 %>% 
group_by(conventionality, novelty) %>% 
summarize(count = length(source_id)) %>% 
mutate(gp = "metab95") %>% 
mutate(percent = round(100 * count/length(metab95$source_id)), 
  category = paste0(conventionality, novelty)) %>% 
data.frame() %>% select(gp, category, percent)

#ap95
print(median(ap95$med))
cat_ap95 <- ap95 %>% 
mutate(conventionality = ifelse(med <= median(ap95$med), "LC", "HC")) %>% 
mutate(novelty = ifelse(ten >= 0, "LN", "HN"))
agg_ap95 <- cat_ap95 %>% 
group_by(conventionality, novelty) %>% 
summarize(count = length(source_id)) %>% 
mutate(gp = "ap95") %>% 
mutate(percent = round(100 * count/length(ap95$source_id)), 
  category = paste0(conventionality, novelty)) %>% 
data.frame() %>% select(gp, category, percent)

#wos95
print(median(wos95$med))
cat_wos95 <- wos95 %>% 
mutate(conventionality = ifelse(med <= median(wos95$med), "LC", "HC")) %>% 
mutate(novelty = ifelse(ten >= 0, "LN", "HN"))
agg_wos95 <- cat_wos95 %>% 
group_by(conventionality, novelty) %>% 
summarize(count = length(source_id)) %>% 
mutate(gp = "wos95") %>% 
mutate(percent = round(100 * count/length(wos95$source_id)), 
  category = paste0(conventionality, novelty)) %>% 
data.frame() %>% select(gp, category, percent)

# wos95_sub_imm 
wos95_sub_imm <- wos95[wos95$source_id %in% imm95$source_id] 
print(median(wos95_sub_imm$med))
cat_wos95_sub_imm <- wos95_sub_imm %>% 
mutate(conventionality=ifelse(med <= median(wos95_sub_imm$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_wos95_sub_imm <- cat_wos95_sub_imm %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='wos95_sub_imm') %>% 
mutate(percent=round(100*count/length(wos95_sub_imm$source_id)),
 category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# wos95_sub_ap 
wos95_sub_ap <- wos95[wos95$source_id %in% ap95$source_id] 
print(median(wos95_sub_ap$med))
cat_wos95_sub_ap <- wos95_sub_ap %>% 
mutate(conventionality=ifelse(med <= median(wos95_sub_ap$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_wos95_sub_ap <- cat_wos95_sub_ap %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='wos95_sub_ap') %>% 
mutate(percent=round(100*count/length(wos95_sub_ap$source_id)),
 category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

# wos95_sub_metab 
wos95_sub_metab <- wos95[wos95$source_id %in% metab95$source_id] 
print(median(wos95_sub_metab$med))
cat_wos95_sub_metab <- wos95_sub_metab %>% 
mutate(conventionality=ifelse(med <= median(wos95_sub_metab$med),"LC","HC")) %>% 
mutate(novelty=ifelse(ten >= 0,"LN","HN"))
agg_wos95_sub_metab <- cat_wos95_sub_metab %>% 
group_by(conventionality,novelty) %>% 
summarize(count=length(source_id)) %>% 
mutate(gp='wos95_sub_metab') %>% 
mutate(percent=round(100*count/length(wos95_sub_metab$source_id)),
 category=paste0(conventionality,novelty)) %>% 
data.frame() %>% select(gp,category,percent)

barcomp <- rbind(agg_ap95,agg_imm95,agg_metab95,agg_wos95_sub_ap,agg_wos95_sub_imm,agg_wos95_sub_metab)
barcomp[barcomp$gp=='ap95',1] <- 'ap'
barcomp[barcomp$gp=='wos95_sub_ap',1] <- 'ap_wos'

barcomp[barcomp$gp=='imm95',1] <- 'imm'
barcomp[barcomp$gp=='wos95_sub_imm',1] <- 'imm_wos'

barcomp[barcomp$gp=='metab95',1] <- 'metab'
barcomp[barcomp$gp=='wos95_sub_metab',1] <- 'metab_wos'

barcomp$gp <- factor(barcomp$gp,levels=c('ap','ap_wos','imm','imm_wos','metab','metab_wos'))

pdf('bc1.pdf')
ggplot(barcomp, aes(y=percent, x=gp, color=gp,fill=gp)) + 
geom_bar(stat="identity") + 
facet_wrap(~category) +
theme(axis.text.x = element_text(angle = -60, hjust = 0)) + xlab("") + ylab("Percent of Publications") + theme(text=element_text(size=10,  family="Times New Roman"))  
dev.off()
## Zooming in to top 2% of pubs by citation count

imm_2 <- imm95[citation_count >= quantile(imm95$citation_count,0.98)]
print(median(imm_2$med))
cat_imm_2 <- imm_2 %>% 
mutate(conventionality = ifelse(med <= median(imm_2$med), "LC", "HC")) %>% 
mutate(novelty = ifelse(ten >= 0, "LN", "HN"))
agg_imm_2 <- cat_imm_2 %>% 
group_by(conventionality, novelty) %>% 
summarize(count = length(source_id)) %>% 
mutate(gp = "imm_2") %>% 
mutate(percent = round(100 * count/length(imm_2$source_id)), 
  category = paste0(conventionality, novelty)) %>% 
data.frame() %>% select(gp, category, percent)

ap_2 <- ap95[citation_count >= quantile(ap95$citation_count,0.98)]
print(median(ap_2$med))
cat_ap_2 <- ap_2 %>% 
mutate(conventionality = ifelse(med <= median(ap_2$med), "LC", "HC")) %>% 
mutate(novelty = ifelse(ten >= 0, "LN", "HN"))
agg_ap_2 <- cat_ap_2 %>% 
group_by(conventionality, novelty) %>% 
summarize(count = length(source_id)) %>% 
mutate(gp = "ap_2") %>% 
mutate(percent = round(100 * count/length(ap_2$source_id)), 
  category = paste0(conventionality, novelty)) %>% 
data.frame() %>% select(gp, category, percent)

metab_2 <- metab95[citation_count >= quantile(metab95$citation_count,0.98)]
print(median(metab_2$med))
cat_metab_2 <- metab_2 %>% 
mutate(conventionality = ifelse(med <= median(metab_2$med), "LC", "HC")) %>% 
mutate(novelty = ifelse(ten >= 0, "LN", "HN"))
agg_metab_2 <- cat_metab_2 %>% 
group_by(conventionality, novelty) %>% 
summarize(count = length(source_id)) %>% 
mutate(gp = "metab_2") %>% 
mutate(percent = round(100 * count/length(metab_2$source_id)), 
  category = paste0(conventionality, novelty)) %>% 
data.frame() %>% select(gp, category, percent)

wos95_2 <- wos95[citation_count >= quantile(imm95$citation_count,0.98)]
print(median(wos95_2$med))
cat_wos95_2 <- wos95_2 %>% 
mutate(conventionality = ifelse(med <= median(wos95_2$med), "LC", "HC")) %>% 
mutate(novelty = ifelse(ten >= 0, "LN", "HN"))
agg_wos95_2 <- cat_wos95_2 %>% 
group_by(conventionality, novelty) %>% 
summarize(count = length(source_id)) %>% 
mutate(gp = "wos_2") %>% 
mutate(percent = round(100 * count/length(wos95_2$source_id)), 
  category = paste0(conventionality, novelty)) %>% 
data.frame() %>% select(gp, category, percent)


barcomp_2 <- rbind(agg_ap_2,agg_ap95,agg_imm_2,agg_imm95,agg_metab_2,agg_metab95,agg_wos95_2,agg_wos95)
barcomp_2[barcomp_2$gp=='ap95',1] <- 'ap_all'
barcomp_2[barcomp_2$gp=='imm95',1] <- 'imm_all'
barcomp_2[barcomp_2$gp=='metab95',1] <- 'metab_all'
barcomp_2[barcomp_2$gp=='wos95',1] <- 'wos_all'

barcomp_2$gp <- factor(barcomp_2$gp,levels=c('ap_2','ap_all',
'imm_2','imm_all','metab_2','metab_all','wos_2','wos_all'))

pdf('bc2.pdf')
ggplot(barcomp_2, aes(y=percent, x=gp, color=gp,fill=gp)) + 
geom_bar( stat="identity") +    
facet_wrap(~category) + theme(axis.text.x = element_text(angle = -60, hjust = 0)) + xlab("") + ylab("Percent of Publications")+ theme(text=element_text(size=10,  family="Times New Roman"))  
dev.off()



