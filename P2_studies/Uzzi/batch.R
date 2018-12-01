source('mcstats.R')

mcmc_10_5 <- ucomparison('zscores1980_10_shuffle_5.csv',5,10,2700,4) 
mcmc_1_5 <- ucomparison('zscores1980_1_shuffle_5.csv',5,1,300,3)
perm_0_5 <- ucomparison('zscores1980_permute_5.csv',5,0,1,1) 
swr_0_5 <- ucomparison('zscores1980_swr_5.csv',5,0,1,2) 

mcmc_1_10 <- ucomparison('zscores1980_1_shuffle_10.csv',10,1,300,3)
perm_0_10 <- ucomparison('zscores1980_permute_10.csv',10,0,1,1) 
swr_0_10 <- ucomparison('zscores1980_swr_10.csv',10,0,1,2) 

perm_0_100 <- ucomparison('zscores1980_permute_100.csv',100,0,1,1) 
swr_0_100 <- ucomparison('zscores1980_swr_100.csv',100,0,1,2) 

dflist <- list(mcmc_10_5,mcmc_1_5,perm_0_5,swr_0_5,mcmc_1_10,perm_0_10,swr_0_10,perm_0_100,swr_0_100)

# longer version
# Reduce(function(x, y) merge(x, y, all=TRUE or by='whateverby'), list(df1, df2, df3))
summary_data <- reduce(function(...) merge(...,by='parm'),dflist)




