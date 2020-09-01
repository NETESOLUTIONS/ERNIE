# Import mcx dump data for analysis in R
setwd('~/Desktop/theta_plus/top/george')
rm(list=ls()); library(data.table)
fl <- list.files()

# import file contents as text into a list
# each of these elements is a long character vector
text_list <- list()
for (i in 1:length(fl)){
text_list[[i]] <- readLines(fl[i])	
}
names(text_list) <- fl

# process each element of the list into another list using scan
# to ensure recursive processing I used a loop
cluster_list <- list()
for (i in 1:length(text_list)){
cluster_list[[i]] <- lapply(text_list[[i]], function(x) scan(text = x, what = character(), quiet = TRUE))
}

# calculate number of elements in each element of the list
length_list=list()
for (i in 1:length(cluster_list)){
length_list[[i]] <- lapply(cluster_list[[i]],length)
}

for(i in 1:length(cluster_list)){
	names(length_list)[i] <- names(text_list)[i]
}

for(i in 1:length(cluster_list)){
	names(cluster_list)[i] <- names(text_list)[i]
}
rm(i);

global_dflist <- cluster_list
for (j in 1:length(global_dflist)){
	for (i in 1:length(global_dflist[[j]])) {
		b <- unlist(global_dflist[[j]][[i]])
		b <- as.numeric(substring(b,2))
		a <- rep(paste(i),length(b))
		global_dflist[[j]][[i]] <- data.frame(a,b,stringsAsFactors=FALSE)
	}
}

setwd('/Users/george/Desktop/theta_plus/top')
ncf_20 <- do.call(rbind,global_dflist[[1]]); colnames(ncf_20) <- c('cluster_no','scp')
fwrite(ncf_20,file="ncf_20.csv")

ncf_30 <- do.call(rbind,global_dflist[[2]]); colnames(ncf_30) <- c('cluster_no','scp')
fwrite(ncf_30,file="ncf_30.csv")

ncf_40 <- do.call(rbind,global_dflist[[3]]); colnames(ncf_40) <- c('cluster_no','scp')
fwrite(ncf_40,file="ncf_40.csv")

ncf_60 <- do.call(rbind,global_dflist[[4]]); colnames(ncf_60) <- c('cluster_no','scp')
fwrite(ncf_60,file="ncf_60.csv")

now_20 <- do.call(rbind,global_dflist[[5]]); colnames(now_20) <- c('cluster_no','scp')
fwrite(now_20,file="now_20.csv")

now_30 <- do.call(rbind,global_dflist[[6]]); colnames(now_30) <- c('cluster_no','scp')
fwrite(now_30,file="now_30.csv")

now_40 <- do.call(rbind,global_dflist[[7]]); colnames(now_40) <- c('cluster_no','scp')
fwrite(now_40,file="now_40.csv")

now_60 <- do.call(rbind,global_dflist[[8]]); colnames(now_60) <- c('cluster_no','scp')
fwrite(now_60,file="now_60.csv")

sf_20 <- do.call(rbind,global_dflist[[9]]); colnames(sf_20) <- c('cluster_no','scp') 
fwrite(sf_20,file="sf_20.csv")

sf_30 <- do.call(rbind,global_dflist[[10]]); colnames(sf_30) <- c('cluster_no','scp')
fwrite(sf_30,file="sf_30.csv")

sf_40 <- do.call(rbind,global_dflist[[11]]); colnames(sf_40) <- c('cluster_no','scp')
fwrite(sf_40,file="sf_40.csv")

sf_60 <- do.call(rbind,global_dflist[[12]]); colnames(sf_60) <- c('cluster_no','scp')
fwrite(sf_60,file="sf_60.csv")

