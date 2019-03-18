setwd('~/Desktop/p1000_calcs')
library(dplyr); library(data.table); library(ggplot2)

#imm85 dataset imm85 background
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
z <-rbind(z,y)
z <<- z %>% mutate(gp=paste0(conventionality,novelty))
z$class <- factor(z$class, levels=c('all','top1','top2','top3','top4','top5','top6','top7','top8','top9','top10'))
z <- z %>% mutate(bg=' imm85')

#imm85 dataset d85 background
print(dim(cat_d85_sub_imm))
print(head(cat_d85_sub_imm,5))
setDT(cat_d85_sub_imm)
z1 <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d85_sub_imm$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d85_sub_imm[citation_count>=a])[1]
x <- cat_d85_sub_imm %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z1 <- rbind(z1,x)
}
# assign(paste0('top',i),x)
y1 <- cat_d85_sub_imm %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d85_sub_imm)[1]))) %>% mutate(class='all')
z1 <-rbind(z1,y1)
z1 <<- z1 %>% mutate(gp=paste0(conventionality,novelty))
z1$class <- factor(z1$class, levels=c('all','top1','top2','top3','top4','top5','top6','top7','top8','top9','top10'))
z1 <- z1 %>% mutate(bg='d85_sub_imm')
Z_imm <- rbind(z,z1)

setDT(Z_imm)
temp <- Z_imm[class=='top1'|class=='all']
dodge <- position_dodge(width = 0.5)
pdf('imm85.pdf')
ggplot(temp,aes(gp,percent)) + geom_bar(aes(fill = class), stat="identity",position=dodge, width=0.5)  + facet_grid(bg ~ .) + ggtitle("Imm85")
dev.off()
