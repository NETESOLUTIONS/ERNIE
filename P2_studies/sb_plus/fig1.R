# Plot ECDF for 940 million co-cited pairs
# George Chacko 6/20/2020
setwd('~/Desktop/sb_plus')
rm(list=ls())
library(data.table; library(ggplot2)

# Import data
x <- fread('all940.csv')
p <- ggplot(x,aes(scopus_frequency)) +
stat_ecdf(geom="step") +
labs(y="F(Co-citation Frequency",x="Co-citation Frequency") +
scale_x_continuous(trans='log2') +
theme_bw() +
theme(text=element_text(family="Arial",size=20))

# takes a long time
pdf('fig1.pdf')
print(p)
dev.off() 

