The ugly way to extract an element from a nested list with uneven numbers of rows and prep it for Solr querying

# May 24, 2018
# George Chacko
# Prep csv file for Solr searching as TN population
# Data provided by Avon Davey from wos:pmid pairs for which there is no wos_data in ERNIE

library(rentrez)
library(purrr)
library(dplyr)
library(tidyr)

# Read in data
wos_neg <- read.csv("~/Desktop/missing_wos_id_sample.csv", stringsAsFactors = FALSE)

# chunker function to chop up source data
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
x= wos_neg$pmid
y= 350

# execute chunker on wos_neg data in 350 row units
pmid_chunks <- chunker(x, y)
namevec <- names(pmid_chunks)

# submit to NCBI - data is returned as a list of lists since we're doing batches
esummary <- list()
for (i in 1:length(e1) {
	esummary[[i]] <- entrez_summary(db = "pubmed", id = pmid_chunks[[i]])
	Sys.sleep(60)
}
rm(x); rm(y); rm(i); rm(chunker); rm(pmid_chunks); rm(namevec)