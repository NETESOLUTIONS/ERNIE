# Simple script to subtract one year's (1985) data from the 11 year dataset (1985-1995)
# George Chacko 6/9/2020
# run from directory of choice (I used /neo4j_data1/sb_plus)
# Ideally, the data.table merge syntax would allow merging by two columns and negation
# and this is likely possible but I don't know how.

library(data.table); library(bit64)
ll <- list()
# read 10 files (1986-1995) into a list (the pattern pulls into two extra files hence i+2)
for (i in 1:10){
  ll[[i]] <- fread(list.files(pattern='neo4j_results_19*')[i+2])
}
# assign file names as list element names
names(ll) <- list.files(pattern='neo4j_results_19*')[3:12]
# collapse list into a data.table and apply unique
dt <- unique(rbindlist(ll))
keyCols=c('cited_1','cited_2')
setkeyv(dt,keyCols)
# read in 1985 data
x85 <- fread(list.files(pattern='neo4j_results_19*')[2])
setkeyv(x85,keyCols)
# find common rows with 1985 data
mdf <- merge(x85,dt,by.x=keyCols,by.y=keyCols)
# merge common rows with data.table
dt2 <- rbind(mdf,dt)
setkeyv(dt2,keyCols)
# remove duplicates
dt3 <- dt2[,.N,by=keyCols][N==1]
fwrite(dt3,file='sbp_1986_1995_minus1985.csv')
