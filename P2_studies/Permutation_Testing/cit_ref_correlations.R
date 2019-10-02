setwd('~/Desktop/QSS Rebuttal 2/')
rm(list=ls())

library(data.table); library(plotrix);library(ggplot2)
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

# standard error is computed across all three years
d_all <- rbind(d1985,d1995,d2005)
d_all_se <- d_all[,.(mean=mean(refcount),se=std.error(refcount)),by=c('year','citation_count')]
d_all_se[is.na(d_all_se)] <- 0

pdf('all_cit_ref.pdf')
ggplot(d_all_se, aes(x=citation_count, y=mean)) + 
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

# standard error is computed across all three years
ap_all <- rbind(ap1985,ap1995,ap2005)
ap_all_se <- ap_all[,.(mean=mean(refcount),se=std.error(refcount)),by=c('year','citation_count')]
ap_all_se[is.na(ap_all_se)] <- 0

pdf('ap_cit_ref.pdf')
ggplot(ap_all_se, aes(x=citation_count, y=mean)) + 
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

# standard error is computed across all three years
imm_all <- rbind(imm1985,imm1995,imm2005)
imm_all_se <- imm_all[,.(mean=mean(refcount),se=std.error(refcount)),by=c('year','citation_count')]
imm_all_se[is.na(imm_all_se)] <- 0

pdf('imm_cit_ref.pdf')
ggplot(imm_all_se, aes(x=citation_count, y=mean)) + 
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

# standard error is computed across all three years
metab_all <- rbind(metab1985,metab1995,metab2005)
metab_all_se <- metab_all[,.(mean=mean(refcount),se=std.error(refcount)),by=c('year','citation_count')]
metab_all_se[is.na(metab_all_se)] <- 0

pdf('metab_cit_ref.pdf')
ggplot(metab_all_se, aes(x=citation_count, y=mean)) + 
geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.1) +
geom_line() + geom_point() + facet_grid(rows = vars(year))
dev.off()

# standard error is computed across all three years
ap_all[,gp:='ap']
imm_all[,gp:='imm']
metab_all[,gp:='metab']
all_all <- rbind(ap_all,imm_all,metab_all)
all_all_se <- all_all[,.(mean=mean(refcount),se=std.error(refcount)),by=c('year','citation_count','gp')]
all_all_se[is.na(all_all_se)] <- 0

pdf('all_cit_ref_year_gp.pdf')
ggplot(all_all_se, aes(x=citation_count, y=mean)) + 
geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.1) +
geom_line() + geom_point() + facet_grid(year~gp)
dev.off()

pdf('all_cit_ref_year_gp_zoom.pdf')
ggplot(all_all_se[all_all_se$citation_count < 2000 & all_all_se$citation_count > 30,], aes(x=citation_count, y=mean)) + 
geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.1) +
geom_line() + geom_point() + facet_grid(year~gp)
dev.off()



