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

q <- quantile(x$scopus_frequency,c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0))
q <- data.frame(perc=names(q), value=q, row.names=NULL)
# minor cleanup
q$perc <- gsub("%","",q$perc);q$perc <- as.integer(q$perc)
# add additional columns
q$total <- 0
q$connected <- 0

# insert first row of data for q$total & q$connected
q[1,3] <- x[scopus_frequency < q[1,2]][,.N]
q[1,4] <- x[scopus_frequency < q[1,2]][dc_state=='t'][,.N]

for(i in 2:dim(q)[1]) {
	print(i)
	q[i,3] <- x[scopus_frequency >= q[i-1,2] & scopus_frequency < q[i,2]][,.N]
	q[i,4] <- x[scopus_frequency >= q[i-1,2] & scopus_frequency < q[i,2]][dc_state=='t'][,.N]
}
setDT(q)
q$perc <- as.character(q$perc)
q[perc==10,perc:='0-10']
q[perc==20,perc:='10-20']
q[perc==30,perc:='20-30']
q[perc==40,perc:='30-40']
q[perc==50,perc:='40-50']
q[perc==60,perc:='50-60']
q[perc==70,perc:='60-70']
q[perc==80,perc:='70-80']
q[perc==90,perc:='80-90']
q[perc==100,perc:='90-100']
 
q[,proportion:=round(100*connected/total,1)]

pdf('percent_connected.pdf')
qplot(as.factor(perc),proportion,data=q,xlab="co-citation frequency percentile group",ylab="percent connected",ylim=c(0,50),geom=c("point","line"),group=1) + 
theme_bw() + theme(text=element_text(family="Arial", size=20))
dev.off()
system('cp percent_connected.pdf ~/cocitation_2/')
