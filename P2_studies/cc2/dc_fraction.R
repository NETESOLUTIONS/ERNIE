# Author: George Chacko
# Feb 14, 2020
# Source data derived from ERNIE
# \copy (select scopus_frequency,citing_papers,
# NTILE(1000) OVER(ORDER BY SCOPUS_FREQUENCY DESC) AS bin_sf 
# FROM ten_year_cocit_union_freq11_freqsum_bins) 
# to '~/sf_bins.csv' with (format csv,header);

# clear workspace
rm(list=ls())
setwd('~/Desktop/cc2')
library(data.table);library(ggplot2)
# import data
x <- fread('~/Desktop/cc2/sf_bins.csv')
# calculate number of observation in each bin for data in 10 bins
x[,nrows:=length(scopus_frequency),by=bin_sf10]
#### 45% of pairs have scopus_frequency =1 and are spread across multiple bins 6-10
#### Thus shuffle values for scopus_frequency==1 to avoid any PostgreSQL derived ordering
preshuffle <- x[scopus_frequency==1]
preshuffle[,shuffled:=sample(bin_sf10)]
postshuffle <- preshuffle[,.(scopus_frequency,citing_papers,bin_sf1000,bin_sf100,bin_sf10=shuffled,nrows)]
# recombine
x <- rbind(x[scopus_frequency>1],postshuffle)
# calculate median scopus frequency for data in 10 bins
x[,msf:=median(scopus_frequency),by='bin_sf10']
# count cases where members of a co-cited pair cite each other at least once
y <- x[citing_papers=='t',length(scopus_frequency),by=c('bin_sf10','msf','nrows')]
p <- qplot(as.factor(bin_sf10),V1/nrows,data=y,geom=c('point','line'),group=1,
ylab="Proportion of Directly Cited Pairs",xlab="All Observations")
pdf('eureka.pdf')
print(p)
dev.off()

# subset data to 90th percentile akatop 10% (bin_sf10 is equal to 1)
x90 <- x[bin_sf10==1,.(scopus_frequency,citing_papers,bin_sf100,nrows)]
x90[,msf:=median(scopus_frequency),by='bin_sf100']
y90 <- x90[citing_papers=='t',length(scopus_frequency),by=c('bin_sf100','nrows','msf')]
p90 <- qplot(as.factor(bin_sf100),10*V1/nrows,data=y90,geom=c('point','line'),group=1,
xlab="> 90th percentile") + theme(axis.title.y = element_blank())

pdf('eureka90.pdf')
print(p90)
dev.off()

# subset data to 99th percentile akatop 10% (bin_sf100 is equal to 1)
x99 <- x[bin_sf100==1,.(scopus_frequency,citing_papers,bin_sf1000,nrows)]
x99[,msf:=median(scopus_frequency),by='bin_sf1000']
y99 <- x99[citing_papers=='t',length(scopus_frequency),by=c('bin_sf1000','nrows','msf')]
p99 <- qplot(as.factor(bin_sf1000),100*V1/nrows,data=y99,geom=c('point','line'),group=1,
xlab="> 99th percentile") + theme(axis.title.y = element_blank())
pdf('eureka99.pdf')
print(p99)
dev.off()

composite <- p+ annotation_custom(ggplotGrob(p90),xmin=3,xmax=6,ymin=0.05,ymax=0.15) + annotation_custom(ggplotGrob(p99),xmin=7,xmax=10,ymin=0.075,ymax=0.175)

# generate composite figure
pdf('eureka_composite.pdf')
print(composite)
dev.off()





