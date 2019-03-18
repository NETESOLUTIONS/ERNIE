source('state.R')
rm(list=setdiff(ls(), c("cat_imm95", "cat_bl95","cat_imm95","cat_metab95")))

# Imm95 background is imm95
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
z_imm <-rbind(z,y)
z_imm <<- z_imm %>% mutate(gp=paste0(conventionality,novelty))
z_imm <- z_imm %>% mutate(bg=' imm95')
# insert missing rows on account of zero values
##3t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='imm95')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='imm95')
#z_imm <- rbind(z_imm,t1,t2)
z_imm <- z_imm %>% arrange(class)
z_imm$class <- factor(z_imm$class, levels=c('top1','top2','top3','top4','top5','top6','top7','top8','top9','top10','all'))
x1 <- z_imm %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_imm %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='imm95_x4.csv')
pdf('imm95_trends.pdf')
qplot(class,value,group=variable,data=x4,color=variable,shape=variable,geom=c("point","line"),main="analysis of Conventionality and Novelty in Imm95 dataset\n Imm95 Background",ylab="Percent of Publications",xlab="Percentile Group (all = complete set)")
dev.off()

source('state.R')
rm(list=setdiff(ls(), c("cat_d95_sub_imm", "cat_d95_sub_bl95","cat_d95_sub_imm","d95_sub_metab")))

# Imm95, background is cat_d95_sub_imm
print(dim(cat_d95_sub_imm))
print(head(cat_d95_sub_imm,5))
setDT(cat_d95_sub_imm)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d95_sub_imm$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d95_sub_imm[citation_count>=a])[1]
x <- cat_d95_sub_imm %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d95_sub_imm %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d95_sub_imm)[1]))) %>% mutate(class='all')
z_imm_sub_d95 <-rbind(z,y)
z_imm_sub_d95 <<- z_imm_sub_d95 %>% mutate(gp=paste0(conventionality,novelty))
z_imm_sub_d95 <- z_imm_sub_d95 %>% mutate(bg=' imm_sub_d95')
# insert missing rows on account of zero values
#t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='cs95')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='cs95')
#z_imm_sub_d95 <- rbind(z_imm_sub_d95,t1,t2)
z_imm_sub_d95 <- z_imm_sub_d95 %>% arrange(class)
z_imm_sub_d95$class <- factor(z_imm_sub_d95$class, levels=c('top1','top2','top3','top4','top5','top6','top7','top8','top9','top10','all'))
x1 <- z_imm_sub_d95 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_imm_sub_d95 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='imm_d95_x4.csv')
pdf('imm95_trends_wosbg.pdf')
qplot(class,value,group=variable,data=x4,color=variable,shape=variable,geom=c("point","line"),main="analysis of Conventionality and Novelty in Imm95 dataset\n d95 Background",ylab="Percent of Publications",xlab="Percentile Group (all = complete set)")
dev.off()

