rm(list=ls())
setwd('~/Desktop/cc2'); library(data.table)
x <- fread('~/Desktop/cc2/sleeping_beauty_bin1.csv')
x$cited_2 <- as.numeric(x$cited_2)
x[, `:=`(l_t, ((peak_frequency - min_frequency)/(first_peak_year-first_possible_year)) * (co_cited_year - first_possible_year) + min_frequency)]
  
# why add min_frequency if you remove it again in the next step? 
x[, `:=`(b_c, (l_t - frequency)/pmax(1, frequency))]
# remove rows where l_t or b_c is NaN (0/0))
x <- x[complete.cases(x)]
# BC calcs
final <- x[,sum(b_c),by=c('cited_1','cited_2')][order(-V1)]
# AT calcs
# d_t = ((C_tm-C_0)*t - t_mC_t + t_mC_0)/((C_tm-C_0)**2 + t_m**2)**0.5
# aka 
x[,d_t_num:=(((peak_frequency-min_frequency)*(co_cited_year - first_cited_year))-((first_peak_year-first_cited_year)*frequency) + ((first_peak_year-first_cited_year)*min_frequency))]
x[,d_t_den:=((peak_frequency-min_frequency)**2 + (first_peak_year-first_cited_year)**2)**0.5]
x[,d_t:=d_t_num/d_t_den]
final_bc_at <- x[,.(at=max(d_t),bc=sum(b_c)),by=c('cited_1','cited_2')][order(-at)]
