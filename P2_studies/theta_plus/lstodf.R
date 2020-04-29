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
ncf_20 <- do.call(rbind,global_dflist[[1]]); fwrite(ncf_20,file="ncf_20.csv")
ncf_30 <- do.call(rbind,global_dflist[[2]]); fwrite(ncf_30,file="ncf_30.csv")
ncf_40 <- do.call(rbind,global_dflist[[3]]); fwrite(ncf_40,file="ncf_40.csv")
ncf_60 <- do.call(rbind,global_dflist[[4]]); fwrite(ncf_60,file="ncf_60.csv")1

now_20 <- do.call(rbind,global_dflist[[5]]); fwrite(now_20,file="now_20.csv")
now_30 <- do.call(rbind,global_dflist[[6]]); fwrite(now_30,file="now_30.csv")
now_40 <- do.call(rbind,global_dflist[[7]]); fwrite(now_40,file="now_40.csv")
now_60 <- do.call(rbind,global_dflist[[8]]); fwrite(now_60,file="now_60.csv")

sf_20 <- do.call(rbind,global_dflist[[9]]);  fwrite(sf_20,file="sf_20.csv")
sf_30 <- do.call(rbind,global_dflist[[10]]); fwrite(sf_30,file="sf_30.csv")
sf_40 <- do.call(rbind,global_dflist[[11]]); fwrite(sf_40,file="sf_40.csv")
sf_60 <- do.call(rbind,global_dflist[[12]]); fwrite(sf_60,file="sf_60.csv")

