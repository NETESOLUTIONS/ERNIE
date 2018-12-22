# Initial implementation of the Warnow model
# Input is an annual dataslice and frequency table/probs for references within
# Output is a dataframe/csv with refpairs and a table of k values.
# George Chacko 12/17/2018

# Clear workspace
rm(list = ls())
# setwd("~/")
library(data.table)
library(dplyr)

# read data
df <- fread("dataset1980_dec2018.csv")
# read frequency files
freqs <- fread("dataset1980_freqs.csv")

# select pubs with at least two references 
print(dim(df))
df[,refcount:=.N,by='source_id']
df <- df[refcount>1]
print(dim(df))

# get rid of unnecessary columns
df <- df[,c('source_id','cited_source_uid','reference_year')]
df <- df[order(source_id,cited_source_uid)]

# calculate k-values
kvals <- data.table::copy(df)
kvals <- kvals[,k:=.N,by=c('source_id','reference_year')]
kvals <- kvals[,cited_source_uid:=NULL]
kvals <- unique(kvals)
kvals <-kvals[order(source_id,reference_year)]
write.csv(kvals,file='kvals.csv',row.names=FALSE)

# break data up into chunks of source_id:cited_source_uid and insert into list
datalist <- list()
source_id_vec <- as.vector(unique(df$source_id)) #unique should not be necessary
for (i in 1:length(source_id_vec)) { 
	datalist[[i]] <- df[source_id == source_id_vec[i]]
		if(i%%5000 == 0) {
		print(paste('completed',i))
	}
}
names(datalist) <- source_id_vec

# collapse list and write as csv
dftable <- rbindlist(datalist)
write.csv(dftable,file='dftable.csv',row.names=FALSE)

# remove d1980 to save memory- it should help in theory at least
rm(df)

# use lapply to generate a list of dataframes of reference pairs 
refpair_list <- lapply(datalist,function(x) data.frame(t(combn(x$cited_source_uid,2)),stringsAsFactors=FALSE))

# collapse list and reduce to unique reference pairs
refpairs_table <- rbindlist(refpair_list)
refpairs_table <- data.table(refpairs_table)
refpairs_table <- unique(refpairs_table)

# sort reference pairs
library(parallel)
cl <- makeCluster(4)
rp  <- t(parApply(cl,refpairs_table,1,sort)))
refpairs_table <- data.table(rp)
colnames(refpairs_table) <- c('X1','X2')

# merge f,F, and P

x1 <- merge(refpairs_table,freqs,by.x='X1',by.y='cited_source_uid')
colnames(x1) <- c("X1", "X2", "X1_refyear", "X1_f", "X1_F", "X1_p")
x2 <- merge(refpairs_table,freqs,by.x='X2', by.y='cited_source_uid')
colnames(x2) <- c("X2", "X1", "X2_refyear", "X2_f", "X2_F", "X2_p")
pairs <- merge(x1, x2, by = c("X1", "X2"))
dim(pairs)
print(head(pairs))
fwrite(pairs,file = 'pairs.csv')

