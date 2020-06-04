# George Chacko
# data.table approach to calculate Pico's Article Score
# William et al. (2015) Cell
rm(list=ls())
library(data.table)
# read in data casting scp as character
x <- fread('xx.csv',colClasses=rep('character',4))
# Count edges to target
y <- x[,.(.N),by='target']
# Merge back to x using target-> target
z1 <- merge(x,y,by.x='target',by.y='target')
# Merge back to x using source -> target. Use outer join this time.
z2 <- merge(z1,y,by.x='source',by.y='target',all.x=TRUE)
# Replace NA with 0
z2[is.na(z2$N.y),6] <- 0
colnames(z2) <- c('source','target','stype','ttype','n_target','n_source')
# Calculate article scores
z3 <- z2[,.(sum(n_source)+sum(n_target)/length(stype)),by='target'][order(-V1)]
# divide bt length(stype) to avoid duplicate counting at level 1
# user friendly names, e.g. 'before_breakfast_for_type_grand_master_samet_keserci'
colnames(z3) <- c('scp','article_score')