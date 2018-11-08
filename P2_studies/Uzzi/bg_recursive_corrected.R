library(data.table); library(dplyr)
rm(list=ls())
sorted <- fread("~/Desktop/gc_mc_1980_1990_sorted.csv")
refindex <- sorted %>% select(cited_source_uid,reference_issn,reference_year)
refindex <- data.table(refindex)
refindex <- unique(refindex,by=c("cited_source_uid","reference_issn","reference_year"))

for (i in 1:10) {
S1 <- sorted %>% 
select(source_id,source_year,o_cited_source_uid=cited_source_uid,o_refyear=reference_year,o_ref_issn=reference_issn) %>% 
group_by(o_refyear) %>% 
mutate(s_cited_source_uid=sample(o_cited_source_uid,replace=TRUE))

s_delta <- S1 %>% group_by(source_id) %>% summarize(check=sum(duplicated(s_cited_source_uid))) %>% filter(check > 0) %>% select(source_id) 

S1 <- S1 %>% group_by(source_id,s_cited_source_uid) %>% filter(n()==1)

S2 <- S1 %>% 
inner_join(refindex,by=c("s_cited_source_uid"="cited_source_uid"))
colnames(S2) <- c("source_id","source_year","o_cited_source_uid","o_refyear","o_ref_issn","s_cited_source_uid","s_reference_issn","s_reference_year")
fwrite(S2,file=paste("~/Desktop/bg_n",i,".csv",sep=""),row.names=FALSE)
}