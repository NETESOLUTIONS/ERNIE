library(rentrez); library(data.table);library(purrr)
x <- entrez_search(db="pubmed", term="COVID",retmax=2000)

# chunking
a <- entrez_summary(db="pubmed", id=x$ids[1:300],retmax=300)
b <- entrez_summary(db="pubmed", id=x$ids[301:600],retmax=300)
c <- entrez_summary(db="pubmed", id=x$ids[601:900],retmax=300)
d <- entrez_summary(db="pubmed", id=x$ids[901:length(x$ids)],retmax=300)

a_df<- map_dfr(a,"articleids")
b_df<- map_dfr(b,"articleids")
c_df<- map_dfr(c,"articleids")
d_df<- map_dfr(d,"articleids")
abcd <- rbind(a_df,b_df,c_df,d_df)
setDT(abcd)
fwrite(data.frame(abcd[idtype=='doi',value]),file='~/wenxi2.csv')