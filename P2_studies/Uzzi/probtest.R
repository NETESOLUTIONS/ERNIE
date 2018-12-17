# Initial implementation of the Warnow model
# Input is an annual dataslice and frequency table/probs for references within
# Output is two dataframes wwith refpairs in same year and different years
# Still need to implement calculations for same year and different years

# Clear workspace
rm(list = ls())
setwd("~/")
library(data.table)
library(dplyr)

# read data
d1980 <- fread("dataset1980_dec2018.csv")
# read frequency files
freqs <- fread("dataset1980_freqs.csv")

# select pubs with at least two references 
print(dim(d1980))
d1980[,refcount:=.N,by='source_id']
d1980 <- d1980[refcount>1]
print(dim(d1980))

# break data up into chunks of source_id:cited_source_uid and insert into list
datalist <- list()
source_id_vec <- as.vector(unique(d1980$source_id)) #unique should not be necessary
for (i in 1:length(source_id_vec)) { 
	datalist[[i]] <- d1980[source_id == source_id_vec[i]]
	if(i%%1000 == 0) {
		print(i)}
}

rm(d1980)

# looping through datalist create new list of reference pairs for each pub
refpair_list <- list()
for (i in 1:length(datalist)) {
	x <- datalist[[i]]
	# print(length(x$cited_source_uid))
	y <- data.frame(t(combn(x$cited_source_uid, 2)),stringsAsFactors=FALSE)
	refpair_list[[i]] <- y
	names(refpair_list)[i] <- x[1,1]
}

# looping through datalist count k values for reference_years for each pub
ref_k_list <- list()
for (i in 1:length(datalist)) {
	x <- datalist[[i]]
	x <- data.table(x)
	y <- x[,.N,by=c('source_id','reference_year')]
	ref_k_list[[i]] <- y
	names(ref_k_list)[i] <- x[1,1]
}
# collapse list and reduce to unique reference pairs
refpairs_table <- rbindlist(refpair_list)
refpairs_table <- data.table(refpairs_table)
refpairs_table <- unique(refpairs_table)

# merge f,F, and P

x1 <- merge(refpairs_table,freqs,by.x='X1',by.y='cited_source_uid')
colnames(x1) <- c("X1", "X2", "X1_refyear", "X1_f", "X1_F", "X1_p")
x2 <- merge(refpairs_table,freqs,by.x='X2', by.y='cited_source_uid')
colnames(x2) <- c("X2", "X1", "X2_refyear", "X2_f", "X2_F", "X2_p")
pairs <- merge(x1, x2, by = c("X1", "X2"))
pairs <- data.table(pairs)
pairs_same <- pairs[X1_refyear == X2_refyear]
pairs_different <- pairs[!X1_refyear == X2_refyear]

# calculate number of draws for each reference in a publication 
# for example if a pub has three references from 1975 then k=3 for 1975 refs.













#chunker takes two parameters. 
# A vector x and chunk_size y
# Does not handle data frames

chunker <- function(x, y) {
	no_of_chunks <- ceiling(length(x)/y)
	print(no_of_chunks)
	my_chunks <- list()
	a <- 0

	for (i in 1:no_of_chunks) {
		if (i < no_of_chunks) {
			my_chunks[[i]] <- x[(a + 1):(a + y)]
		} else {
			my_chunks[[i]] <- x[(a + 1):length(x)]
		}
		a = a + y
	}
	return(my_chunks)
}

####

chunk <- 1000
n <- nrow(my_data_frame)
r <- rep(1:ceiling(n/chunk), each = chunk)[1:n]
d <- split(my_data_frame, r)



d1980_1 <- d1980 %>% select(source_id, cited_source_uid, reference_year) %>% unique()
d1980_2 <- merge(d1980_1, freqs, by.x = "cited_source_uid", by.y = "cited_source_uid") %>% select(source_id, cited_source_uid, 
	reference_year = reference_year.x, f, F, p)
x <- d1980_2 %>% group_by(source_id) %>% summarize(refcounts = length(cited_source_uid)) %>% filter(refcounts == 30)
x <- x[1:3, 1]
vec <- as.vector(x$source_id)
for (i in 1:length(vec)) {
	x <- d1980_2[d1980_2$source_id == vec[i], ]
	assign(paste0("test_", i), get("x"))
}
rm(x)
rm(i)
rm(vec)

d1980_3 <- d1980_2 %>% select(cited_source_uid, reference_year, f, F, p) %>% unique()
pairs <- data.frame(t(combn(sort(test_1$cited_source_uid), 2)), stringsAsFactors = FALSE)
pairs1 <- merge(pairs, d1980_3, by.x = "X1", by.y = "cited_source_uid")
colnames(pairs1) <- c("X1", "X2", "X1_refyear", "X1_f", "X1_F", "X1_p")

pairs2 <- merge(pairs, d1980_3, by.x = "X2", by.y = "cited_source_uid")
colnames(pairs2) <- c("X2", "X1", "X2_refyear", "X2_f", "X2_F", "X2_p")

merge(pairs1, pairs2, by = c("X1", "X2"))
pairs <- merge(pairs1, pairs2, by = c("X1", "X2"))
rm(pairs1)
rm(pairs2)

pairs <- data.table(pairs)
pairs_same <- pairs[X1_refyear == X2_refyear]
pairs_different <- pairs[!X1_refyear == X2_refyear]

test_1 <- data.table(test_1)
test_1[, `:=`(k, .N), by = reference_year]
kcount <- unique(test_1[, c("reference_year", "k")])

temp <- merge(pairs_different, kcount, by.x = "X1_refyear", by.y = "reference_year")
colnames(temp)[11] <- "k1"

temp <- merge(temp, kcount, by.x = "X2_refyear", by.y = "reference_year")
colnames(temp)[12] <- "k2"





