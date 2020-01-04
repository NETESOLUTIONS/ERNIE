setwd("~/Desktop/cc2")
rm(list = ls())
library(data.table)
library(ggplot2)
library(patchwork)
# using data downloaded on 1/4/2019
# ten year bin 1 data
x <- fread("ten_year_cocit_union_freq11_freqsum_bin1_time_lag.csv")
a <- dim(x)
# check if flawed citing year data exists
x <- x[first_cited_year >= cited_1_year][first_cited_year >= cited_2_year]
x[, `:=`(refdiff, abs(cited_1_year - cited_2_year))]
x[, `:=`(maxdiff, first_cited_year - max(cited_1_year, cited_2_year)), by = c("cited_1", "cited_2")]
x[, `:=`(mindiff, first_cited_year - min(cited_1_year, cited_2_year)), by = c("cited_1", "cited_2")]
b <- dim(x)
# test for equal numbers of rows
identical(a[1], b[1])

faultyrows <- fread("ten_year_cocit_union_freq11_freqsum_bin1_fault_data.csv")
print(paste0("aberrant first_citation year percentage="," ",100*dim(faultyrows)[1]/dim(x)[1]))

pdf("time_lag1.pdf")
p1 <- ggplot(x, aes(refdiff, scopus_frequency)) + geom_point(aes(colour = cut(scopus_frequency, c(-Inf, 10000, 20000, Inf))), 
	size = 2) + xlim(0, 80) + theme(legend.position = "none")

p2 <- ggplot(x, aes(mindiff, scopus_frequency)) + geom_point(aes(colour = cut(scopus_frequency, c(-Inf, 10000, 20000, Inf))), 
	size = 2) + xlim(0, 80) + theme(legend.position = "none")

p3 <- ggplot(x, aes(maxdiff, scopus_frequency)) + geom_point(aes(colour = cut(scopus_frequency, c(-Inf, 10000, 20000, Inf))), 
	size = 2) + xlim(0, 80) + theme(legend.position = "none")

pdf("time_lag1.pdf")
print(p1/p2/p3)
dev.off()
system("cp time_lag1.pdf ~/cocitation_2/time_lag1.pdf")
