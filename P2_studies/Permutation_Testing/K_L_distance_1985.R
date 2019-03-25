# calculates K-L distance using the seewave library
# Used on the 'ernie3' temp server (120 Gb RAM, Centos 7.4)
# George Chacko 3/25/2019
setwd "/erniedev_data1/Misc_Calculations"
rm(list = ls())
library(data.table); library(seewave)

colsToKeep <- c("journal_pairs", "obs_frequency", "mean", "z_scores")

## Year 1985

#wos
wos1985_jp <- fread("spark1000_1985_permute.csv", header = TRUE, 
	select = colsToKeep, verbose = TRUE)
wos1985_jp <- unique(wos1985_jp)
wos1985_jp[, `:=`(jp_clean = gsub("\\(|\\)", "", journal_pairs))]
wos1985_jp[, `:=`(journal_pairs, NULL)]
wos1985_jp <- wos1985_jp[, .(journal_pairs = jp_clean, obs_frequency, mean, z_scores)]
wos1985_jp <- wos1985_jp[!z_scores == Inf]
wos1985_jp <- wos1985_jp[!z_scores == -Inf]

#ap
ap1985_jp <- fread("dataset_ap1985_permute.csv", header = TRUE, select = colsToKeep, verbose = TRUE)
ap1985_jp <- unique(ap1985_jp)
ap1985_jp[, `:=`(jp_clean = gsub("\\(|\\)", "", journal_pairs))]
ap1985_jp[, `:=`(journal_pairs, NULL)]
ap1985_jp <- ap1985_jp[, .(journal_pairs = jp_clean, obs_frequency, mean, z_scores)]
ap1985_jp <- ap1985_jp[!z_scores == Inf]
ap1985_jp <- ap1985_jp[!z_scores == -Inf]

#imm
imm1985_jp <- fread("dataset_imm1985_permute.csv", header = TRUE, select = colsToKeep, verbose = TRUE)
imm1985_jp <- unique(imm1985_jp)
imm1985_jp[, `:=`(jp_clean = gsub("\\(|\\)", "", journal_pairs))]
imm1985_jp[, `:=`(journal_pairs, NULL)]
imm1985_jp <- imm1985_jp[, .(journal_pairs = jp_clean, obs_frequency, mean, z_scores)]
imm1985_jp <- imm1985_jp[!z_scores == Inf]
imm1985_jp <- imm1985_jp[!z_scores == -Inf]

#metab
metab1985_jp <- fread("dataset_metab1985_permute.csv", header = TRUE, select = colsToKeep, verbose = TRUE)
metab1985_jp <- unique(metab1985_jp)
metab1985_jp[, `:=`(jp_clean = gsub("\\(|\\)", "", journal_pairs))]
metab1985_jp[, `:=`(journal_pairs, NULL)]
metab1985_jp <- metab1985_jp[, .(journal_pairs = jp_clean, obs_frequency, mean, z_scores)]
metab1985_jp <- metab1985_jp[!z_scores == Inf]
metab1985_jp <- metab1985_jp[!z_scores == -Inf]

ap_wos_1985_jp <- merge(ap1985_jp,wos1985_jp,by.x='journal_pairs',by.y='journal_pairs')
colnames(ap_wos_1985_jp) <- c('journal_pairs','obs_frequency_ap','mean_ap','z_scores_ap','obs_frequency_wos','mean_wos','z_scores_wos')

imm_wos_1985_jp <- merge(imm1985_jp,wos1985_jp,by.x='journal_pairs',by.y='journal_pairs')
colnames(imm_wos_1985_jp) <- c('journal_pairs','obs_frequency_imm','mean_imm','z_scores_imm','obs_frequency_wos','mean_wos','z_scores_wos')

metab_wos_1985_jp <- merge(metab1985_jp,wos1985_jp,by.x='journal_pairs',by.y='journal_pairs')
colnames(metab_wos_1985_jp) <- c('journal_pairs','obs_frequency_metab','mean_metab','z_scores_metab','obs_frequency_wos','mean_wos','z_scores_wos')

ap_wos_1985_jp <- ap_wos_1985_jp[complete.cases(ap_wos_1985_jp)]
imm_wos_1985_jp <- imm_wos_1985_jp[complete.cases(imm_wos_1985_jp)]
metab_wos_1985_jp <- metab_wos_1985_jp[complete.cases(metab_wos_1985_jp)]

#K-L ap
ap1985_probs <- ap_wos_1985_jp[, .(journal_pairs, p_emp_ap = obs_frequency_ap/sum(obs_frequency_ap), 
  p_sim_ap = mean_ap/sum(mean_ap), 
  p_emp_wos = obs_frequency_wos/sum(obs_frequency_wos), 
  p_sim_wos = mean_wos/sum(mean_wos))] 
# K-L distance for ap1985
kl.dist(ap1985_probs$p_emp_ap, ap1985_probs$p_sim_ap, base = 2)
# K-L distance for corresponding wos1985 (same journal pairs)
kl.dist(ap1985_probs$p_emp_wos, ap1985_probs$p_sim_wos, base = 2)

#K-L imm
imm1985_probs <- imm_wos_1985_jp[, .(journal_pairs, p_emp_imm = obs_frequency_imm/sum(obs_frequency_imm), 
  p_sim_imm = mean_imm/sum(mean_imm), 
  p_emp_wos = obs_frequency_wos/sum(obs_frequency_wos), 
  p_sim_wos = mean_wos/sum(mean_wos))]
kl.dist(imm1985_probs$p_emp_imm, imm1985_probs$p_sim_imm, base = 2)
# K-L distance for corresponding wos1985 (same journal pairs)
kl.dist(imm1985_probs$p_emp_wos, imm1985_probs$p_sim_wos, base = 2)

#K-L metab
metab1985_probs <- metab_wos_1985_jp[, .(journal_pairs, p_emp_metab = obs_frequency_metab/sum(obs_frequency_metab), 
  p_sim_metab = mean_metab/sum(mean_metab), 
  p_emp_wos = obs_frequency_wos/sum(obs_frequency_wos), 
  p_sim_wos = mean_wos/sum(mean_wos))]
kl.dist(metab1985_probs$p_emp_metab, metab1985_probs$p_sim_metab, base = 2)
# K-L distance for corresponding wos1985 (same journal pairs)
kl.dist(metab1985_probs$p_emp_wos, metab1985_probs$p_sim_wos, base = 2)





