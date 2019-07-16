# extension of simple script to calculate article scores per Williams (2015)
# The file name needs to be replaced of course and the input file should 
# have the four columns of an edgelist. source, stype, target, ttype.
# This script extends Pico's article score by considering additonal degrees of neighbors

rm(list = ls())
library(data.table)
# read in data casting scp as character
x0 <- fread("kavli_mdressel_combined_4col.csv", colClasses = rep("character", 4))
# Count edges to target

x1  <- x0[source %in% target]
x2  <- x1[source %in% target]
x3  <- x2[source %in% target]
x4  <- x3[source %in% target]

y0 <- x0[, .(.N), by = "target"]
y1 <- x1[, .(.N), by = "target"]
y2 <- x2[, .(.N), by = "target"]
y3 <- x3[, .(.N), by = "target"]
y4 <- x4[, .(.N), by = "target"]

z01 <- merge(y0,y1,by.x='target',by.y='target',all.x=TRUE)
z012 <- merge(z01,y2,by.x='target',by.y='target',all.x=TRUE)
colnames(z012) <- c('target','n0','n1','n2')
z0123 <- merge(z012,y3,by.x='target',by.y='target',all.x=TRUE)
colnames(z0123) <- c('target','n0','n1','n2','n3')
z01234 <- merge(z0123,y4,by.x='target',by.y='target',all.x=TRUE)
colnames(z01234) <- c('target','n0','n1','n2','n3','n4')
z01234[is.na(z01234)] <-0
rm(list=setdiff(ls(), c("z01234")))
z <- z01234[,.(base_count=n0,art_score=(n0+n1),
art_score_plus_one=(n0+n1+n2),
art_score_plus_two=(n0+n1+n2+n3),
art_score_plus_three=(n0+n1+n2+n3+n4))][order(-base_count)]; rm(z01234)


