# extension of simple script to calculate article scores per Williams (2015)
# The file name needs to be replaced of course and the input file should 
# have the four columns of an edgelist. source, stype, target, ttype.
# This script extends Pico's article score by considering additonal degrees of neighbors

rm(list = ls())
library(data.table)
# read in data casting scp as character
x0 <- fread("kavli_mdressel_combined_4col.csv", colClasses = rep("character", 4))
# Count edges to target
y0 <- x0[, .(.N), by = "target"][order(-N)]
z0 <- merge(x0,y0,by.x='source',by.y='target',all.x=TRUE)
z0[is.na(z0)] <- 0
article_scores <- z0[,.(sum(N)+.N),by='target'][order(-V1)]

# additional degrees to be addded