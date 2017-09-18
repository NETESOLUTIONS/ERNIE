nct_pubmed_search <- function (x)
# takes a character vector of NCT Ids as input and returns a
# list of vectors each containing pmids associated with that nct_id
{
nct_list <- vector("list",length(x))
library(rentrez)
for (i in 1:length(x)){
t<- entrez_search(db="pubmed", term=x[i],retmax=20)
nct_list[[i]] <- t$ids
}
names(nct_list) <- x 
return(nct_list)
}