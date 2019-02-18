source('state.R')
rm(list=setdiff(ls(), c("cat_cs95", "cat_bl95","cat_imm95","cat_metab95")))

# Cocit95 background is cocit95
print(dim(cat_cs95))
print(head(cat_cs95,5))
setDT(cat_cs95)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_cs95$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_cs95[citation_count>=a])[1]
x <- cat_cs95 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_cs95 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_cs95)[1]))) %>% mutate(class='all')
z_cs <-rbind(z,y)
z_cs <<- z_cs %>% mutate(gp=paste0(conventionality,novelty))
z_cs <- z_cs %>% mutate(bg=' cs95')
# insert missing rows on account of zero values
t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='cs95')
t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='cs95')
z_cs <- rbind(z_cs,t1,t2)
z_cs <- z_cs %>% arrange(class)
z_cs$class <- factor(z_cs$class, levels=c('top1','top2','top3','top4','top5','top6','top7','top8','top9','top10','all'))
x1 <- z_cs %>% group_by(class,conventionality) %>% summarize(frac_HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_cs %>% group_by(class,novelty) %>% summarize(frac_HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,frac_HC,frac_HN)]
x4 <- melt(x3,id='class')
pdf('cocit95_trends.pdf')
qplot(class,value,group=variable,data=x4,color=variable,shape=variable,geom=c("point","line"),main="analysis of Conventionality and Novelty in Cocit_S dataset\n Co-cit95 Background",ylab="Percent of Publications",xlab="Percentile Group (all = complete set)")
dev.off()

source('state.R')
rm(list=setdiff(ls(), c("cat_d95_sub_cs95", "cat_d95_sub_bl95","d95_sub_imm","d95_sub_metab")))

# Cocit95, background is cat_d95_sub_cs95
print(dim(cat_d95_sub_cs95))
print(head(cat_d95_sub_cs95,5))
setDT(cat_d95_sub_cs95)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d95_sub_cs95$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d95_sub_cs95[citation_count>=a])[1]
x <- cat_d95_sub_cs95 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d95_sub_cs95 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d95_sub_cs95)[1]))) %>% mutate(class='all')
z_cs_sub_d95 <-rbind(z,y)
z_cs_sub_d95 <<- z_cs_sub_d95 %>% mutate(gp=paste0(conventionality,novelty))
z_cs_sub_d95 <- z_cs_sub_d95 %>% mutate(bg=' cs_sub_d95')
# insert missing rows on account of zero values
#t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='cs95')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='cs95')
#z_cs_sub_d95 <- rbind(z_cs_sub_d95,t1,t2)
z_cs_sub_d95 <- z_cs_sub_d95 %>% arrange(class)
z_cs_sub_d95$class <- factor(z_cs_sub_d95$class, levels=c('top1','top2','top3','top4','top5','top6','top7','top8','top9','top10','all'))
x1 <- z_cs_sub_d95 %>% group_by(class,conventionality) %>% summarize(frac_HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_cs_sub_d95 %>% group_by(class,novelty) %>% summarize(frac_HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,frac_HC,frac_HN)]
x4 <- melt(x3,id='class')
pdf('cocit95_trends_wosbg.pdf')
qplot(class,value,group=variable,data=x4,color=variable,shape=variable,geom=c("point","line"),main="analysis of Conventionality and Novelty in Cocit_S dataset\n d95 Background",ylab="Percent of Publications",xlab="Percentile Group (all = complete set)")
dev.off()

