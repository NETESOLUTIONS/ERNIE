# script to replace duplicated intra-publication references
# for MCMC background networks per Uzzi (2013) using resampling
# The file path is presently set to work on ernie2

# load dataset- in this case 1981-1990 pubs and references 
setwd("/erniedev_data1/P2_studies/Uzzi_data"
library(data.table); library(dplyr)
rm(list=ls())
#sorted <- fread("~/Desktop/gc_mc_1980_1990_sorted.csv")
sorted <- fread("gc_mc_1980_1990_sorted.csv")
# clean posssibly faulty references out
sorted <- sorted %>% filter(source_year >= reference_year)
# build file for merging back data later
refindex <- sorted %>% select(cited_source_uid,reference_issn,reference_year)
refindex <- data.table(refindex)
refindex <- unique(refindex,by=c("cited_source_uid","reference_issn","reference_year"))

# loop 10 times to build 10 background files

for (i in 1:10) {
S1 <- sorted %>% 
select(source_id,source_year,o_cited_source_uid=cited_source_uid,o_refyear=reference_year,o_ref_issn=reference_issn) %>% 
group_by(o_refyear) %>% 
mutate(s_cited_source_uid=sample(o_cited_source_uid,replace=TRUE))

s_delta <- S1 %>% group_by(source_id) %>% summarize(check=sum(duplicated(s_cited_source_uid))) %>% filter(check > 0) %>% select(source_id) 

S2 <- S1[S1$source_id %in% s_delta$source_id,] %>% arrange(o_refyear,source_id)
S2_refyear <- unique(S2$o_refyear)
S4 <- S2[1,]
	for (j in 1:length(S2_refyear)) {
	print(S2_refyear[j])
	temp <- S2[S2$o_refyear==S2_refyear[j],]
	sub <- temp$s_cited_source_uid
	repl <- sample(sorted[sorted$reference_year==S2_refyear[j],5],length(sub))
	temp$s_cited_source_uid2 <- repl
	S4 <- rbind(S4,temp)
	}
S4[-1,] # remove filler row
S4 <- S4[,-6] # remove 
colnames(S4) <- c("source_id","source_year","o_cited_source_uid","o_refyear","o_ref_issn","s_cited_source_uid")

# swap out rows with duplicates for rows with resampled citation_uids
S1_swap <- S1[!S1$source_id %in% s_delta$source_id,]
S1_swapped <- rbind(S1_swap,S4)

S5 <- S1_swapped %>% 
inner_join(refindex,by=c("s_cited_source_uid"="cited_source_uid"))
colnames(S5) <- c("source_id","source_year","o_cited_source_uid","o_refyear","o_ref_issn","s_cited_source_uid",
"s_reference_issn","s_reference_year")
fwrite(S5,file=paste("bg_n_resampled",i,".csv",sep=""),row.names=FALSE)
}

