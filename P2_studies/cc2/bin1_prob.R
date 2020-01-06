setwd('~/Desktop/cc2')
rm(list=ls())
library(data.table)
# prob data: using Jan  6 10:22 download includes 943 rows of corrected data
x <- fread('ten_year_cocit_union_freq11_freqsum_bin1_probability_results.csv')
# frequency data
y <- fread('ten_year_cocit_union_freq11_freqsum_bin1_time_lag.csv')
# remove unnecessary columns; jc1 and jc2 are Jaccard 1 and 2 calculated from N(x|y) and N*(x|y) respectively
x1 <- x[,.(cited_1,cited_2,exy,jc1=union_xy,jc2=union_xy2)]
# fsum is intra-dataset co-citation counts (1985-1995), scopus_frequency is across Scopus to Dec 2019
y1 <- y[,.(cited_1,cited_2,fsum,scopus_frequency)]
x1y1 <- merge(x1,y1,by.x=c('cited_1','cited_2'),by.y=c('cited_1','cited_2'))
# clean up 
rm(list=setdiff(ls(), "x1y1"))
