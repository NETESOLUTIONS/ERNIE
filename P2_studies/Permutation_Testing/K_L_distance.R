# calculates K-L distance using the seewave library
setwd('~/Desktop/Fig1')
rm(list=ls())
library(data.table)
library(seewave)
imm95_wos95_jp <- fread('imm95_wos95_jp.csv')
imm95_wos95_jp <- imm95_wos95_jp[complete.cases(imm95_wos95_jp)]

imm95_probs <- imm95_wos95_jp[,.(journal_pairs,p_emp_imm=obs_frequency_imm/sum(obs_frequency_imm),
p_sim_imm=mean_imm/sum(mean_imm),
p_emp_wos=obs_frequency_wos/sum(obs_frequency_wos),
p_sim_wos=mean_wos/sum(mean_wos))]

# K-L distance for imm95
kl.dist(imm95_probs$p_emp_imm,imm95_probs$p_sim_imm,base = 2)
# K-L distance for corresponding wos95 (same journal pairs)
kl.dist(imm95_probs$p_emp_wos,imm95_probs$p_sim_wos,base = 2)