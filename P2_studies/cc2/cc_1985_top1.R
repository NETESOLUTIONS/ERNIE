setwd('~/Desktop/cc2')
rm(list=ls())
library(data.table)
freq85 <- fread('obs_freq_1985_top1_frequency.csv')
lag85 <- fread('obs_freq_1985_top1_time_lag.csv')
fl85_top1 <- merge(freq85,lag85,by.x=c('cited_1','cited_2'),by.y=c('cited_1','cited_2'))

# clean up 
fl85_top1 <- fl85_top1[!(first_cited_year < cited_2_year | first_cited_year < cited_1_year)]
# first cited year minus latest pub_year of co-cited pair
fl85_top1[,maxdiff:=first_cited_year-pmax(cited_1_year,cited_2_year)]
# first cited year minus earliest pub_year of co-cited pair
fl85_top1[,mindiff:=first_cited_year-pmin(cited_1_year,cited_2_year)]
# difference between reference years
fl85_top1[,refdiff:=abs(cited_1_year-cited_2_year)]

pdf('cc_1985_top1a.pdf')
par(mfrow=c(2,2))
plot(table(fl85_top1$mindiff),xlim=c(0,130),ylim=c(0,9000))
plot(table(fl85_top1$maxdiff),xlim=c(0,130),ylim=c(0,9000))
plot(table(fl85_top1$refdiff),xlim=c(0,130),ylim=c(0,9000))
plot(table(fl85_top1$first_cited_year))
dev.off()

pdf('cc_1985_top1b.pdf')
par(mfrow=c(2,2))
plot(fl85_top1$mindiff,fl85_top1$frequency)
hist(fl85_top1$mindiff,main="mindiff hist")
plot(fl85_top1$maxdiff,fl85_top1$frequency)
hist(fl85_top1$maxdiff,main="maxdiff hist")
dev.off()


#clustering
mydata <- fl85_top1[,.(frequency,scopus_frequency,mindiff,maxdiff,refdiff)]
md <- scale(mydata)
d <- dist(md[,-1])
hc <- hclust(d, method='average')
labels <- cutree(hc, k = 3)
mydata$groups <- labels
qplot(refdiff,scopus_frequency,data=mydata,facets=groups~.)
