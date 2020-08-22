rm(list = ls())
setwd("~/Desktop/theta_plus/")
library(data.table)
library(ggplot2)
x <- fread("~/Desktop/theta_plus/imm1985_1995_author_tiers.csv")
dim(x)
x <- x[complete.cases(x)]
dim(x)

x[num_clusters_int_edges >= 100, `:=`(gp, 1)]
x[num_clusters_int_edges >= 10 & num_clusters_int_edges < 100, `:=`(gp, 2)]
x[num_clusters_int_edges < 10, `:=`(gp, 3)]

x[order(-gp, -num_clusters_int_edges)][tier_1 + tier_2 > tier_3, head(.SD, 10), by = "gp"][order(gp, -total_num_clusters)]

x[, .N, by = "gp"]

p1 <- plot(x$total_num_clusters, log = "x", type = "h", lwd = 1, lend = 1, ylab = "num_clusters_per_author", xlab = "count_authors")

xq_90 <- x[, .(quantile(tier_1, 0.9), quantile(tier_2, 0.9), quantile(tier_3, 0.9)), by = "gp"]
mxq_90 <- melt(xq_90, id = "gp")
mxq_90[variable == "V1", `:=`(variable, "tier_1")]
mxq_90[variable == "V2", `:=`(variable, "tier_2")]
mxq_90[variable == "V3", `:=`(variable, "tier_3")]
colnames(mxq_90)[2] <- "tier"

p2 <- ggplot(mxq_90, aes(fill = tier, y = value, x = gp)) + 
geom_bar(position = "dodge", stat = "identity") + 
ylim(0, 200) +
labs(y = "90th percentile", x = "gp") + 
theme_bw()

head <- x[order(-tier_1, -tier_2, -tier_3)][, head(.SD, 100), by = "gp"]
head_90 <- head[, .(quantile(tier_1, 0.9), quantile(tier_2, 0.9), quantile(tier_3, 0.9)), by = "gp"]
mh_90 <- melt(head_90, id = "gp")
mh_90[variable == "V1", `:=`(variable, "tier_1")]
mh_90[variable == "V2", `:=`(variable, "tier_2")]
mh_90[variable == "V3", `:=`(variable, "tier_3")]
colnames(mh_90)[2] <- "tier"
p3 <- ggplot(mh_90, aes(fill = tier, y = value, x = gp)) + 
geom_bar(position = "dodge", stat = "identity") + 
labs(y = "top 100 authors", x = "gp") + 
ylim(0, 200) + theme_bw() + theme(legend.position = "none")

tail <- x[order(-tier_1, -tier_2, -tier_3)][, tail(.SD, 100), by = "gp"]
tail_90 <- tail[, .(quantile(tier_1, 0.9), quantile(tier_2, 0.9), quantile(tier_3, 0.9)), by = "gp"]
mt_90 <- melt(tail_90, id = "gp")
mt_90[variable == "V1", `:=`(variable, "tier_1")]
mt_90[variable == "V2", `:=`(variable, "tier_2")]
mt_90[variable == "V3", `:=`(variable, "tier_3")]
colnames(mt_90)[2] <- "tier"
p4 <- ggplot(mt_90, aes(fill = tier, y = value, x = gp)) + 
geom_bar(position = "dodge", stat = "identity") + 
labs(y = "bottom 100 authors", x = "gp") + 
ylim(0, 200) + theme_bw() + theme(legend.position = "none")

p5 <- p2 | (p3/p4)

setwd('~/ERNIE_tp/tpp/')
pdf('p1.pdf')
plot(x$total_num_clusters, log = "x", type = "h", 
lwd = 1, lend = 1, ylab = "num_clusters_per_author", 
xlab = "count_authors",col="darkgray")
dev.off()

pdf('p5.pdf')
print(p5)
dev.off()

