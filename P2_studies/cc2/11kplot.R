setwd('~/Desktop/cc2')
rm(list=ls())
library(data.table);
x <- fread('ten_year_cocit_union_freq11_freqsum.csv')
pp <- data.frame(cbind(seq(0,100,by=1),unname(quantile(x$fsum,seq(0,1,by=0.01)))))
p1 <- qplot(X1,X2,data=pp,geom=c("point","line"),xlab="Percentile",ylab="Co-citation Frequency")
p2 <- qplot(X1,log(X2),data=pp,geom=c("point","line"),xlab="Percentile",ylab="ln(Co-citation Frequency)")
vp <- viewport(width = 0.6, height = 0.4, x = 0.5, y = 0.7)
pdf('11k_plot.pdf')
print(p1)
print(p2,vp=vp)
dev.off()

