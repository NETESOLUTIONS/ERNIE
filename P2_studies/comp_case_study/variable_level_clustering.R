rm(list=ls())

# read in csv file
# setwd('~/Desktop/dblp')
x <- fread('dblp_high_cited_pubs_frequency_integers.csv')
# order by co-citation_frequency descending
x <- x[order(-co_citation_frequency)]
print(paste("Initial data rows =",nrow(x)))

# limit input table to normalized_co_citation_frequency at xth percentile or greater
# You can set this to any value between 0 and 1

#j <- 0.1
#x <- x[co_citation_frequency >= quantile(x$co_citation_frequency,j)]
# print(paste("Threshold quantile level =",j))
# initialize table of clusters
i=1. # i is cluster number
# select all rows where either member of any co-cited pair contains at least one member 
# of the first row of data in x1
y <- x[cited_1 %in% unname(as.vector(x[1,1])) | cited_1 %in% unname(as.vector(x[1,2])) |
cited_2 %in% unname(as.vector(x[1,1])) | cited_2 %in% unname(as.vector(x[1,2]))][,cluster:=i]

# display size of this first cluster based on co-citations
print(paste('Cluster #',i,'co-cited pairs =', nrow(y),sep=" "))

# remove y from x
x <- x[!sortkey %in% y$sortkey]

# reorder
x <- x[order(-co_citation_frequency)]


# begin loop for i=2 to 100 

for (i in 2:nrow(x)){
		z <-x[cited_1 %in% unname(as.vector(x[1,1])) | cited_1 %in% unname(as.vector(x[1,2])) |
		cited_2 %in% unname(as.vector(x[1,1])) | cited_2 %in% unname(as.vector(x[1,2]))][,cluster:=i]
		y <- rbind(y,z)
		x <- x[!sortkey %in% z$sortkey]
		x <- x[order(-normalized_co_citation_frequency)]
print(paste('Cluster #',i,'co-cited pairs =', nrow(z),sep=" "))
print(paste("Remaining data rows =",nrow(x)))
print(i)
if (nrow(x)==0){
break}
}
yy <- y[,length(sortkey),by='cluster']
fwrite(y,file='level_1_clustering.csv')
