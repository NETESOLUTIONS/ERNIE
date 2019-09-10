setwd('/ernie1_museum/data_1985')
rm(list=ls())
library(data.table)
# All WoS 1985
d1000_pubwise_85 <- fread('d1000_85_pubwise_zsc_med.csv')
refs_85 <- fread('reference_count_1985.csv')
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
fwrite(imm_pubwise_refs,file='imm_pubwise_refs.csv')

# metab_85
refs_85_metab <- refs_85[metab=='t']
metab_pubwise_85 <- fread('metab85_pubwise_zsc_med.csv')
metab_pubwise_refs <- merge(metab_pubwise_85, refs_85_metab,by.x='source_id',by.y='source_id')
fwrite(metab_pubwise_refs,file='metab_pubwise_refs.csv')
