# a simple script to count the number of nulls in simulated data
# relative to observed frequency. It's memory hungry gc 12/4/2018

library(data.table)
# read in csv
f1 <- fread('file_name.csv')
# rename columns to handle duplicate names etc
colnames(f1) <- c('reference_pairs',c(1:ncol(f1)-1))
vec <- colnames(f1)
# use rowSums in data.table to sum across rows
f1[,sum := rowSums(.SD),.SDcols=vec[-1]]
# get rid of unwanted columns
f1[,list(reference_pairs,sum)]
# count null values in sum column
dim(f1[!complete.cases(f1)])
