# list of input files

setwd('~/Desktop/composite')
rm(list=ls())
library(data.table); library(dplyr); library(ggplot2);
# creates categorically labeled (HC/HN) pubs
source('~/Desktop/composite/state_composite.R')
# remove all files except the following four to keep workspace clean
rm(list=setdiff(ls(), c("cat_ap95","cat_imm95","cat_metab95","cat_wos95",
"cat_wos95_sub_ap","cat_wos95_sub_imm","cat_wos95_sub_metab")))
setwd('~/Desktop/composite')

# wos95
print(dim(cat_wos95))
print(head(cat_wos95,5))
setDT(cat_wos95)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_wos95$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_wos95[citation_count>=a])[1]
x <- cat_wos95 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_wos95 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_wos95)[1]))) %>% mutate(class='all')
z_wos95 <-rbind(z,y)
z_wos95 <- z_wos95 %>% mutate(gp=paste0(conventionality,novelty))
z_wos95 <- z_wos95 %>% mutate(bg=' wos95')
z_wos95 <- z_wos95 %>% arrange(class)
z_wos95$class <- factor(z_wos95$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_wos95 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_wos95 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='wos95_x4.csv')

# ap95
print(dim(cat_ap95))
print(head(cat_ap95,5))
setDT(cat_ap95)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_ap95$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_ap95[citation_count>=a])[1]
x <- cat_ap95 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_ap95 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_ap95)[1]))) %>% mutate(class='all')
z_ap95 <-rbind(z,y)
z_ap95 <- z_ap95 %>% mutate(gp=paste0(conventionality,novelty))
z_ap95 <- z_ap95 %>% mutate(bg=' ap95')
z_ap95 <- z_ap95 %>% arrange(class)
z_ap95$class <- factor(z_ap95$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_ap95 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_ap95 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='ap95_x4.csv')

# imm95
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
z_imm95 <-rbind(z,y)
z_imm95 <- z_imm95 %>% mutate(gp=paste0(conventionality,novelty))
z_imm95 <- z_imm95 %>% mutate(bg=' imm95')
z_imm95 <- z_imm95 %>% arrange(class)
z_imm95$class <- factor(z_imm95$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_imm95 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_imm95 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='imm95_x4.csv')

# metab95
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
z_metab95 <-rbind(z,y)
z_metab95 <- z_metab95 %>% mutate(gp=paste0(conventionality,novelty))
z_metab95 <- z_metab95 %>% mutate(bg=' metab95')
z_metab95 <- z_metab95 %>% arrange(class)
z_metab95$class <- factor(z_metab95$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_metab95 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_metab95 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='metab95_x4.csv')
##############
# using wos95 backgrounds for ap,imm, and metab
# cat_wos95_sub_ap
print(dim(cat_wos95_sub_ap))
print(head(cat_wos95_sub_ap,5))
setDT(cat_wos95_sub_ap)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_wos95_sub_ap$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_wos95_sub_ap[citation_count>=a])[1]
x <- cat_wos95_sub_ap %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_wos95_sub_ap %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_wos95_sub_ap)[1]))) %>% mutate(class='all')
z_wos95_sub_ap <-rbind(z,y)
z_wos95_sub_ap <- z_wos95_sub_ap %>% mutate(gp=paste0(conventionality,novelty))
z_wos95_sub_ap <- z_wos95_sub_ap %>% mutate(bg=' ap_wos95')
z_wos95_sub_ap <- z_wos95_sub_ap %>% arrange(class)
z_wos95_sub_ap$class <- factor(z_wos95_sub_ap$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_wos95_sub_ap %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_wos95_sub_ap %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='ap_wos95_x4.csv')

# cat_wos95_sub_imm
print(dim(cat_wos95_sub_imm))
print(head(cat_wos95_sub_imm,5))
setDT(cat_wos95_sub_imm)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_wos95_sub_imm$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_wos95_sub_imm[citation_count>=a])[1]
x <- cat_wos95_sub_imm %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_wos95_sub_imm %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_wos95_sub_imm)[1]))) %>% mutate(class='all')
z_wos95_sub_imm <-rbind(z,y)
z_wos95_sub_imm <- z_wos95_sub_imm %>% mutate(gp=paste0(conventionality,novelty))
z_wos95_sub_imm <- z_wos95_sub_imm %>% mutate(bg=' imm_wos95')
z_wos95_sub_imm <- z_wos95_sub_imm %>% arrange(class)
z_wos95_sub_imm$class <- factor(z_wos95_sub_imm$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_wos95_sub_imm %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_wos95_sub_imm %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='imm_wos95_x4.csv')

# cat_wos95_sub_metab
print(dim(cat_wos95_sub_metab))
print(head(cat_wos95_sub_metab,5))
setDT(cat_wos95_sub_metab)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_wos95_sub_metab$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_wos95_sub_metab[citation_count>=a])[1]
x <- cat_wos95_sub_metab %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_wos95_sub_metab %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_wos95_sub_metab)[1]))) %>% mutate(class='all')
z_wos95_sub_metab <-rbind(z,y)
z_wos95_sub_metab <- z_wos95_sub_metab %>% mutate(gp=paste0(conventionality,novelty))
z_wos95_sub_metab <- z_wos95_sub_metab %>% mutate(bg=' metab_wos95')
z_wos95_sub_metab <- z_wos95_sub_metab %>% arrange(class)
z_wos95_sub_metab$class <- factor(z_wos95_sub_metab$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_wos95_sub_metab %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_wos95_sub_metab %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='metab_wos95_x4.csv')

# clean up workspace
rm(list=ls())
# read relevant data back in 

wos95_x4 <- fread('wos95_x4.csv')
ap95_x4 <- fread('ap95_x4.csv')
imm95_x4 <- fread('imm95_x4.csv')
metab95_x4 <- fread('metab95_x4.csv')

ap_wos95_x4 <- fread('ap_wos95_x4.csv')
imm_wos95_x4 <- fread('imm_wos95_x4.csv')
metab_wos95_x4 <- fread('metab_wos95_x4.csv')

# add extra fields for faceting by group

wos95_x4[,`:=`(gp='wos95')]
ap95_x4[,`:=`(gp='ap95')]
imm95_x4[,`:=`(gp='imm95')]
metab95_x4[,`:=`(gp='metab95')]

ap_wos95_x4[,`:=`(gp='ap_wos95')]
imm_wos95_x4[,`:=`(gp='imm_wos95')]
metab_wos95_x4[,`:=`(gp='metab_wos95')]

composite1 <- rbind(wos95_x4,ap95_x4,imm95_x4,metab95_x4)

composite1$class <- factor(composite1$class,levels=c('all','top10',
'top9','top8','top7','top6','top5',
'top4','top3','top2','top1'))
composite1$gp <- 
factor(composite1$gp,levels=c('ap95','imm95','metab95','wos95'))
library(ggplot2); library(extrafont)
pdf('fig1a.pdf')
qplot(class, value, group=gp, color=gp, data=composite1, geom=c('line','point'),facets=variable~.,xlab="Citation Count Percentile Group",ylab="Percent of Publications") + theme(text=element_text(size=10,  family="Times New Roman")) + theme(axis.text.x = element_text(angle = -70, hjust = 0))
dev.off()

composite2 <- rbind(ap95_x4, ap_wos95_x4,
imm95_x4, imm_wos95_x4,
metab95_x4, metab_wos95_x4)
composite2$class <- factor(composite2$class,levels=c('all','top10',
'top9','top8','top7','top6','top5',
'top4','top3','top2','top1'))
composite2$gp <- 
factor(composite2$gp,levels=c('ap95','ap_wos95','imm95','imm_wos95','metab95','metab_wos95'))

pdf('fig1b.pdf')
qplot(class, value, group=gp, color=gp, data=composite2, geom=c('line','point'),facets=variable~.,xlab="Citation Count Percentile Group",ylab="Percent of Publications") + theme(text=element_text(size=10,  family="Times New Roman")) + theme(axis.text.x = element_text(angle = -70, hjust = 0))
dev.off()


