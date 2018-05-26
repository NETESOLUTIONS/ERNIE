# May 24, 2018
# George Chacko
# Prep csv file for Solr searching as TN population
# Data provided by Avon Davey from wos:pmid pairs for which there is no wos_data in ERNIE
# The problem here is to use these pmids to construct a query set for Solr of the form "Authors,Title,Publication_Year,
# Journal,Volume" to use for the True Negative (TN) population in a citation matching exercise. We use the NCBI e-utils 
# API along with rentrez to do this.

# Stage-I: submit requests to e-utils in chunks of 350 pmids (this works from experience)

library(rentrez)
library(purrr)
library(dplyr)
library(tidyr)

# Read in data
wos_neg <- read.csv("~/Desktop/missing_wos_id_sample.csv", stringsAsFactors = FALSE)

# chunker function to chop up source data (is also stored in NETELabs_Case Studies Repo in Github

chunker <- function(x,y) {
    no_of_chunks <- ceiling(length(x)/y)	
    print(no_of_chunks)

# data checks for x & y
if (is.vector(x)!=TRUE) {break}
if (all(x == as.integer(x))!=TRUE) {break}
if (all(y == as.integer(y))!=TRUE) {break}
my_chunks <- list()
a <- 0
    for(i in 1:no_of_chunks) {
        if(i < no_of_chunks) {
		my_chunks[[i]] <- x[(a+1):(a+y)]
			} else {
			my_chunks[[i]] <- x[(a+1):length(x)]}
			a=a+y}
names(my_chunks) <- paste("my_chunks", 1:no_of_chunks, sep = "")
return(my_chunks)}

# parameters for chunker for this case
x= wos_neg$pmid #input file
y= 350 # chunk size

# execute chunker on wos_neg data in 350 row units to create a list named pmid_chunks

pmid_chunks <- chunker(x, y)
namevec <- names(pmid_chunks)

# submit to NCBI - data is returned as a list of lists since we're doing batches
esummary <- list()
for (i in 1:length(e1) {
	esummary[[i]] <- entrez_summary(db = "pubmed", id = pmid_chunks[[i]])
	Sys.sleep(60)

rm(x); rm(y); rm(i); rm(chunker); rm(pmid_chunks); rm(namevec)

# Stage II Assemble a dataframe of necessary fields from the data returned by e-utils through rentrez (esummary)
# This is a nested list. Further, for cases where no associated data is found for a pmid, rentrez modified the list
# structure to a length of 2 instead of the usual 43. This seriously messes with extracting data from pmid_chunks
# You know when this happens because the script returns Warnings, which can be read by typing warnings()

# Remove the list elements associated with pmids that have no data. First make a working copy and flatten it to get rid of the chunks
# flatten to clean
flat_es <- flatten(esummary)
flat_es_clean <- flat_es[lengths(flat_es)== 43]

# rechunk to be able to use previously written code
es_clean_rechunked <- list()
es_clean_rechunked[[1]] <- flat_es_clean[1:2200]
es_clean_rechunked[[2]] <- flat_es_clean[2201:length(flat_es_clean)]

# Process authors since they're a data frame element within each chunk
# Start extracting data from esummary

solr_neg_authors <- list()
for (i in 1:length(es_clean_rechunked)) {
	t1 <- map(es_clean_rechunked[[i]], "authors")
	solr_neg_authors[[i]] <- t1
}

solr_neg_authors <- flatten(solr_neg_authors)

library(dplyr)
d <- data.frame()
for (i in 1:length(solr_neg_authors)) {
	a <- rep(names(solr_neg_authors[i]),length(solr_neg_authors[[i]][[1]]))
	b <- solr_neg_authors[[i]][[1]]
	c <- data.frame(cbind(a, b), stringsAsFactors = FALSE)
	d <- rbind(d, c)
	d <- unique(d)
}

d <- d %>% group_by(a) %>% summarise(authors = paste(b, 
	collapse = ", "))
colnames(d) <- c("uid", "authors")

# process other fields
f1 <- list()
for (i in 1:length(es_clean_rechunked)) {
	f1[[i]] <- map_df(es_clean_rechunked[[i]], `[`, 
		c("uid", "title", "pubdate", 
			"fulljournalname", "volume"))
}
g <- do.call(rbind, f1)

# merge authors with other fields

h <- merge(d, g)
h$pubdate <- substr(h$pubdate, 1, 4)
solr_neg <- h
rm(a); rm(b);rm(c);rm(d);rm(es_clean_rechunked);rm(flat_es);rm(flat_es_clean)
rm(g1);rm(h)


 