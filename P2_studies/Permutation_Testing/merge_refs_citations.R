## Script to combine citation counts, reference counts, and (median, tenth, and first percentiles)
## of z_scores of Uzzi-style simulations on all WoS, ap, imm, and metab datasets for the
## years 1985, 1995, 2005. George Chacko, Sep 2019

setwd('/ernie1_museum/data_1985')
rm(list=ls())
library(data.table)

### All WoS 1985
d1000_pubwise_85 <- fread('d1000_85_pubwise_zsc_med.csv')
refs_85 <- fread('reference_count_1985.csv')
colnames(refs_85)[2] <- 'refcount'
d1000_pubwise_refs_85 <- merge(d1000_pubwise_85,refs_85,by.x='source_id',by.y='source_id')
fwrite(d1000_pubwise_refs_85,file='d1000_pubwise_refs_85.csv')

# ap_85
refs_85_ap <- refs_85[ap=='t']
ap_pubwise_85 <- fread('ap85_pubwise_zsc_med.csv')
ap_pubwise_refs_85 <- merge(ap_pubwise_85, refs_85_ap, by.x='source_id',by.y='source_id')
fwrite(ap_pubwise_refs_85,file='ap_pubwise_refs_85.csv')

#imm_85
refs_85_imm <- refs_85[imm=='t']
imm_pubwise_85 <- fread('imm85_pubwise_zsc_med.csv')
imm_pubwise_refs <- merge(imm_pubwise_85,refs_85_imm, by.x='source_id',by.y='source_id')
fwrite(imm_pubwise_refs,file='imm_pubwise_refs_85.csv')

# metab_85
refs_85_metab <- refs_85[metab=='t']
metab_pubwise_85 <- fread('metab85_pubwise_zsc_med.csv')
metab_pubwise_refs <- merge(metab_pubwise_85, refs_85_metab,by.x='source_id',by.y='source_id')
fwrite(metab_pubwise_refs,file='metab_pubwise_refs_85.csv')

### All WoS 1995
setwd('/ernie1_museum/data_1995')
rm(list=ls())
d1000_pubwise_95 <- fread('d1000_95_pubwise_zsc_med.csv')
refs_95 <- fread('reference_count_1995.csv')
colnames(refs_95)[2] <- 'refcount'
d1000_pubwise_refs_95 <- merge(d1000_pubwise_95,refs_95,by.x='source_id',by.y='source_id')
fwrite(d1000_pubwise_refs_95,file='d1000_pubwise_refs_95.csv')

# ap_95
refs_95_ap <- refs_95[ap=='t']
ap_pubwise_95 <- fread('ap95_pubwise_zsc_med.csv')
ap_pubwise_refs_95 <- merge(ap_pubwise_95, refs_95_ap, by.x='source_id',by.y='source_id')
fwrite(ap_pubwise_refs_95,file='ap_pubwise_refs_95.csv')

#imm_95
refs_95_imm <- refs_95[imm=='t']
imm_pubwise_95 <- fread('imm95_pubwise_zsc_med.csv')
imm_pubwise_refs <- merge(imm_pubwise_95,refs_95_imm, by.x='source_id',by.y='source_id')
fwrite(imm_pubwise_refs,file='imm_pubwise_refs_95.csv')

# metab_95
refs_95_metab <- refs_95[metab=='t']
metab_pubwise_95 <- fread('metab95_pubwise_zsc_med.csv')
metab_pubwise_refs <- merge(metab_pubwise_95, refs_95_metab,by.x='source_id',by.y='source_id')
fwrite(metab_pubwise_refs,file='metab_pubwise_refs_95.csv')

### All WoS 2005
setwd('/ernie1_museum/data_2005')
rm(list=ls())
d1000_pubwise_2005 <- fread('d1000_2005_pubwise_zsc_med.csv')
refs_2005 <- fread('reference_count_2005.csv')
colnames(refs_2005)[2] <- 'refcount'
d1000_pubwise_refs_2005 <- merge(d1000_pubwise_2005,refs_2005,by.x='source_id',by.y='source_id')
fwrite(d1000_pubwise_refs_2005,file='d1000_pubwise_refs_2005.csv')

# ap_2005
refs_2005_ap <- refs_2005[ap=='t']
ap_pubwise_2005 <- fread('ap2005_pubwise_zsc_med.csv')
ap_pubwise_refs_2005 <- merge(ap_pubwise_2005, refs_2005_ap, by.x='source_id',by.y='source_id')
fwrite(ap_pubwise_refs_2005,file='ap_pubwise_refs_2005.csv')

#imm_2005
refs_2005_imm <- refs_2005[imm=='t']
imm_pubwise_2005 <- fread('imm2005_pubwise_zsc_med.csv')
imm_pubwise_refs <- merge(imm_pubwise_2005,refs_2005_imm, by.x='source_id',by.y='source_id')
fwrite(imm_pubwise_refs,file='imm_pubwise_refs_2005.csv')

# metab_2005
refs_2005_metab <- refs_2005[metab=='t']
metab_pubwise_2005 <- fread('metab2005_pubwise_zsc_med.csv')
metab_pubwise_refs <- merge(metab_pubwise_2005, refs_2005_metab,by.x='source_id',by.y='source_id')
fwrite(metab_pubwise_refs,file='metab_pubwise_refs_2005.csv')

rm(list=ls())
