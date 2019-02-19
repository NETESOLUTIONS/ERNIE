source('state.R')
rm(list=setdiff(ls(), c("cat_metab95", "cat_bl95","cat_metab95","cat_metab95")))

# Metab95 background is Metab95
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
z_metab <-rbind(z,y)
z_metab <<- z_metab %>% mutate(gp=paste0(conventionality,novelty))
z_metab <- z_metab %>% mutate(bg=' metab95')
# insert missing rows on account of zero values
##3t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='imm95')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='imm95')
#z_imm <- rbind(z_imm,t1,t2)
z_metab <- z_metab %>% arrange(class)
z_metab$class <- factor(z_metab$class, levels=c('top1','top2','top3','top4','top5','top6','top7','top8','top9','top10','all'))
x1 <- z_metab %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_metab %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='metab95_x4.csv',row.names=FALSE)
pdf('metab95_trends.pdf')
qplot(class,value,group=variable,data=x4,color=variable,shape=variable,geom=c("point","line"),main="analysis of Conventionality and Novelty in Imm95 dataset\n Metab95 Background",ylab="Percent of Publications",xlab="Percentile Group (all = complete set)")
dev.off()

source('state.R')
rm(list=setdiff(ls(), c("cat_d95_sub_metab", "cat_d95_sub_bl95","cat_d95_sub_metab","cat_d95_sub_metab")))

# Metab95, background is cat_d95_sub_metab
print(dim(cat_d95_sub_metab))
print(head(cat_d95_sub_metab,5))
setDT(cat_d95_sub_metab)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d95_sub_metab$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d95_sub_metab[citation_count>=a])[1]
x <- cat_d95_sub_metab %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d95_sub_metab %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d95_sub_metab)[1]))) %>% mutate(class='all')
z_metab_sub_d95 <-rbind(z,y)
z_metab_sub_d95 <<- z_metab_sub_d95 %>% mutate(gp=paste0(conventionality,novelty))
z_metab_sub_d95 <- z_metab_sub_d95 %>% mutate(bg=' imm_sub_d95')
# insert missing rows on account of zero values
#t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='cs95')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='cs95')
#z_imm_sub_d95 <- rbind(z_imm_sub_d95,t1,t2)
z_metab_sub_d95 <- z_metab_sub_d95 %>% arrange(class)
z_metab_sub_d95$class <- factor(z_metab_sub_d95$class, levels=c('top1','top2','top3','top4','top5','top6','top7','top8','top9','top10','all'))
x1 <- z_metab_sub_d95 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_metab_sub_d95 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='metab_d95_x4.csv',row.names=FALSE)
pdf('metab95_trends_wosbg.pdf')
qplot(class,value,group=variable,data=x4,color=variable,shape=variable,geom=c("point","line"),main="analysis of Conventionality and Novelty in Metab95 dataset\n d95 Background",ylab="Percent of Publications",xlab="Percentile Group (all = complete set)")
dev.off()



