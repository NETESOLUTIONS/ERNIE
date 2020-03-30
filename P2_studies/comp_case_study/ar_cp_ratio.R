# Script for Fig 1 of Salton and Bergmark paper

rm(list = ls())
library(reshape2); library(data.table)
setwd("~/Desktop/dblp/")
x <- fread("ar_vs_cp2.csv")
x <- x[, .(cp, cp_count, ar_count)]
colnames(x) <- c("msa", "conf", "article")
mx <- melt(x, id = "msa")
library("ggplot2")
theme_update(text = element_text(size = 12))
pdf("ar_cp_ratio.pdf")
qplot(value/1e+06, reorder(msa, value), color = variable, data = mx, xlab = "Count of Publications (millions)", ylab = "ASJC Major Subject Area")
dev.off()
system("cp ar_cp_ratio.pdf ~/ernie_comp/Scientometrics")
# tiff
tiff("ar_cp_ratio.tif", res=600, compression = "lzw", height=8, width=7, units="in")
qplot(value/1e+06, reorder(msa, value), color = variable, data = mx, 
xlab = "Count of Publications (millions)", ylab = "ASJC Major Subject Area")
dev.off()
