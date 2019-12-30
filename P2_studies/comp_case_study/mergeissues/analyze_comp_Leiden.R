# analyze initial clustering parameters of Leiden clustering of 20 years of comp data
rm(list=ls())
library(data.table)
setwd('~/Desktop/clustering/')
# V1= node_id, V2= cluster_id
one <- fread('combined_comp_5_1.csv')
two <- fread('combined_comp_5_2.csv')
three <- fread('combined_comp_5_3.csv')
four <- fread('combined_comp_5_4.csv')
five <- fread('combined_comp_5_5.csv')
six <- fread('combined_comp_5_6.csv')
seven <- fread('combined_comp_5_7.csv')
eight <- fread('combined_comp_5_8.csv')
nine <- fread('combined_comp_5_9.csv')
ten <- fread('combined_comp_5_10.csv')

# count nodes in each cluster
one_ct <- one[,.(ct=.N),by='V2'][order(-ct)]
two_ct <- two[,.(ct=.N),by='V2'][order(-ct)]
three_ct <- three[,.(ct=.N),by='V2'][order(-ct)]
four_ct <- four[,.(ct=.N),by='V2'][order(-ct)]
five_ct <- five[,.(ct=.N),by='V2'][order(-ct)]
six_ct <- six[,.(ct=.N),by='V2'][order(-ct)]
seven_ct <- seven[,.(ct=.N),by='V2'][order(-ct)]
eight_ct <- eight[,.(ct=.N),by='V2'][order(-ct)]
nine_ct <- nine[,.(ct=.N),by='V2'][order(-ct)]
ten_ct <- ten[,.(ct=.N),by='V2'][order(-ct)]

one_ct[,gp:='one']
two_ct[,gp:='two']
three_ct[,gp:='three']
four_ct[,gp:='four']
five_ct[,gp:='five']
six_ct[,gp:='six']
seven_ct[,gp:='seven']
eight_ct[,gp:='eight']
nine_ct[,gp:='nine']
ten_ct[,gp:='ten']
all <- rbind(one_ct,two_ct,three_ct,four_ct,five_ct,five_ct,six_ct,seven_ct,eight_ct,nine_ct,ten_ct)

# filter cluster size 
all_10 <- all[ct > 10]
all_50 <- all[ct > 50]
all_100 <- all[ct > 100]

# aggregate stats
all_cts <- all[,.(Q1=quantile(ct,0.25),median=quantile(ct,0.5),Q3=quantile(ct,0.75),Q99=quantile(ct,0.99),mean_cs=round(mean(ct),2),min_cs=min(ct),max_cs=max(ct),n_clusters=.N,total_nodes=sum(ct)),by='gp']
all_10_cts <- all_10[,.(Q1=quantile(ct,0.25),median=quantile(ct,0.5),Q3=quantile(ct,0.75),Q99=quantile(ct,0.99),mean_cs=round(mean(ct),2),min_cs=min(ct),max_cs=max(ct),n_clusters=.N,total_nodes=sum(ct)),by='gp']
all_50_cts <- all_50[,.(Q1=quantile(ct,0.25),median=quantile(ct,0.5),Q3=quantile(ct,0.75),Q99=quantile(ct,0.99),mean_cs=round(mean(ct),2),min_cs=min(ct),max_cs=max(ct),n_clusters=.N,total_nodes=sum(ct)),by='gp']
all_100_cts <- all_100[,.(Q1=quantile(ct,0.25),median=quantile(ct,0.5),Q3=quantile(ct,0.75),Q99=quantile(ct,0.99),mean_cs=round(mean(ct),2),min_cs=min(ct),max_cs=max(ct),n_clusters=.N,total_nodes=sum(ct)),by='gp']

fwrite(all_cts,file='all_cts.csv')
fwrite(all_10_cts,file='all_10_cts.csv')
fwrite(all_50_cts,file='all_50_cts.csv')
fwrite(all_100_cts,file='all_100_cts.csv')






