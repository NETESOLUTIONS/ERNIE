clean_zscores <- function(df) {
	library(data.table)
	df < data.table(df)
	df_u <- unique(df[, .(journal_pairs, obs_frequency, mean, z_scores)])
	df_u_noInf <- df_u[!z_scores==Inf]
	df_u_noInf <- df_u_noInf[!z_scores==-Inf]
return(df_u_noInf)
}


