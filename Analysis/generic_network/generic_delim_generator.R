# Take a csv file and converts it into tab delimited

print("this is a test",stdout())
t <- read.csv("/tmp/genric_final.csv",stringsAsFactors=FALSE)
library(caroline)
write.delim(t,file="/tmp/generic_final_delim.txt",row.names=FALSE,sep="\t")


