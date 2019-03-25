# calculates K-L distance using the seewave library
# Used on the 'ernie3' temp server (120 Gb RAM, Centos 7.4)
setwd "/erniedev_data1/Misc_Calculations"
rm(list = ls())
library(data.table); library(seewave)

colsToKeep <- c("journal_pairs", "obs_frequency", "mean", "z_scores")

## Year 2005

#wos
wos2005_jp <- fread("spark1000_2005_permute.csv", header = TRUE, 
	select = colsToKeep, verbose = TRUE)
wos2005_jp <- unique(wos2005_jp)
wos2005_jp[, `:=`(jp_clean = gsub("\\(|\\)", "", journal_pairs))]
wos2005_jp[, `:=`(journal_pairs, NULL)]
wos2005_jp <- wos2005_jp[, .(journal_pairs = jp_clean, obs_frequency, mean, z_scores)]
wos2005_jp <- wos2005_jp[!z_scores == Inf]
wos2005_jp <- wos2005_jp[!z_scores == -Inf]

#ap
ap2005_jp <- fread("dataset_ap2005_permute.csv", header = TRUE, select = colsToKeep, verbose = TRUE)
ap2005_jp <- unique(ap2005_jp)
ap2005_jp[, `:=`(jp_clean = gsub("\\(|\\)", "", journal_pairs))]
ap2005_jp[, `:=`(journal_pairs, NULL)]
ap2005_jp <- ap2005_jp[, .(journal_pairs = jp_clean, obs_frequency, mean, z_scores)]
ap2005_jp <- ap2005_jp[!z_scores == Inf]
ap2005_jp <- ap2005_jp[!z_scores == -Inf]

#imm
imm2005_jp <- fread("dataset_imm2005_permute.csv", header = TRUE, select = colsToKeep, verbose = TRUE)
imm2005_jp <- unique(imm2005_jp)
imm2005_jp[, `:=`(jp_clean = gsub("\\(|\\)", "", journal_pairs))]
imm2005_jp[, `:=`(journal_pairs, NULL)]
imm2005_jp <- imm2005_jp[, .(journal_pairs = jp_clean, obs_frequency, mean, z_scores)]
imm2005_jp <- imm2005_jp[!z_scores == Inf]
imm2005_jp <- imm2005_jp[!z_scores == -Inf]

#metab
metab2005_jp <- fread("dataset_metab2005_permute.csv", header = TRUE, select = colsToKeep, verbose = TRUE)
metab2005_jp <- unique(metab2005_jp)
metab2005_jp[, `:=`(jp_clean = gsub("\\(|\\)", "", journal_pairs))]
metab2005_jp[, `:=`(journal_pairs, NULL)]
metab2005_jp <- metab2005_jp[, .(journal_pairs = jp_clean, obs_frequency, mean, z_scores)]
metab2005_jp <- metab2005_jp[!z_scores == Inf]
metab2005_jp <- metab2005_jp[!z_scores == -Inf]

ap_wos_2005_jp <- merge(ap2005_jp,wos2005_jp,by.x='journal_pairs',by.y='journal_pairs')
colnames(ap_wos_2005_jp) <- c('journal_pairs','obs_frequency_ap','mean_ap','z_scores_ap','obs_frequency_wos','mean_wos','z_scores_wos')

imm_wos_2005_jp <- merge(imm2005_jp,wos2005_jp,by.x='journal_pairs',by.y='journal_pairs')
colnames(imm_wos_2005_jp) <- c('journal_pairs','obs_frequency_imm','mean_imm','z_scores_imm','obs_frequency_wos','mean_wos','z_scores_wos')

metab_wos_2005_jp <- merge(metab2005_jp,wos2005_jp,by.x='journal_pairs',by.y='journal_pairs')
colnames(metab_wos_2005_jp) <- c('journal_pairs','obs_frequency_metab','mean_metab','z_scores_metab','obs_frequency_wos','mean_wos','z_scores_wos')

ap_wos_2005_jp <- ap_wos_2005_jp[complete.cases(ap_wos_2005_jp)]
imm_wos_2005_jp <- imm_wos_2005_jp[complete.cases(imm_wos_2005_jp)]
metab_wos_2005_jp <- metab_wos_2005_jp[complete.cases(metab_wos_2005_jp)]

#K-L ap
ap2005_probs <- ap_wos_2005_jp[, .(journal_pairs, p_emp_ap = obs_frequency_ap/sum(obs_frequency_ap), 
  p_sim_ap = mean_ap/sum(mean_ap), 
  p_emp_wos = obs_frequency_wos/sum(obs_frequency_wos), 
  p_sim_wos = mean_wos/sum(mean_wos))] 
# K-L distance for ap2005
kl.dist(ap2005_probs$p_emp_ap, ap2005_probs$p_sim_ap, base = 2)
# K-L distance for corresponding wos2005 (same journal pairs)
kl.dist(ap2005_probs$p_emp_wos, ap2005_probs$p_sim_wos, base = 2)

#K-L imm
imm2005_probs <- imm_wos_2005_jp[, .(journal_pairs, p_emp_imm = obs_frequency_imm/sum(obs_frequency_imm), 
  p_sim_imm = mean_imm/sum(mean_imm), 
  p_emp_wos = obs_frequency_wos/sum(obs_frequency_wos), 
  p_sim_wos = mean_wos/sum(mean_wos))]
kl.dist(imm2005_probs$p_emp_imm, imm2005_probs$p_sim_imm, base = 2)
# K-L distance for corresponding wos2005 (same journal pairs)
kl.dist(imm2005_probs$p_emp_wos, imm2005_probs$p_sim_wos, base = 2)

#K-L metab
metab2005_probs <- metab_wos_2005_jp[, .(journal_pairs, p_emp_metab = obs_frequency_metab/sum(obs_frequency_metab), 
  p_sim_metab = mean_metab/sum(mean_metab), 
  p_emp_wos = obs_frequency_wos/sum(obs_frequency_wos), 
  p_sim_wos = mean_wos/sum(mean_wos))]
kl.dist(metab2005_probs$p_emp_metab, metab2005_probs$p_sim_metab, base = 2)
# K-L distance for corresponding wos2005 (same journal pairs)
kl.dist(metab2005_probs$p_emp_wos, metab2005_probs$p_sim_wos, base = 2)






library(seewave)



