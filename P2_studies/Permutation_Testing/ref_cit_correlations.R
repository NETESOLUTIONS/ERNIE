setwd('~/Desktop/QSS Rebuttal 2/')
rm(list=ls())

library(data.table); library(plotrix)
# all

d1985 <- fread('d1000_pubwise_refs_85.csv')
d1985 <- d1985[,.(refcount,citation_count)]
d1985[,`:=`(year=1985)]
d1985 <- d1985[refcount < 100]

d1995 <- fread('d1000_pubwise_refs_95.csv')
d1995 <- d1995[,.(refcount,citation_count)]
d1995[,`:=`(year=1995)]
d1995 <- d1995[refcount < 100]

d2005 <- fread('d1000_pubwise_refs_2005.csv')
d2005 <- d2005[,.(refcount,citation_count)]
d2005[,`:=`(year=2005)]
d2005 <- d2005[refcount < 100]

d_all <- rbind(d1985,d1995,d2005)
d_all_se <- d_all[,.(mean=mean(citation_count),se=std.error(citation_count)),by=c('year','refcount')]
d_all_se[is.na(d_all_se)] <- 0

pdf('all_ref_cit.pdf')
ggplot(d_all_se, aes(x=refcount, y=mean)) + 
geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.1) +
geom_line() + geom_point() + facet_grid(rows = vars(year))
dev.off()

#ap
ap1985 <- fread('ap_pubwise_refs_85.csv')
ap1985 <- ap1985[,.(refcount,citation_count)]
ap1985[,`:=`(year=1985)]
ap1985 <- ap1985[refcount < 100]

ap1995 <- fread('ap_pubwise_refs_95.csv')
ap1995 <- ap1995[,.(refcount,citation_count)]
ap1995[,`:=`(year=1995)]
ap1995 <- ap1995[refcount < 100]

ap2005 <- fread('ap_pubwise_refs_2005.csv')
ap2005 <- ap2005[,.(refcount,citation_count)]
ap2005[,`:=`(year=2005)]
ap2005 <- ap2005[refcount < 100]

ap_all <- rbind(ap1985,ap1995,ap2005)
ap_all_se <- ap_all[,.(mean=mean(citation_count),se=std.error(citation_count)),by=c('year','refcount')]
ap_all_se[is.na(ap_all_se)] <- 0

pdf('ap_ref_cit.pdf')
ggplot(ap_all_se, aes(x=refcount, y=mean)) + 
geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.1) +
geom_line() + geom_point() + facet_grid(rows = vars(year))
dev.off()

#imm
imm1985 <- fread('imm_pubwise_refs_85.csv')
imm1985 <- imm1985[,.(refcount,citation_count)]
imm1985[,`:=`(year=1985)]
imm1985 <- imm1985[refcount < 100]

imm1995 <- fread('imm_pubwise_refs_95.csv')
imm1995 <- imm1995[,.(refcount,citation_count)]
imm1995[,`:=`(year=1995)]
imm1995 <- imm1995[refcount < 100]

imm2005 <- fread('imm_pubwise_refs_2005.csv')
imm2005 <- imm2005[,.(refcount,citation_count)]
imm2005[,`:=`(year=2005)]
imm2005 <- imm2005[refcount < 100]

imm_all <- rbind(imm1985,imm1995,imm2005)
imm_all_se <- imm_all[,.(mean=mean(citation_count),se=std.error(citation_count)),by=c('year','refcount')]
imm_all_se[is.na(imm_all_se)] <- 0

pdf('imm_ref_cit.pdf')
ggplot(imm_all_se, aes(x=refcount, y=mean)) + 
geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.1) +
geom_line() + geom_point() + facet_grid(rows = vars(year))
dev.off()

#metab
metab1985 <- fread('metab_pubwise_refs_85.csv')
metab1985 <- metab1985[,.(refcount,citation_count)]
metab1985[,`:=`(year=1985)]
metab1985 <- metab1985[refcount < 100]

metab1995 <- fread('metab_pubwise_refs_95.csv')
metab1995 <- metab1995[,.(refcount,citation_count)]
metab1995[,`:=`(year=1995)]
metab1995 <- metab1995[refcount < 100]

metab2005 <- fread('metab_pubwise_refs_2005.csv')
metab2005 <- metab2005[,.(refcount,citation_count)]
metab2005[,`:=`(year=2005)]
metab2005 <- metab2005[refcount < 100]

metab_all <- rbind(metab1985,metab1995,metab2005)
metab_all_se <- metab_all[,.(mean=mean(citation_count),se=std.error(citation_count)),by=c('year','refcount')]
metab_all_se[is.na(metab_all_se)] <- 0

pdf('metab_ref_cit.pdf')
ggplot(metab_all_se, aes(x=refcount, y=mean)) + 
geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.1) +
geom_line() + geom_point() + facet_grid(rows = vars(year))
dev.off()

ap_all[,gp:='ap']
imm_all[,gp:='imm']
metab_all[,gp:='metab']
all_all <- rbind(ap_all,imm_all,metab_all)
all_all_se <- all_all[,.(mean=mean(citation_count),se=std.error(citation_count)),by=c('year','refcount','gp')]
all_all_se[is.na(all_all_se)] <- 0

pdf('all_ref_cit_year_gp.pdf')
ggplot(all_all_se, aes(x=refcount, y=mean)) + 
geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.1) +
geom_line() + geom_point() + facet_grid(year~gp)
dev.off()



