# script to generate a frequency distribution ytable to compare two clusterings
# by MCL and Graclus July 15, 2020 George Chacko

library(data.table); library(RPostgres); library(bit64); library(ggplot2); library(hrbrthemes)
library(extrafont); loadfonts()

# after setting up tunnel to our server
con <- dbConnect(RPostgres::Postgres(), host="localhost", dbname="ernie", user="XX", password="YY")

# get table of scps group by Graclus cluster from the imm1985 dataset
gclustering <- dbGetQuery(con, "select cluster_no,count(scp) from imm1985_cluster_scp_list_graclus group by cluster_no;")
# get table of scps group by MCL cluster from the imm1985 dataset
mclustering <- dbGetQuery(con, "select cluster_no,count(scp) from imm1985_cluster_scp_list_unshuffled group by cluster_no;")

# R doesn't always handle integer64 type well so convert to numeric.

setDT(gclustering); gclustering[,gp:="graclus"]; gclustering[,cluster_no:=NULL]
setDT(mclustering); mclustering[,gp:="mcl"]; mclustering[,cluster_no:=NULL]
combined_clustering <- rbind(gclustering,mclustering)
colnames(combined_clustering) <- c("cluster_size","gp")
combined_clustering$cluster_size <- as.numeric(combined_clustering$cluster_size)

p <- ggplot(combined_clustering[cluster_size < 300], aes(x=cluster_size, fill=gp)) +
     geom_histogram(,binwidth=10, color="#e9ecef", alpha=0.6, position = 'identity') +
     scale_fill_manual(values=c("#69b3a2", "#404080")) +
     theme_ipsum() +
     labs(fill="") + 
     facet_wrap(~gp)

pdf("cluster_comparison.pdf",h=5,width=7)
print(p)
dev.off()

# manually edit to crop out irrelevant stuff

