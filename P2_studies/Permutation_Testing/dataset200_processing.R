# script to process WoS data slices to look at relationship 
# between citation count and z_scores in aggregate

rm(list=ls())
library(data.table)
setwd('~/Desktop/Focused_Domain_Analysis/')
# Year 1995 data
d95_zsc_med <- fread('d95_zsc_med.csv')
d95_cit <- fread('dataset1995_cit_counts.csv')
cit_d95 <- merge(d95_zsc_med,d95_cit,by.x='source_id',by.y='source_id')

cit_d95_90 <- cit_d95[citation_count > quantile(d95_cit$citation_count,0.9)]
cit_d95_90 <- cit_d95_90[order(citation_count)]
cit_d95_90_gp <- cit_d95_90[,gp:='x']
interval <- floor(nrow(cit_d95_90)/10)

# R seems to evaluate these intervals in a bizarre way but this worked

x <- interval*9+1
y <- nrow(cit_d95_90)

cit_d95_90_gp$gp[1:interval]   <-  'gp1'
cit_d95_90_gp$gp[interval+1:interval]   <-  'gp2'
cit_d95_90_gp$gp[interval*2+1:interval]   <-  'gp3'
cit_d95_90_gp$gp[interval*3+1:interval]   <-  'gp4'
cit_d95_90_gp$gp[interval*4+1:interval]   <-  'gp5'
cit_d95_90_gp$gp[interval*5+1:interval]   <-  'gp6'
cit_d95_90_gp$gp[interval*6+1:interval]   <-  'gp7'
cit_d95_90_gp$gp[interval*7+1:interval]   <-  'gp8'
cit_d95_90_gp$gp[interval*8+1:interval]   <-  'gp9'
cit_d95_90_gp$gp[x:y]   <-  'gp10'

cit_d95_90_gp$gp <- factor(cit_d95_90_gp$gp, levels = c("gp1", "gp2", "gp3", "gp4", "gp5", "gp6", "gp7", "gp8", "gp9", "gp10"))

cit_d95_90_gp <- cit_d95_90_gp[,.(med_med=median(med),med_ten=median(ten),med_one=median(one)),by='gp']

mcit_d95_90_gp <- melt(cit_d95_90_gp,id="gp")

rm(cit_d95); rm(cit_d95_90); rm(cit_d95_90_gp); rm(d95_cit); rm(d95_zsc_med); rm(interval)
rm(x); rm(y)
fwrite(mcit_d95_90_gp,file='mcit_d95_90_gp.csv',row.names=FALSE)

# Year 2000 data
d20_zsc_med <- fread('d20_zsc_med.csv')
d20_cit <- fread('dataset2000_cit_counts.csv')
cit_d20 <- merge(d20_zsc_med,d20_cit,by.x='source_id',by.y='source_id')

cit_d20_90 <- cit_d20[citation_count > quantile(d20_cit$citation_count,0.9)]
cit_d20_90 <- cit_d20_90[order(citation_count)]
cit_d20_90_gp <- cit_d20_90[,gp:='x']
interval <- floor(nrow(cit_d20_90)/10)

# R seems to evaluate these intervals in a bizarre way but this worked

x <- interval*9+1
y <- nrow(cit_d20_90)

cit_d20_90_gp$gp[1:interval]   <-  'gp1'
cit_d20_90_gp$gp[interval+1:interval]   <-  'gp2'
cit_d20_90_gp$gp[interval*2+1:interval]   <-  'gp3'
cit_d20_90_gp$gp[interval*3+1:interval]   <-  'gp4'
cit_d20_90_gp$gp[interval*4+1:interval]   <-  'gp5'
cit_d20_90_gp$gp[interval*5+1:interval]   <-  'gp6'
cit_d20_90_gp$gp[interval*6+1:interval]   <-  'gp7'
cit_d20_90_gp$gp[interval*7+1:interval]   <-  'gp8'
cit_d20_90_gp$gp[interval*8+1:interval]   <-  'gp9'
cit_d20_90_gp$gp[x:y]   <-  'gp10'

cit_d20_90_gp$gp <- factor(cit_d20_90_gp$gp, levels = c("gp1", "gp2", "gp3", "gp4", "gp5", "gp6", "gp7", "gp8", "gp9", "gp10"))

cit_d20_90_gp <- cit_d20_90_gp[,.(med_med=median(med),med_ten=median(ten),med_one=median(one)),by='gp']

mcit_d20_90_gp <- melt(cit_d20_90_gp,id="gp")
fwrite(mcit_d20_90_gp,file='mcit_d20_90_gp.csv',row.names=FALSE)

rm(cit_d20); rm(cit_d20_90); rm(cit_d20_90_gp); rm(d20_cit); rm(d20_zsc_med); rm(interval)
rm(x); rm(y)

# Year 2005 data
d25_zsc_med <- fread('d25_zsc_med.csv')
d25_cit <- fread('dataset2005_cit_counts.csv')
cit_d25 <- merge(d25_zsc_med,d25_cit,by.x='source_id',by.y='source_id')

cit_d25_90 <- cit_d25[citation_count > quantile(d25_cit$citation_count,0.9)]
cit_d25_90 <- cit_d25_90[order(citation_count)]
cit_d25_90_gp <- cit_d25_90[,gp:='x']
interval <- floor(nrow(cit_d25_90_gp)/10)

# R seems to evaluate these intervals in a bizarre way but this worked

x <- interval*9+1
y <- nrow(cit_d25_90_gp)

cit_d25_90_gp$gp[1:interval]   <-  'gp1'
cit_d25_90_gp$gp[interval+1:interval]   <-  'gp2'
cit_d25_90_gp$gp[interval*2+1:interval]   <-  'gp3'
cit_d25_90_gp$gp[interval*3+1:interval]   <-  'gp4'
cit_d25_90_gp$gp[interval*4+1:interval]   <-  'gp5'
cit_d25_90_gp$gp[interval*5+1:interval]   <-  'gp6'
cit_d25_90_gp$gp[interval*6+1:interval]   <-  'gp7'
cit_d25_90_gp$gp[interval*7+1:interval]   <-  'gp8'
cit_d25_90_gp$gp[interval*8+1:interval]   <-  'gp9'
cit_d25_90_gp$gp[x:y]   <-  'gp10'

cit_d25_90_gp$gp <- factor(cit_d25_90_gp$gp, levels = c("gp1", "gp2", "gp3", "gp4", "gp5", "gp6", "gp7", "gp8", "gp9", "gp10"))

cit_d25_90_gp <- cit_d25_90_gp[,.(med_med=median(med),med_ten=median(ten),med_one=median(one)),by='gp']

mcit_d25_90_gp <- melt(cit_d25_90_gp,id="gp")
fwrite(mcit_d25_90_gp,file='mcit_d25_90_gp.csv',row.names=FALSE)

rm(cit_d25); rm(cit_d25_90); rm(cit_d25_90_gp); rm(d25_cit); rm(d25_zsc_med); rm(interval)
rm(x); rm(y)

