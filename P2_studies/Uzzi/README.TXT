# 12/22/2018 The scripts in this folder all relate to data prep and analysis for 
# the co-citation analysis project that is largely inspired by a combination of
# our experience with the data in ERNIE and the Science paper in 2013 by Uzzi et al.

1) uz_ds.sql: generates year slices of the WoS dataset
2) bg_permute_recursive_dedupe.R: implements the background model from the Science paper using permutation
3) bg_swr_recursive_dedupe.R: implements the background model using sampling with replacement
4) frequencies.R: calculates the frequency of citation (number of times it has been cited) within the year slice
5) probtest.R: generates kvals and pairs.csv to implement Warnow's closed form solution of the background model
6) please fill in the others

The workflow is 

1) generate year slice
2) generate background models if going the MCMC route
3) calculate frequencies 
4) calculate kvals and pairs for closed form solutions

