setwd('~/Desktop/cc2')
rm(list=ls())
library(data.table);library(ggplot2); library(grid)
library(patchwork); library(extrafont)

x <- fread('scopus_freq.csv'); x <- x[complete.cases(x)]
pp <- data.frame(cbind(seq(0,100,by=1),unname(quantile(x$scopus_frequency,seq(0,1,by=0.01)))))
p1 <- qplot(X1,X2,data=pp,geom=c("point","line"),xlab="",ylab="frequency") +
theme_bw() + theme(text=element_text(family="Arial", size=18))
p2 <- qplot(X1,log(X2),data=pp,geom=c("point","line"),xlab="",ylab="ln(frequency)") +
theme_bw() + theme(text=element_text(family="Arial", size=18))

x <- fread('timelag3.csv')
# x[,lag:=first_co_cited_year-first_possible_year]
# x <- x[lag >= 0]
x[order(-scopus_frequency)]
setkey(x,scopus_frequency)

# x has 4119324 observations

q <- quantile(x$scopus_frequency,c(seq(0.01,1,by=0.01)))
q <- data.frame(perc=names(q), value=q, row.names=NULL)
# minor cleanup
q$perc <- gsub("%","",q$perc);q$perc <- as.integer(q$perc)
# add additional columns
q$total <- 0
q$connected <- 0

# insert first row of data for q$total & q$connected
q[1,3] <- x[scopus_frequency == q[1,2]][,.N]
q[1,4] <- x[scopus_frequency == q[1,2]][dc_state=='t'][,.N]

for(i in 2:dim(q)[1]) {
	print(i)
	q[i,3] <- x[scopus_frequency >= q[i-1,2] & scopus_frequency < q[i,2]][,.N]
	q[i,4] <- x[scopus_frequency >= q[i-1,2] & scopus_frequency < q[i,2]][dc_state=='t'][,.N]
}
setDT(q)
q1 <- q[total!=0]
q1[,proportion:=round(100*connected/total,1)]


p3 <- qplot(perc,proportion,data=q1,xlab="",ylab="percent connected",
ylim=c(0,50),geom=c("point","line"),group=1) + theme_bw() + theme(text=element_text(family="Arial", size=18))

p4 <- p1/p2 | p3
pdf('percent_connected2.pdf',h=5,w=7)
print(p4)
dev.off()

system('cp percent_connected2.pdf ~/cocitation_2/')
