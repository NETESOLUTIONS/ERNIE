source('state_85.R')
rm(list=setdiff(ls(), c("cat_metab85","cat_d85_sub_metab" )))

# Metab85 background is Metab85
print(dim(cat_metab85))
print(head(cat_metab85,5))
setDT(cat_metab85)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_metab85$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_metab85[citation_count>=a])[1]
x <- cat_metab85 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_metab85 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_metab85)[1]))) %>% mutate(class='all')
z_metab <-rbind(z,y)
z_metab <<- z_metab %>% mutate(gp=paste0(conventionality,novelty))
z_metab <- z_metab %>% mutate(bg=' metab85')
# insert missing rows on account of zero values
##3t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='imm85')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='imm85')
#z_imm <- rbind(z_imm,t1,t2)
z_metab <- z_metab %>% arrange(class)
z_metab$class <- factor(z_metab$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_metab %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_metab %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='metab85_x4.csv',row.names=FALSE)
pdf('metab85_trends.pdf')
qplot(class,value,group=variable,data=x4,color=variable,shape=variable,geom=c("point","line"),main="analysis of Conventionality and Novelty in Imm85 dataset\n Metab85 Background",ylab="Percent of Publications",xlab="Percentile Group (all = complete set)")
dev.off()

source('state_85.R')
rm(list=setdiff(ls(), c("cat_d85_sub_metab", "cat_d85_sub_bl85","cat_d85_sub_metab","cat_d85_sub_metab")))

# Metab85, background is cat_d85_sub_metab
print(dim(cat_d85_sub_metab))
print(head(cat_d85_sub_metab,5))
setDT(cat_d85_sub_metab)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d85_sub_metab$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d85_sub_metab[citation_count>=a])[1]
x <- cat_d85_sub_metab %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d85_sub_metab %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d85_sub_metab)[1]))) %>% mutate(class='all')
z_metab_sub_d85 <-rbind(z,y)
z_metab_sub_d85 <<- z_metab_sub_d85 %>% mutate(gp=paste0(conventionality,novelty))
z_metab_sub_d85 <- z_metab_sub_d85 %>% mutate(bg=' imm_sub_d85')
# insert missing rows on account of zero values
#t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='cs85')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='cs85')
#z_imm_sub_d85 <- rbind(z_imm_sub_d85,t1,t2)
z_metab_sub_d85 <- z_metab_sub_d85 %>% arrange(class)
z_metab_sub_d85$class <- factor(z_metab_sub_d85$class, levels=c('all','top10','top9','top8','top7','top6','top5','top4','top3','top2','top1'))
x1 <- z_metab_sub_d85 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_metab_sub_d85 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='metab_d85_x4.csv',row.names=FALSE)
pdf('metab85_trends_wosbg.pdf')
qplot(class,value,group=variable,data=x4,color=variable,shape=variable,geom=c("point","line"),main="analysis of Conventionality and Novelty in Metab85 dataset\n d85 Background",ylab="Percent of Publications",xlab="Percentile Group (all = complete set)")
dev.off()



