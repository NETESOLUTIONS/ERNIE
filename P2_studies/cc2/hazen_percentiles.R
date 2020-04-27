# Calculation of Hazen percentiles
# read in data
rm(list=ls())
# Dataset, which includes reference counts and papers with zero citations 
x <- fread('~/Downloads/f1000_reference_count.csv')

# set NA to zero for percentile calculations
x[is.na(x)] <-0

# filter to years with data in them
x <- x[pub_year >= 1996 & pub_year <= 2018]

# generate ranks by pub_year using method of averaging
y <- x[,.(scp,reference_count,citation_count,n=length(scp),
rank=rank(citation_count,ties.method='average')),by='pub_year']

# calculate Hazen percentiles as hazen_perc using 100*(i-0.5)/n as formula
y[,hazen_perc:=100*(rank-0.5)/n]

# set percentile of zero citations to 0
y[citation_count==0,hazen_perc := 0]

x10cit <- x[reference_count>=10]
y10cit <- x10cit[,.(scp,reference_count,citation_count,n=length(scp),
rank=rank(citation_count,ties.method='average')),by='pub_year']
y10cit[,hazen_perc:=100*(rank-0.5)/n]
y10cit[citation_count==0,hazen_perc := 0]
setwd('~/Downloads')
fwrite(y,file='f1000_hazen.csv')
fwrite(y10cit,file='f1000_min10cit_hazen.csv')