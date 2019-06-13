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
melted_x[,ds:='ap']
melted_x <- melted_x[order(variable)]

melted_x[variable=='ap_allwos_nete_fc', bg:='ap_WoS']
melted_x[variable=='ap_allwos_uzzi_fc', bg:='ap_WoS']

melted_x[variable=='ap_nete_fc', bg:='ap']
melted_x[variable=='ap_uzzi_fc', bg:='ap']

# umsj: Uzzi, Mukherjee, Stringer, Jones
melted_x[variable=='ap_allwos_uzzi_fc', algorithm:='umsj'] 
melted_x[variable=='ap_uzzi_fc', algorithm:='umsj']

# repcs: runtime enhanced permuting citation shuffler
melted_x[is.na(algorithm),algorithm:='repcs'] 
melted_x[bg=='ap',bg:='appl_physics']
ap_x <- melted_x

## metab_85 dataset
dataset1985_metab_disc_comp <- fread('dataset1985_metab_disc_comp.csv')

x <- dataset1985_metab_disc_comp[,
.(merged_subjects,metab_allwos_uzzi_fc,metab_allwos_nete_fc,metab_nete_fc,metab_uzzi_fc)]
melted_x <- melt(x,id='merged_subjects')
setDT(melted_x)
melted_x[,ds:='metab']
melted_x <- melted_x[order(variable)]

melted_x[variable=='metab_allwos_nete_fc', bg:='metab_WoS']
melted_x[variable=='metab_allwos_uzzi_fc', bg:='metab_WoS']

melted_x[variable=='metab_nete_fc', bg:='metab']
melted_x[variable=='metab_uzzi_fc', bg:='metab']

# umsj: Uzzi, Mukherjee, Stringer, Jones
melted_x[variable=='metab_allwos_uzzi_fc',algorithm:='umsj'] 
melted_x[variable=='metab_uzzi_fc',algorithm:='umsj']

# repcs: runtime enhanced permuting citation shuffler
melted_x[is.na(algorithm),algorithm:='repcs'] 
melted_x[bg=='metab',bg:='metabolism']
metab_x <- melted_x

## imm_85 dataset
dataset1985_imm_disc_comp <- fread('dataset1985_imm_disc_comp.csv')
x <- dataset1985_imm_disc_comp[,
.(merged_subjects,imm_allwos_uzzi_fc,imm_allwos_nete_fc,imm_nete_fc,imm_uzzi_fc)]

melted_x <- melt(x,id='merged_subjects')
setDT(melted_x)
melted_x[,ds:='imm']
melted_x <- melted_x[order(variable)]

melted_x[variable=='imm_allwos_nete_fc', bg:='imm_WoS']
melted_x[variable=='imm_allwos_uzzi_fc', bg:='imm_WoS']

melted_x[variable=='imm_nete_fc', bg:='imm']
melted_x[variable=='imm_uzzi_fc', bg:='imm']

# umsj: Uzzi, Mukherjee, Stringer, Jones
melted_x[variable=='imm_allwos_uzzi_fc',algorithm:='umsj'] 
melted_x[variable=='imm_uzzi_fc',algorithm:='umsj']

# repcs: runtime enhanced permuting citation shuffler
melted_x[is.na(algorithm),algorithm:='repcs'] 

melted_x[bg=='imm',bg:='immunology']
imm_x <- melted_x

X <- rbind(ap_x,imm_x,metab_x)

X$bg <- factor(X$bg,levels=c('appl_physics','ap_WoS','immunology','imm_WoS','metabolism','metab_WoS'))

pdf('background-effect.pdf')
qplot(bg, log(value), data=X, facets=algorithm~. ,geom='boxplot',group=bg,color=bg, ylab=expression(paste((log[2]),' fold change in subject frequency of references')),xlab='network background')  + theme_bw() + theme(strip.text.y = element_text(size = 14)) + theme(legend.position = 'none') 
dev.off()
rm(list=ls())


