rm(list = ls())
setwd("~/Desktop/theta_plus")
library(data.table)
library(ggplot2)
library(xtable)

# read in data from Shreya'a analysis on ernie-2

eco_mcl <- fread("eco2000_2010_conductance_unshuffled.csv")
eco_leiden <- fread("eco2000_2010_conductance_leiden_CPM_R0002.csv")

imm_small_mcl <- fread("imm2000_2004_conductance_unshuffled.csv")
imm_small_leiden <- fread("imm2000_2004_conductance_leiden_CPM_R0002.csv")

imm_large_mcl <- fread("imm1985_1995_conductance_unshuffled.csv")
imm_large_leiden <- fread("imm1985_1995_conductance_leiden_CPM_R0002.csv")

names <- vector()
names[1] <- 'imm_l_mcl'
names[2] <- 'imm_l_leiden'
names[3] <- 'imm_s_mcl'
names[4] <- 'imm_s__leiden'
names[5] <- 'eco_mcl'
names[6] <- 'eco_leiden'

sizevec <- vector()
sizevec[1] <- imm_large_mcl[,.N]
sizevec[2] <- imm_large_leiden[,.N]
sizevec[3] <- imm_small_mcl[,.N]
sizevec[4] <- imm_small_leiden[,.N]
sizevec[5] <- eco_mcl[,.N]
sizevec[6] <- eco_leiden[,.N]


sizevec_30_350 <- vector()
sizevec_30_350[1] <- imm_large_mcl[cluster_counts >=30 & cluster_counts <=350,.N]
sizevec_30_350[2] <- imm_large_leiden[cluster_counts >=30 & cluster_counts <=350,.N]
sizevec_30_350[3] <- imm_small_mcl[cluster_counts >=30 & cluster_counts <=350,.N]
sizevec_30_350[4] <- imm_small_leiden[cluster_counts >=30 & cluster_counts <=350,.N]
sizevec_30_350[5] <- eco_mcl[cluster_counts >=30 & cluster_counts <=350,.N]
sizevec_30_350[6] <- eco_leiden[cluster_counts >=30 & cluster_counts <=350,.N]


singleton_count <- vector()
singleton_count[1] <- imm_large_mcl[cluster_counts==1,.N]
singleton_count[2] <- imm_large_leiden[cluster_counts==1,.N]
singleton_count[3] <- imm_small_mcl[cluster_counts==1,.N]
singleton_count[4] <- imm_small_leiden[cluster_counts==1,.N]
singleton_count[5] <- eco_mcl[cluster_counts==1,.N]
singleton_count[6] <- eco_leiden[cluster_counts==1,.N]


less_than_30 <- vector()
less_than_30[1] <- imm_large_mcl[cluster_counts <30,.N]
less_than_30[2] <- imm_large_leiden[cluster_counts <30,.N]
less_than_30[3] <- imm_small_mcl[cluster_counts <30,.N]
less_than_30[4] <- imm_small_leiden[cluster_counts <30,.N]
less_than_30[5] <- eco_mcl[cluster_counts <30,.N]
less_than_30[6] <- eco_leiden[cluster_counts <30,.N]

greater_than_350 <-vector()
greater_than_350[1] <- imm_large_mcl[cluster_counts > 350,.N]
greater_than_350[2] <- imm_large_leiden[cluster_counts > 350,.N]
greater_than_350[3] <- imm_small_mcl[cluster_counts > 350,.N]
greater_than_350[4] <- imm_small_leiden[cluster_counts > 350,.N]
greater_than_350[5] <- eco_mcl[cluster_counts > 350,.N]
greater_than_350[6] <- eco_leiden[cluster_counts > 350,.N]

# generate table

table2 <- data.frame(cbind(names,sizevec,sizevec_30_350,singleton_count,less_than_30,greater_than_350))
colnames(table2) <- c('dataset','clusters','clusters_30_350', 'singletons', 'less_than_30', 'greater_than_350')
library(xtable)
xtable(table2)

# generate conductance distribution

ilm <- imm_large_mcl[cluster_counts >=30 & cluster_counts <=350][,.(conductance,'imm_l_mcl')]
ill <- imm_large_leiden[cluster_counts >=30 & cluster_counts <=350][,.(conductance,'imm_l_leiden')]
ism <- imm_small_mcl[cluster_counts >=30 & cluster_counts <=350][,.(conductance,'imm_s_mcl')]
isl <- imm_small_leiden[cluster_counts >=30 & cluster_counts <=350][,.(conductance,'imm_s_leiden')]
emc <- eco_mcl[cluster_counts >=30 & cluster_counts <=350][,.(conductance,'eco_mcl')]
elc <- eco_leiden[cluster_counts >=30 & cluster_counts <=350][,.(conductance,'eco_leiden')]

conductances <- rbind(emc,elc,ism,isl,ilm,ill)
conductances[V2=='eco_mcl',c('gp','col'):= list('eco','mcl')]
conductances[V2=='eco_leiden',c('gp','col'):= list('eco','leiden')]

conductances[V2=='imm_l_mcl',c('gp','col'):= list('imm_1','mcl')]
conductances[V2=='imm_l_leiden',c('gp','col'):= list('imm_1','leiden')]

conductances[V2=='imm_s_mcl',c('gp','col'):= list('imm_2','mcl')]
conductances[V2=='imm_s_leiden',c('gp','col'):= list('imm_2','leiden')]

conductances$color <- factor(conductances$color,levels=c("mcl","leiden"))

pdf('fig3.pdf')
updated per editors request for greater font size
#qplot(conductance,data=conductances,geom='density',group=V2,color=col,facets=.~gp) +  theme_bw() + 
#theme(legend.title = element_blank()) + theme(text = element_text(size=20)
qplot(conductance,data=conductances,geom='density',group=V2,color=col,facets=.~gp) +  theme_bw() + theme(legend.title = element_blank()) + theme(text = element_text(size=20),axis.text.x = element_text(angle=-90, hjust=1))
dev.off()

# repeat for size distribution

ilm <- imm_large_mcl[cluster_counts >=30 & cluster_counts <=350][,.(cluster_counts,'imm_l_mcl')]
ill <- imm_large_leiden[cluster_counts >=30 & cluster_counts <=350][,.(cluster_counts,'imm_l_leiden')]
ism <- imm_small_mcl[cluster_counts >=30 & cluster_counts <=350][,.(cluster_counts,'imm_s_mcl')]
isl <- imm_small_leiden[cluster_counts >=30 & cluster_counts <=350][,.(cluster_counts,'imm_s_leiden')]
emc <- eco_mcl[cluster_counts >=30 & cluster_counts <=350][,.(cluster_counts,'eco_mcl')]
elc <- eco_leiden[cluster_counts >=30 & cluster_counts <=350][,.(cluster_counts,'eco_leiden')]

sizes <- rbind(emc,elc,ism,isl,ilm,ill)
sizes[V2=='eco_mcl',c('gp','col'):= list('eco','mcl')]
sizes[V2=='eco_leiden',c('gp','col'):= list('eco','leiden')]

sizes[V2=='imm_l_mcl',c('gp','col'):= list('imm_1','mcl')]
sizes[V2=='imm_l_leiden',c('gp','col'):= list('imm_1','leiden')]

sizes[V2=='imm_s_mcl',c('gp','col'):= list('imm_2','mcl')]
sizes[V2=='imm_s_leiden',c('gp','col'):= list('imm_2','leiden')]

sizes$color <- factor(sizes$color,levels=c("mcl","leiden"))

pdf('fig2.pdf')
# updated per editors request for greater font size
#qplot(cluster_counts,data=sizes,geom='density',group=V2,color=col,facets=.~gp)+  theme_bw()  + 
#theme(legend.title = element_blank()) 
qplot(cluster_counts,data=sizes,geom='density',group=V2,color=col,facets=.~gp)+  theme_bw()  + 
theme(legend.title = element_blank()) + theme(text = element_text(size=20),axis.text.x = element_text(angle=-90, hjust=1))
dev.off()

system('cp fig2.pdf ~/ERNIE_tp/tp_combined_rebuttal/fig2.pdf')
system('cp fig3.pdf ~/ERNIE_tp/tp_combined_rebuttal/fig3.pdf')










