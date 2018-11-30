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

x <- inner_join(mcmc_10_5,mcmc_1_5,by='parm')
colnames(x) <- c('parm','mcmc_10_5','mcmc_1_5')
y <- inner_join(swr_0_5,perm_0_5,by='parm')
colnames(y) <- c('parm','swr_0_5','perm_0_5')
z <- inner_join(x,y,by='parm')

x <- inner_join(mcmc_1_10,swr_0_10,by='parm')
colnames(x) <- c('parm','mcmc_1_10','swr_0_10')
x <-  inner_join(x,perm_0_10,by='parm')
colnames(x) <- c('parm','mcmc_1_10','swr_0_10','perm_0_10')
z <- inner_join(z,x,by='parm')

x <- inner_join(swr_0_100,perm_0_100,by='parm')
colnames(x) <- c('parm','swr_0_100','perm_0_100')
summary_data <- inner_join(z,x,by='parm')

