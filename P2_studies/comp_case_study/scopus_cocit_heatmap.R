# script for 2-panel co-citation heatmap
# in S&B paper

rm(list = ls())
library(data.table)
library(ggplot2)
setwd("~/Desktop/dblp")
x <- fread("cocit_heatmap_data.csv")

# Commented out lines below are from the direct citation plot in this paper. 
# reduce to columns of interest
#x1 <- x[,.(cluster_no,source_id,class_code,minor_subject_area)]
# pub counts per msa
#x2 <- x1[,.(length(source_id)),by=c('cluster_no','minor_subject_area')]
# for normalizing counts to each cluster
x3 <- x[, .(total_pubs = sum(count)), by = "cluster_no"]
# merging x2 and x3
x4 <- merge(x, x3, by.x = "cluster_no", by.y = "cluster_no")
# reduce x4 to those msas of at least 15%.
x4 <- x4[, `:=`(perc, round(100 * count/total_pubs))]
x4 <- x4[perc >= 15][, .(cluster_no, minor_subject_area, perc)]
x4$cluster_no <- factor(x4$cluster_no, levels = ordered(unique(x4$cluster_no)))
# set perc cutoff at >= 15%
p1 <- qplot(as.factor(cluster_no), minor_subject_area, data = x4) + 
geom_tile(aes(fill = perc)) + 
scale_fill_gradient2(low = "grey", high = "black", guide = "colorbar") + 
#ggtitle("15% Cluster Count Cutoff") + 
xlab("Cluster ID") + ylab("") + 
labs(fill = "% Cluster \n Count") + 
theme(text = element_text(size = 12), axis.text.x = element_text(angle = -60, hjust = 0), axis.title.x = element_blank())
# first fig
pdf("scopus_dblp_heatmap1.pdf", h = 7.5, w = 10)
print(p1)
dev.off()
system("cp scopus_dblp_heatmap1.pdf ~/ernie_comp/Scientometrics")

# rebuild x4 set perc cutoff at >=10%
x4 <- merge(x, x3, by.x = "cluster_no", by.y = "cluster_no")
x4 <- x4[, `:=`(perc, round(100 * count/total_pubs))]
x4 <- x4[perc >= 10][, .(cluster_no, minor_subject_area, perc)]
x4$cluster_no <- factor(x4$cluster_no, levels = ordered(unique(x4$cluster_no)))
p2 <- qplot(as.factor(cluster_no), minor_subject_area, data = x4) + 
geom_tile(aes(fill = perc)) + 
scale_fill_gradient2(low = "grey", high = "black", guide = "colorbar") + 
#ggtitle("10% Cluster Count Cutoff") + 
xlab("Cluster ID") + ylab("") + 
labs(fill = "% Cluster \n Count") + 
theme(text = element_text(size = 12), axis.text.x = element_text(angle = -60, hjust = 0), axis.title.x = element_blank())

# second fig
pdf("scopus_dblp_heatmap2.pdf", h = 7.5, w = 10)
print(p2)
dev.off()
system("cp scopus_dblp_heatmap2.pdf ~/ernie_comp/Scientometrics")
library(patchwork)

# merged figures
p3 <- p1/p2
pdf("scopus_dblp_heatmap3.pdf",h = 7.5, w = 10)
print(p3)
dev.off()
system("cp scopus_dblp_heatmap3.pdf ~/ernie_comp/Scientometrics")

tiff("scopus_dblp_heatmap3.tif", res=600, compression = "lzw", height=9, width=8, units="in")
print(p3)
dev.off()
