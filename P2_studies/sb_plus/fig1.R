# Plot ECDF for 940 million co-cited pairs
# George Chacko 6/20/2020
# Data were generated on by merging the files
# sbp_1985.csv, sb_plus_batch_chop_1.csv, sb_plus_batch_chop_2.csv
# sb_plus_batch_chop_3.csv, sb_plus_batch_chop_4.csv, sb_plus_batch_chop_5.csv
# sb_plus_batch_chop_6.csv, sb_plus_batch_chop_7.csv, sb_plus_batch_chop_8.csv
# sb_plus_batch_chop_8.csv to create all940.csv
# Look in /erniedev_data3/sb_plus
# The merging stragey was to read the files into a list and
# use rbindlist to create a single data.table

setwd('~/Desktop/sb_plus')
rm(list=ls())
library(data.table); library(ggplot2)

# Import data
x <- fread('all940.csv')
p <- ggplot(x,aes(scopus_frequency)) +
stat_ecdf(geom="step") +
labs(y="F(Co-citation Frequency)",x="Co-citation Frequency") +
scale_x_continuous(trans='log2') +
theme_bw() +
theme(text=element_text(family="Arial",size=20))

# takes a long time
pdf('fig1.pdf')
print(p)
dev.off() 

