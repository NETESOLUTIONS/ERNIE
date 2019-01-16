# permute_to_medians script
# 1/16/2019 takes a *_permute.csv file from Jenkins and 
# generates a *_zsc_med.csv file on ernie1
# Handles blast_95, blast_2000, blast_2005, keyword_search_95, 
# and max_cocit_search_95 data

# On Server
library(data.table)

# BLAST_95 data
# blast_95
setwd("/erniedev_data10/P2_studies/data_slices/blast/blast_1995")
bl_1995 <- fread("blast_analysis_gen1_1995_permute.csv")
bl_95 <- bl_1995[, .(source_id, z_scores)]
bl_95 <- bl_95[!z_scores == Inf]
bl_95 <- bl_95[!z_scores == Inf]
bl95_zsc_med <- bl_95[, .(med = median(z_scores), ten = quantile(z_scores, 0.1), 
	one = quantile(z_scores, 0.01)), by = "source_id"]
fwrite(bl95_zsc_med, file = "bl95_zsc_med.csv", row.names = FALSE)
# nb_blast95
setwd("/erniedev_data10/P2_studies/data_slices/blast/blast_1995")
nbl_1995 <- fread("nb_blast_analysis_gen1_1995_permute.csv")
nbl_95 <- nbl_1995[, .(source_id, z_scores)]
nbl_95 <- nbl_1995[, .(source_id, z_scores)]
nbl_95 <- nbl_95[!z_scores == Inf]
nbl_95 <- nbl_95[!z_scores == -Inf]
nbl95_zsc_med <- nbl_95[, .(med = median(z_scores), ten = quantile(z_scores, 0.1), 
	one = quantile(z_scores, 0.01)), by = "source_id"]
fwrite(nbl95_zsc_med, file = "nbl95_zsc_med.csv", row.names = FALSE)

#BLAST_2000 data
# blast_2000
setwd("/erniedev_data10/P2_studies/data_slices/blast/blast_2000")
nbl_2000 <- fread("nb_blast_analysis_gen1_2000_permute.csv")
nbl_20 <- nbl_2000[, .(source_id, z_scores)]
nbl_20 <- nbl_20[!z_scores == Inf]
nbl_20 <- nbl_20[!z_scores == -Inf]
nbl20_zsc_med <- nbl_20[, .(med = median(z_scores), ten = quantile(z_scores, 0.1), 
	one = quantile(z_scores, 0.01)), by = "source_id"]
fwrite(nbl20_zsc_med, file = "nbl20_zsc_med.csv", row.names = FALSE)
# nb_blast_2000
setwd("/erniedev_data10/P2_studies/data_slices/blast/blast_2000")
bl_2000 <- fread("blast_analysis_gen1_2000_permute.csv")
bl_20 <- bl_2000[, .(source_id, z_scores)]
bl_20 <- bl_20[!z_scores == Inf]
bl_20 <- bl_20[!z_scores == -Inf]
bl20_zsc_med <- bl_20[, .(med = median(z_scores), ten = quantile(z_scores, 0.1), 
	one = quantile(z_scores, 0.01)), by = "source_id"]
fwrite(bl20_zsc_med, file = "bl20_zsc_med.csv", row.names = FALSE)

# BLAST_2005 data
#blast_2005
setwd("/erniedev_data10/P2_studies/data_slices/blast/blast_2005")
bl_2005 <- fread("blast_analysis_gen1_2005_permute.csv")
bl_25 <- bl_2005[, .(source_id, z_scores)]
bl_25 <- bl_25[!z_scores == Inf]
bl_25 <- bl_25[!z_scores == -Inf]
bl25_zsc_med <- bl_25[, .(med = median(z_scores), ten = quantile(z_scores, 0.1), 
	one = quantile(z_scores, 0.01)), by = "source_id"]
fwrite(bl25_zsc_med, file = "bl25_zsc_med.csv", row.names = FALSE)
#nb_blast_2005
setwd("/erniedev_data10/P2_studies/data_slices/blast/blast_2005")
nbl_2005 <- fread("/erniedev_data10/P2_studies/data_slices/blast/blast_2005/nb_blast_analysis_gen1_2005_permute.csv")
nbl_25 <- nbl_2005[, .(source_id, z_scores)]
nbl_25 <- nbl_25[!z_scores == Inf]
nbl_25 <- nbl_25[!z_scores == -Inf]
nbl25_zsc_med <- nbl_25[, .(med = median(z_scores), ten = quantile(z_scores, 0.1), 
	one = quantile(z_scores, 0.01)), by = "source_id"]
fwrite(nbl25_zsc_med, file = "nbl25_zsc_med.csv", row.names = FALSE)

#KEYWORD_SEARCH data
# keyword_search_95
setwd("/erniedev_data10/P2_studies/data_slices/keyword_search")
ks_1995 <- fread("/erniedev_data10/P2_studies/data_slices/keyword_search/ks_cd3_1995_permute.csv")
ks_95 <- ks_1995[,.(source_id,z_scores)]
ks_95 <- ks_95[!z_scores==Inf]
ks_95 <- ks_95[!z_scores==-Inf]
ks95_zsc_med <- ks_95[, .(med = median(z_scores), ten = quantile(z_scores, 0.1), 
	one = quantile(z_scores, 0.01)), by = "source_id"]
fwrite(ks95_zsc_med, file = "ks95_zsc_med.csv", row.names = FALSE)

# MAX_COCIT_SEARCH DATA
#cs_1995
setwd("/erniedev_data10/P2_studies/data_slices/cocit_search")
cs_1995 <- fread("/erniedev_data10/P2_studies/data_slices/cocit_search/max_cocit_1995_permute.csv")
cs_95 <- cs_1995[, .(source_id, z_scores)]
cs_95 <- cs_95[!z_scores == Inf]
cs_95 <- cs_95[!z_scores == -Inf]
cs95_zsc_med <- cs_95[, .(med = median(z_scores), ten = quantile(z_scores, 0.1), one = quantile(z_scores, 0.01)), by = "source_id"]
fwrite(cs95_zsc_med, file = "cs95_zsc_med.csv", row.names = FALSE)

#nm_cs_1995
setwd("/erniedev_data10/P2_studies/data_slices/cocit_search")
nm_cs_1995 <- fread("/erniedev_data10/P2_studies/data_slices/cocit_search/nm_max_cocit_1995_permute.csv")
nm_cs_95 <- nm_cs_1995[,.(source_id,z_scores)]
nm_cs_95 <- nm_cs_95[!z_scores==Inf]
nm_cs_95 <- nm_cs_95[!z_scores==-Inf]
nm_s95_zsc_med <- nm_cs_95[, .(med = median(z_scores), ten = quantile(z_scores, 0.1), 
	one = quantile(z_scores, 0.01)), by = "source_id"]
fwrite(nm_s95_zsc_med, file = "nm_s95_zsc_med.csv", row.names = FALSE)