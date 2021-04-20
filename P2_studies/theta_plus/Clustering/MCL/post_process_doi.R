# updated April 2021 to handle dois instead of scps
# George Chacko

rm(list=ls())
library(data.table)
fl <- list.files(pattern='dump.*')

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
	# <- as.numeric(substring(b,2)) # commented out historical Scopus scp handling
	a <- rep(paste(i),length(b))
	global_dflist[[j]][[i]] <- data.frame(a,b,stringsAsFactors=FALSE)
	      }
}

for (i in 1:length(global_dflist)){
    x <- do.call(rbind,global_dflist[[i]])
    colnames(x) <- c('cluster_no','scp')
    fwrite(x,file=sprintf('%s.csv',names(global_dflist)[i]))
}



