setwd('~/Desktop/cc2/')
rm(list=ls()); library(data.table); library(ggplot2); library(grid)
library(extrafont)
x <- fread('timelag3.csv')
x[,lag:=first_co_cited_year-first_possible_year]
x <- x[lag >= 0]
x[, .SD[which.max(sb)]]
x[, .SD[which.max(lag)]]
x[, .SD[which.max(scopus_frequency)]]

a <- unname(quantile(x$scopus_frequency,0.99))
b <- unname(quantile(x$scopus_frequency,0.98))
c <- unname(quantile(x$scopus_frequency,0.97))
d <- unname(quantile(x$scopus_frequency,0.96))
e <- unname(quantile(x$scopus_frequency,0.95))

x[scopus_frequency >=a, perc:='99th']
x[scopus_frequency >= b & scopus_frequency < a, perc:='98th']
x[scopus_frequency >= c & scopus_frequency < b, perc:='97th']
x[scopus_frequency >= d & scopus_frequency < c, perc:='96th']
x[scopus_frequency >= e & scopus_frequency < d, perc:='95th']

y <- x[scopus_frequency >= e]
colnames(y)[8] <- "connected"

y[connected=='f',connected:='false'];y[connected=='t',connected:='true']
colnames(y)[8] <- "connected"
y$perc <- factor(y$perc,levels=c('99th','98th','97th','96th','95th'))
p1 <- qplot(perc,scopus_frequency,geom="boxplot",data=y,facets=connected~.,
color=perc,xlab="percentile group") + theme(text=element_text(family="Arial", size=12))
p2 <- qplot(perc,log(scopus_frequency),geom="boxplot",data=y,facets=connected~.,
color=perc) + theme(text=element_text(family="Arial", size=18)) + theme(legend.position = "none") 
p2 <- p2 + theme(axis.title.x = element_blank())
vp <- viewport(width = 0.5, height = 0.4, x = 0.55, y = 0.30)

pdf('kinetics.pdf')
print(p1)
print(p2,vp=vp)
dev.off()
system('cp kinetics.pdf ~/cocitation_2/')

pdf('lag.pdf')
qplot(lag,scopus_frequency,data=y,facets=connected~perc,color=connected,xlab="time to first co-citation (yrs)") + 
scale_y_continuous(trans='log2') + theme_bw() + 
theme(text=element_text(family="Arial", size=18)) + theme(axis.text.x=element_text(angle = -75, hjust = 0)) +
theme(legend.text=element_text(size=18))
dev.off()
system('cp lag.pdf ~/cocitation_2/R1/R1lag2.pdf')
