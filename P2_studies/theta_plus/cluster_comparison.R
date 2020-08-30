# script to generate a frequency distribution ytable to compare two clusterings
# by MCL and Graclus July 15, 2020 George Chacko

library(data.table); library(RPostgres); library(bit64); library(ggplot2); library(hrbrthemes)
library(extrafont); loadfonts()

# after setting up tunnel to our server execute the following line after substituting 
# username and passsword for XX and YY

con <- dbConnect(RPostgres::Postgres(), host="localhost", dbname="ernie", user="XX", password="YY")

# get table of scps group by MCL cluster from the imm1985 dataset
mclustering <- dbGetQuery(con, "select cluster_no,count(scp) from imm1985_cluster_scp_list_unshuffled group by cluster_no;")

# get table of scps group by Graclus cluster from the imm1985 dataset
grac_2391 <- dbGetQuery(con, "select cluster_no,count(scp) from imm1985_cluster_scp_list_graclus group by cluster_no;")

grac_5284 <- dbGetQuery(con, "select cluster_no,count(scp) from imm1985_cluster_scp_list_graclus_half_mclsize group by cluster_no;")

grac_7926 <- dbGetQuery(con, "select cluster_no,count(scp) from imm1985_cluster_scp_list_graclus_75_mclsize group by cluster_no;")

grac_10568 <- dbGetQuery(con, "select cluster_no,count(scp) from imm1985_cluster_scp_list_graclus_mclsize  group by cluster_no;") 

# R doesn't always handle integer64 type well so convert to numeric.
setDT(mclustering); mclustering[,gp:="mcl"]; mclustering[,cluster_no:=NULL]
setDT(grac_2391); grac_2391[,gp:="grac_2391"]; grac_2391[,cluster_no:=NULL]
setDT(grac_5284); grac_5284[,gp:="grac_5284"]; grac_5284[,cluster_no:=NULL]
setDT(grac_7926); grac_7926[,gp:="grac_7926"]; grac_7926[,cluster_no:=NULL]
setDT(grac_10568); grac_10568[,gp:="grac_10568"]; grac_10568[,cluster_no:=NULL]
combined_grac <- rbind(grac_10568,grac_7926,grac_5284,grac_2391)
colnames(combined_grac) <- c("cluster_size","gp")
combined_grac$cluster_size <- as.numeric(combined_grac$cluster_size)
combined_grac$gp <- factor(combined_grac$gp,levels=c('grac_10568','grac_7926','grac_5284','grac_2391'))

p <- ggplot(combined_grac[cluster_size < 325], aes(x=cluster_size, fill=gp)) +
     geom_histogram(,binwidth=10, color="#e9ecef", alpha=0.8, position = 'identity') +
     scale_fill_manual(values=c("#DF536B", "#61D04F", "#2297E6", "#28E2E5")) +
     theme_bw() +
     labs(fill="") + 
     facet_wrap(~gp) +
     theme(legend.position="none") + ylim(0,10000)
     
pdf("combined_grac.pdf")
print(p)
dev.off()

mcl_grac <- rbind(mclustering,grac_5284)
colnames(mcl_grac) <- c("cluster_size","gp")
mcl_grac$cluster_size <- as.numeric(mcl_grac$cluster_size)
mcl_grac$gp <- factor(mcl_grac$gp,levels=c('mcl','grac_5284'))

q <- ggplot(mcl_grac[cluster_size < 325], aes(x=cluster_size, fill=gp)) +
     geom_histogram(,binwidth=10, color="#e9ecef", alpha=0.8, position = 'identity') +
     scale_fill_manual(values=c("#F5C710", "#2297E6")) +
     theme_bw() +
     labs(fill="") + 
     facet_wrap(~gp) +
     theme(legend.position="none") + ylim(0,10000)

library(patchwork)
pq <- p/q

pdf('fig2.pdf')
print(pq)
dev.off()
system('cp fig2.pdf ~/ERNIE_tp/')

dbDisconnect(con);
