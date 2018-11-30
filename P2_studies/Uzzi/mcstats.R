ucomparison <- function(df,reps,shuffles,runtime,method) {
	# perm = 1
	# swr = 2
	# 1S = 3
	# 10S =4
	
library(data.table)
df <- fread(df)

rows <- c("method","reps","shuffles","runtime (min)",
"output_rows","unique_pubs","unique_rp","unique_jp",
"clean_jp","pcnt notInf", "min z_score","max_zscore","mean_zscore",
"10th p'cntile zscore","median_zscore","Q1","Q3")	
rundata <- numeric()

rundata[1] <- method
rundata[2] <- reps
rundata[3] <- shuffles
rundata[4] <- runtime
rundata[5] <- dim(df)[1]
rundata[6] <- length(unique(df$source_id))
rundata[7] <- length(unique(df$wos_id_pairs))
rundata[8] <- length(unique(df$journal_pairs))

df2 <- unique(df[,list(journal_pairs,frequency,z_score)])
df3 <- df2[!(z_score==Inf | z_score==-Inf)]
rundata[9] <- length(unique(df3$journal_pairs))
print(rundata[8])
print(rundata[9])
rundata[10] <- round(100*(rundata[9]/rundata[8]),1)
rundata[11] <- min(df3$z_score)
rundata[12] <- max(df3$z_score)
rundata[13] <- mean(df3$z_score)
rundata[14] <-quantile(df3$z_score,0.1)
rundata[15] <-median(df3$z_score)
rundata[16] <-quantile(df3$z_score,0.25)
rundata[17] <-quantile(df3$z_score,0.75)


x <- data.frame(cbind(rows,rundata),stringsAsFactors=FALSE)
str(x)
colnames(x) <- c("parm","data")
return(x)
}