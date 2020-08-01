args <- commandArgs(trailingOnly=TRUE)
filename <- (args[2])
print(filename)
library(data.table);
x <- fread(filename)
print(dim(x))
x$citing <- paste0('a',x$citing)
x$cited <- paste0('a',x$cited)
filename <- gsub('.csv','',filename)
write.table(x, file=sprintf('%s.tsv',filename),quote=FALSE,sep='\t',row.names=FALSE,col.names=FALSE)



