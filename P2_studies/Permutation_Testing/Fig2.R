# d95: background is also imm95
print(dim(cat_d95))
print(head(cat_d95,5))
setDT(cat_d95)
z <- data.frame()
x <-data.frame()
for(i in 1:10){
a <- quantile(cat_d95$citation_count,(100-i)/100)
print(unname(a))		
b <- dim(cat_d95[citation_count>=a])[1]
x <- cat_d95 %>% filter(citation_count >= a) %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% 
mutate(percent=round((100*count/b))) %>% mutate(class=paste0('top',i))
z <- rbind(z,x)
}
y <- cat_d95 %>% group_by(conventionality,novelty) %>% summarize(count=length(source_id)) %>% data.frame() %>% mutate(percent=round((100*count/dim(cat_d95)[1]))) %>% mutate(class='all')
z_d95 <-rbind(z,y)
z_d95 <<- z_d95 %>% mutate(gp=paste0(conventionality,novelty))
z_d95 <- z_d95 %>% mutate(bg=' imm95')
# insert missing rows on account of zero values
#t1 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top1',gp="LCLN",bg='imm95')
#t2 <- data.frame(conventionality="LC",novelty="LN",count=0,percent=0,class='top2',gp="LCLN",bg='imm95')
#z_d95 <- rbind(z_d95,t1,t2)
z_d95 <- z_d95 %>% arrange(class)
z_d95$class <- factor(z_d95$class, levels=c('top1','top2','top3','top4','top5','top6','top7','top8','top9','top10','all'))
x1 <- z_d95 %>% group_by(class,conventionality) %>% summarize(HC=sum(percent)) %>% filter(conventionality=='HC')
x2 <- z_d95 %>% group_by(class,novelty) %>% summarize(HN=sum(percent)) %>% filter(novelty=='HN')
x3 <- merge(x1,x2,by.x='class',by.y='class')
setDT(x3); x3 <- x3[,.(class,HC,HN)]
x4 <- melt(x3,id='class')
fwrite(x4,file='d95_x4.csv')
pdf('d95_trends.pdf')
qplot(class,value,group=variable,data=x4,color=variable,shape=variable,geom=c("point","line"),main="analysis of Conventionality and Novelty in d95 dataset\n487433 publications",ylab="Percent of Publications",xlab="Percentile Group (all = complete set)")
dev.off()

# Compare imm95 with d95
rm(list=ls())
imm95_x4 <- fread('imm95_x4.csv')
d95_x4 <- fread('d95_x4.csv')
imm95_x4 <- imm95_x4 %>% mutate(bg=' imm95')
d95_x4 <- d95_x4 %>% mutate(bg='all_wos95')
fig2 <- rbind(imm95_x4,d95_x4)

fig2$bg <- factor(fig2$bg,levels=c(" imm95","all_wos95"))
fig2$class <- factor(fig2$class,levels=c('top1','top2','top3','top4',
'top5','top6','top7','top8','top9','top10','all'))
pdf('fig1.pdf',height=5,width=7)
qplot(class,value,data=fig2,group=variable,color=variable,geom=c("point","line"),facets=.~bg,
#main="Comparison of biologically-themed network with all WoS\nin Measuring Conventionality and Novelty 21,000 & #487,433\n publications respectively",
xlab="Citation Percentile Group",ylab="Percent of Publications") + theme(axis.text.x=element_text(angle=-65, hjust=0))
dev.off()