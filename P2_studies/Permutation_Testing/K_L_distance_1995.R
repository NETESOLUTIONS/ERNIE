# calculates K-L distance using the seewave library
# Used on the 'ernie3' temp server (120 Gb RAM, Centos 7.4)
# George Chacko 3/25/2019
setwd "/erniedev_data1/Misc_Calculations"
rm(list = ls())
library(data.table); library(seewave)

colsToKeep <- c("journal_pairs", "obs_frequency", "mean", "z_scores")

## Year 1995

#wos
wos1995_jp <- fread("spark1000_1995_permute.csv", header = TRUE, 
	select = colsToKeep, verbose = TRUE)
wos1995_jp <- unique(wos1995_jp)
wos1995_jp[, `:=`(jp_clean = gsub("\\(|\\)", "", journal_pairs))]
wos1995_jp[, `:=`(journal_pairs, NULL)]
wos1995_jp <- wos1995_jp[, .(journal_pairs = jp_clean, obs_frequency, mean, z_scores)]
wos1995_jp <- wos1995_jp[!z_scores == Inf]
wos1995_jp <- wos1995_jp[!z_scores == -Inf]

#ap
ap1995_jp <- fread("dataset_ap1995_permute.csv", header = TRUE, select = colsToKeep, verbose = TRUE)
ap1995_jp <- unique(ap1995_jp)
ap1995_jp[, `:=`(jp_clean = gsub("\\(|\\)", "", journal_pairs))]
ap1995_jp[, `:=`(journal_pairs, NULL)]
ap1995_jp <- ap1995_jp[, .(journal_pairs = jp_clean, obs_frequency, mean, z_scores)]
ap1995_jp <- ap1995_jp[!z_scores == Inf]
ap1995_jp <- ap1995_jp[!z_scores == -Inf]

#imm
imm1995_jp <- fread("dataset_imm1995_permute.csv", header = TRUE, select = colsToKeep, verbose = TRUE)
imm1995_jp <- unique(imm1995_jp)
imm1995_jp[, `:=`(jp_clean = gsub("\\(|\\)", "", journal_pairs))]
imm1995_jp[, `:=`(journal_pairs, NULL)]
imm1995_jp <- imm1995_jp[, .(journal_pairs = jp_clean, obs_frequency, mean, z_scores)]
imm1995_jp <- imm1995_jp[!z_scores == Inf]
imm1995_jp <- imm1995_jp[!z_scores == -Inf]

#metab
metab1995_jp <- fread("dataset_metab1995_permute.csv", header = TRUE, select = colsToKeep, verbose = TRUE)
metab1995_jp <- unique(metab1995_jp)
metab1995_jp[, `:=`(jp_clean = gsub("\\(|\\)", "", journal_pairs))]
metab1995_jp[, `:=`(journal_pairs, NULL)]
metab1995_jp <- metab1995_jp[, .(journal_pairs = jp_clean, obs_frequency, mean, z_scores)]
metab1995_jp <- metab1995_jp[!z_scores == Inf]
metab1995_jp <- metab1995_jp[!z_scores == -Inf]

ap_wos_1995_jp <- merge(ap1995_jp,wos1995_jp,by.x='journal_pairs',by.y='journal_pairs')
colnames(ap_wos_1995_jp) <- c('journal_pairs','obs_frequency_ap','mean_ap','z_scores_ap','obs_frequency_wos','mean_wos','z_scores_wos')

imm_wos_1995_jp <- merge(imm1995_jp,wos1995_jp,by.x='journal_pairs',by.y='journal_pairs')
colnames(imm_wos_1995_jp) <- c('journal_pairs','obs_frequency_imm','mean_imm','z_scores_imm','obs_frequency_wos','mean_wos','z_scores_wos')

metab_wos_1995_jp <- merge(metab1995_jp,wos1995_jp,by.x='journal_pairs',by.y='journal_pairs')
colnames(metab_wos_1995_jp) <- c('journal_pairs','obs_frequency_metab','mean_metab','z_scores_metab','obs_frequency_wos','mean_wos','z_scores_wos')

ap_wos_1995_jp <- ap_wos_1995_jp[complete.cases(ap_wos_1995_jp)]
imm_wos_1995_jp <- imm_wos_1995_jp[complete.cases(imm_wos_1995_jp)]
metab_wos_1995_jp <- metab_wos_1995_jp[complete.cases(metab_wos_1995_jp)]

#K-L ap
ap1995_probs <- ap_wos_1995_jp[, .(journal_pairs, p_emp_ap = obs_frequency_ap/sum(obs_frequency_ap), 
  p_sim_ap = mean_ap/sum(mean_ap), 
  p_emp_wos = obs_frequency_wos/sum(obs_frequency_wos), 
  p_sim_wos = mean_wos/sum(mean_wos))] 
# K-L distance for ap1995
kl.dist(ap1995_probs$p_emp_ap, ap1995_probs$p_sim_ap, base = 2)
# K-L distance for corresponding wos1995 (same journal pairs)
kl.dist(ap1995_probs$p_emp_wos, ap1995_probs$p_sim_wos, base = 2)

#K-L imm
imm1995_probs <- imm_wos_1995_jp[, .(journal_pairs, p_emp_imm = obs_frequency_imm/sum(obs_frequency_imm), 
  p_sim_imm = mean_imm/sum(mean_imm), 
  p_emp_wos = obs_frequency_wos/sum(obs_frequency_wos), 
  p_sim_wos = mean_wos/sum(mean_wos))]
kl.dist(imm1995_probs$p_emp_imm, imm1995_probs$p_sim_imm, base = 2)
# K-L distance for corresponding wos1995 (same journal pairs)
kl.dist(imm1995_probs$p_emp_wos, imm1995_probs$p_sim_wos, base = 2)

#K-L metab
metab1995_probs <- metab_wos_1995_jp[, .(journal_pairs, p_emp_metab = obs_frequency_metab/sum(obs_frequency_metab), 
  p_sim_metab = mean_metab/sum(mean_metab), 
  p_emp_wos = obs_frequency_wos/sum(obs_frequency_wos), 
  p_sim_wos = mean_wos/sum(mean_wos))]
kl.dist(metab1995_probs$p_emp_metab, metab1995_probs$p_sim_metab, base = 2)
# K-L distance for corresponding wos1995 (same journal pairs)
kl.dist(metab1995_probs$p_emp_wos, metab1995_probs$p_sim_wos, base = 2)





