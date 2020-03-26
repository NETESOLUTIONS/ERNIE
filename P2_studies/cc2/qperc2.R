# a simple script to calculate percentage of connected co-cited pairs
# as a function of percentile groups of frequency. 

setwd('~/Desktop/cc2/')
rm(list=ls()); library(data.table); library(ggplot2); library(extrafont)

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
# 3 is total an 4 is connected
q[1,3] <- x[scopus_frequency == q[1,2]][,.N]
q[1,4] <- x[scopus_frequency == q[1,2]][dc_state=='t'][,.N]

for(i in 2:dim(q)[1]) {
	print(i)
	q[i,3] <- x[scopus_frequency >= q[i-1,2] & scopus_frequency < q[i,2]][,.N]
	q[i,4] <- x[scopus_frequency >= q[i-1,2] & scopus_frequency < q[i,2]][dc_state=='t'][,.N]
}
setDT(q)
# strip rows with zero values
q1 <- q[total!=0]
qplot(perc,round(100*connected/total),data=q1,geom=c("point","line"))

# add column for calculated proportion as percent
q1[,proportion:=round(100*connected/total,1)]

# generate plot
pdf('percent_connected1.pdf')
qplot(perc,proportion,data=q1,xlab="co-citation frequency percentile group",ylab="percent connected",ylim=c(0,50),geom=c("point","line"),group=1) + 
theme_bw() + theme(text=element_text(family="Arial", size=20))
dev.off()
system('cp percent_connected1.pdf ~/cocitation_2/')
