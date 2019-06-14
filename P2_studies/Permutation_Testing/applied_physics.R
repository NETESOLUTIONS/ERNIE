rm(list=ls())
library(data.table)
library(ggplot2)
library(reshape2)
setwd('/Users/chackoge/Desktop/disciplinary_references')

## ap_1985 dataset
dataset1985_ap_disc_comp <- fread('dataset1985_ap_disc_comp.csv')
x <- dataset1985_ap_disc_comp[,
.(merged_subjects,ap_allwos_uzzi_fc,ap_allwos_nete_fc,ap_nete_fc,ap_uzzi_fc)]
melted_x <- melt(x,id='merged_subjects')
setDT(melted_x)
melted_x <- melted_x[order(variable)]

melted_x[variable=='ap_allwos_nete_fc', bg:='WoS']
melted_x[variable=='ap_allwos_uzzi_fc', bg:='WoS']

melted_x[variable=='ap_nete_fc', bg:='ap']
melted_x[variable=='ap_uzzi_fc', bg:='ap']

# umsj: Uzzi, Mukherjee, Stringer, Jones
melted_x[variable=='ap_allwos_uzzi_fc', algorithm:='umsj'] 
melted_x[variable=='ap_uzzi_fc', algorithm:='umsj']

# repcs: runtime enhanced permuting citation shuffler
melted_x[is.na(algorithm),algorithm:='repcs'] 

melted_x[bg=='ap',bg:='appl_physics']

qplot(bg, value, data=melted_x, facets=algorithm~. , geom='boxplot', group=bg, color=bg,
ylab='fold change in frequency \n(150 WoS extended subjects)',xlab='network background') + 
theme_bw() + theme(legend.position = 'none')

melted_x[,.(ds='ap')]

## metab_85 dataset
dataset1985_metab_disc_comp <- fread('dataset1985_metab_disc_comp.csv')

x <- dataset1985_metab_disc_comp[,
.(merged_subjects,metab_allwos_uzzi_fc,metab_allwos_nete_fc,metab_nete_fc,metab_uzzi_fc)]
melted_x <- melt(x,id='merged_subjects')
setDT(melted_x)
melted_x <- melted_x[order(variable)]

melted_x[variable=='metab_allwos_nete_fc', bg:='WoS']
melted_x[variable=='metab_allwos_uzzi_fc', bg:='WoS']

melted_x[variable=='metab_nete_fc', bg:='metab']
melted_x[variable=='metab_uzzi_fc', bg:='metab']

# umsj: Uzzi, Mukherjee, Stringer, Jones
melted_x[variable=='metab_allwos_uzzi_fc',algorithm:='umsj'] 
melted_x[variable=='metab_uzzi_fc',algorithm:='umsj']

# repcs: runtime enhanced permuting citation shuffler
melted_x[is.na(algorithm),algorithm:='repcs'] 

melted_x[bg=='metab',bg:='metabolism']

qplot(bg, log(value), data=melted_x, facets=algorithm~. ,geom='boxplot',group=bg,color=bg,
ylab='fold change in frequency \n(150 WoS extended subjects)',xlab='network background') + 
theme_bw() + theme(legend.position = 'none')

## imm_85 dataset
dataset1985_imm_disc_comp <- fread('dataset1985_imm_disc_comp.csv')

x <- dataset1985_imm_disc_comp[,
.(merged_subjects,imm_allwos_uzzi_fc,imm_allwos_nete_fc,imm_nete_fc,imm_uzzi_fc)]

## Comment out once Sitaram fixes the source data
x[is.na(imm_allwos_uzzi_fc),imm_allwos_uzzi_fc:=1]
## 

melted_x <- melt(x,id='merged_subjects')
setDT(melted_x)
melted_x <- melted_x[order(variable)]

melted_x[variable=='imm_allwos_nete_fc', bg:='WoS']
melted_x[variable=='imm_allwos_uzzi_fc', bg:='WoS']

melted_x[variable=='imm_nete_fc', bg:='imm']
melted_x[variable=='imm_uzzi_fc', bg:='imm']

# umsj: Uzzi, Mukherjee, Stringer, Jones
melted_x[variable=='imm_allwos_uzzi_fc',algorithm:='umsj'] 
melted_x[variable=='imm_uzzi_fc',algorithm:='umsj']

# repcs: runtime enhanced permuting citation shuffler
melted_x[is.na(algorithm),algorithm:='repcs'] 

melted_x[bg=='imm',bg:='immunology']

qplot(bg, log(value), data=melted_x, facets=algorithm~. ,geom='boxplot',group=bg,color=bg,
ylab='fold change in frequency \n(150 WoS extended subjects)',xlab='network background') + 
theme_bw() + theme(legend.position = 'none')

