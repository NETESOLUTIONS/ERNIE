# simple script to calculate article scores per Williams (2015)
# The file name needs to be replaced of course and should 
# have the four columns of an edgelist. source, stype, target, ttype

rm(list = ls())
library(data.table)
# read in data casting scp as character
x <- fread("kavli_mdressel_combined_4col.csv", colClasses = rep("character", 4))
# Count edges to target
y <- x[, .(.N), by = "target"]
# Merge back to x using target-> target
z1 <- merge(x, y, by.x = "target", by.y = "target")
# Merge back to x using source -> target
z2 <- merge(z1, y, by.x = "source", by.y = "target", all.x = TRUE)
# Replace NA with 0
z2[is.na(z2$N.y), 6] <- 0
colnames(z2) <- c("source", "target", "stype", "ttype", "n_target", "n_source")
# Calculate article scores
z3 <- z2[, .(sum(n_source) + sum(n_target)/length(stype)), by = "target"][order(-V1)]
# user friendly names, e.g. 'before_breakfast_for_type_grand_master_samet_keserci'
colnames(z3) <- c("scp", "article_score")

# read in auth_list
a <- fread('kavli_mdressel_auth_list.csv',colClasses=rep('character',2))
# merge with z3
b <- merge(z3,a,by.x='scp',by.y='pub')
# article scores
c <- b[,.(art_score=sum(article_score)),by='auid'][order(-art_score)]

