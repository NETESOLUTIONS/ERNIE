# script for permuting references in Uzzi-type analysis

# Don't forget to set working directory to where your
# input data is located.
setwd('name of working directory')

library(data.table); library(dplyr)
rm(list=ls())
# import source file (one year's worth of data- filename is hard coded as data1980.csv in this script)
sorted <- fread('data1980.csv')

# construct table for backjoining later

refindex <- sorted %>% select(cited_source_uid,reference_issn,reference_year)
refindex <- data.table(refindex)
refindex <- unique(refindex,by=c('cited_source_uid','reference_issn','reference_year'))

# loop to create background models
for (i in 1:100) {

print(paste('Starting loop number',i,sep=''))
S1 <- sorted %>% 
select(source_id,source_year,o_cited_source_uid=cited_source_uid,o_refyear=reference_year,o_ref_issn=reference_issn) 
S1 <- S1[ , s_cited_source_uid := sample(o_cited_source_uid),by=o_refyear]
print(dim(S1))

# identify cases of duplication
s_delta <- S1 %>% group_by(source_id) %>% summarize(check=sum(duplicated(s_cited_source_uid))) %>% filter(check > 0) %>% select(source_id) 
print(dim(s_delta))

# subtract pubs with duplications in them
S2 <- S1[!S1$source_id %in% s_delta$source_id,]
print(dim(S2))

# only used during testing. Consistently returns zero so commented out
# check to see if dupes are removed (should return zero rows)
# S3 <- S2 %>% group_by(source_id,s_cited_source_uid) %>% filter(n()>1)
# print(dim(S3))

# back join to fill in data from refindex, rename, and export
S4 <- S2 %>% inner_join(refindex,by=c('s_cited_source_uid'='cited_source_uid'))
colnames(S4) <- c('source_id','source_year','o_cited_source_uid','o_refyear','o_ref_issn','s_cited_source_uid','s_reference_issn','s_reference_year')
print(dim(S4))
# single quotes seem to work better in CentOS although this could be because of passaging through TextEdit.
fwrite(S4,file=paste('bg_n_shuffled',i,'.csv',sep=''),row.names=FALSE)
print(paste('Ended loop number',i,sep=''))

}
