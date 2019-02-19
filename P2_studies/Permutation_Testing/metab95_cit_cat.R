setwd('~/Desktop/Fig1')
rm(list=ls())
load('.RData')
library(dplyr); library(data.table); library(ggplot2)

#metab95 dataset
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
# assign(paste0('top',i),x)
y <- cat_metab95 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_metab95)[1]))) %>% mutate(class='all')
z <-rbind(z,y)
z <<- z %>% mutate(gp=paste0(conventionality,novelty))
z$class <- factor(z$class, levels=c('all','top1','top2','top3','top4','top5','top6','top7','top8','top9','top10'))
z <- z %>% mutate(bg=' metab95')

print(dim(cat_d95_sub_metab))
print(head(cat_d95_sub_metab,5))
setDT(cat_d95_sub_metab)
z1 <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d95_sub_metab$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d95_sub_metab[citation_count>=a])[1]
x <- cat_d95_sub_metab %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z1 <- rbind(z1,x)
}
# assign(paste0('top',i),x)
y1 <- cat_d95_sub_metab %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d95_sub_metab)[1]))) %>% mutate(class='all')
z1 <-rbind(z1,y1)
z1 <<- z1 %>% mutate(gp=paste0(conventionality,novelty))
z1$class <- factor(z1$class, levels=c('all','top1','top2','top3','top4','top5','top6','top7','top8','top9','top10'))
z1 <- z1 %>% mutate(bg='d95_sub_metab')
Z_metab <- rbind(z,z1)

setDT(Z_metab)
temp <- Z_metab[class=='top1'|class=='all']
dodge <- position_dodge(width = 0.5)
pdf('metab95.pdf')
ggplot(temp,aes(gp,percent)) + geom_bar(aes(fill = class), stat="identity",position=dodge, width=0.5)  + facet_grid(bg ~ .) + ggtitle("Metab95")
dev.off()

