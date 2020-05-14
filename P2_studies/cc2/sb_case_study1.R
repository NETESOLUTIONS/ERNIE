rm(list=ls())
library(data.table); library(ggplot2);library(reshape);library(patchwork)

setwd('~/Desktop/cc2/case_studies')

# Instability of the interface of two gases accelerated by a shock wave doi: 10.1007/BF01015969
# Taylor instability in shock acceleration of compressible fluids doi: 10.1002/cpa.3160130207
c1_1 <- fread('case1_34250466139.csv') #pub_year=1972, first_time_cited=1993
c1_2 <- fread('case1_84980087532.csv') #pub_year=1960, first_time_cited=1973
c1_cc <- fread('case1_cocited.csv') # first_co_cited_year=1993
c1_cc <- c1_cc[,.(cc_year=co_cited_year,cc_frequency=frequency)]

#Insert single citation in first_pub_year to mark graph
c1_1_buff <-c(1972,0)
c1_1 <- rbind(c1_1_buff,data.frame(c1_1))

c1_2_buff <-c(1960,0)
c1_2 <- rbind(c1_2_buff,data.frame(c1_2))

t1 <- base::merge(c1_1,c1_2,by.x='pub_year',by.y='pub_year',all.x=T,all.y=T)
case1 <- base::merge(t1,c1_cc,by.x='pub_year',by.y='cc_year',all.x=T,all.y=T)
case1[!is.na(case1$pub_year),]; 
case1 <- setDT(case1)
case1 <- case1[pub_year <= 2018]
colnames(case1) <- c('pub_year','pub1','pub2','cocite')
# case1[is.na(case1)] <-0
m_case1 <- reshape::melt(case1,id='pub_year')
colnames(m_case1)[2] <- "example_1"
pcase1 <- qplot(pub_year,value,group=example_1,data=m_case1,geom=c('point','line'),xlim=c(1950,2020),
ylim=c(0,250),color=example_1,ylab='Frequency',xlab="") 
pcase1 <- pcase1 +  geom_vline(aes(xintercept=1972), colour="#000000", linetype="dashed") +
geom_vline(aes(xintercept=1960), colour="#000000", linetype="dashed") + 
geom_vline(aes(xintercept=1993), colour="#000000", linetype="dashed")+ 
theme_bw() + theme(text=element_text(size=20))
pdf('pcase1.pdf')
print(pcase1)
dev.off()


# Colorimetric assay of catalase doi: 10.1016/0003-2697(72)90132-7
# Levels of glutathione, glutathione reductase and glutathione S-transferase activities in rat lung and liver doi: 10.1016/0304-4165(79)90289-7
c2_1 <- fread('case2_15353270.csv') # pub_year=1972, first_time_cited=1970 (drop citation from 1970)
c2_1[pub_year==1970,pub_year:=1972] # replaces 1970 with 1972 for a single citation 
c2_2 <- fread('case2_18327389.csv') # pub_year=1979, first_time_cited-1979
c2_cc <- fread('case2_cocited.csv') # first_co_cited_year=1979
c2_cc <- c2_cc[,.(cc_year=co_cited_year,cc_frequency=frequency)]

t2 <- base::merge(c2_1,c2_2,by.x='pub_year',by.y='pub_year',all.x=T,all.y=T)
case2 <- base::merge(t2,c2_cc,by.x='pub_year',by.y='cc_year',all.x=T,all.y=T)
case2[!is.na(case2$pub_year),];
case2 <- setDT(case2)
case2 <- case2[pub_year <= 2018]
colnames(case2) <- c('pub_year','pub1','pub2','cocite')

m_case2 <- reshape::melt(case2,id='pub_year')
colnames(m_case2)[2] <- "example_2"
pcase2 <- qplot(pub_year,value,group=example_2,data=m_case2,geom=c('point','line'),xlim=c(1950,2020),
ylim=c(0,250),color=example_2,ylab="Frequency",xlab="Publication Year") + theme(text=element_text(family="Arial", size=20))
pcase2 <- pcase2 +  geom_vline(aes(xintercept=1972), colour="#000000", linetype="dashed") +
geom_vline(aes(xintercept=1979), colour="#000000", linetype="dashed") + 
geom_vline(aes(xintercept=1979), colour="#000000", linetype="dashed")+ 
theme_bw() + theme(text=element_text(size=20))

pdf('composite_samples3.pdf')
print(pcase1/pcase2)
dev.off()

system('cp composite_samples3.pdf ~/cocitation_2/R1')



