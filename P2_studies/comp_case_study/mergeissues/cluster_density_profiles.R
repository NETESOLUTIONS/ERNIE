setwd('~/Desktop/clustering')
library(data.table)
x <- fread('dblp_graclus.csv')
y10 <- x[publication=='t'][,.(count=length(source_id)),by='cluster_10']
y15 <- x[publication=='t'][,.(count=length(source_id)),by='cluster_15']
y20 <- x[publication=='t'][,.(count=length(source_id)),by='cluster_20']
y25 <- x[publication=='t'][,.(count=length(source_id)),by='cluster_25']
y30 <- x[publication=='t'][,.(count=length(source_id)),by='cluster_30']
y40 <- x[publication=='t'][,.(count=length(source_id)),by='cluster_40']
y50 <- x[publication=='t'][,.(count=length(source_id)),by='cluster_50']

pdf('graclus_density_plots.pdf')
plot(density(y10$count),ylim=c(0,6.5e-5),col="red",xlab="Cluster Size",main="Density Profile of Graclus Clusters \n
10-50")
lines(density(y20$count),col="blue")
lines(density(y30$count),col="green")
lines(density(y40$count),col="brown")
lines(density(y50$count),col="black")
legend("topright", inset=.02, title="Number of Clusters",legend=c("10", "20","30","40","50"),
col=c("red", "blue","green","brown","black"), lty=1:2, cex=0.8)
dev.off()

pdf('graclus_density_plots_zoom.pdf')
plot(density(y15$count),ylim=c(0,6.5e-5),col="red",xlab="Cluster Size",main="Density Profile of Graclus Clusters \n
15-30")
lines(density(y20$count),col="blue")
lines(density(y25$count),col="green")
lines(density(y30$count),col="brown")
legend("topright", inset=.02, title="Number of Clusters",legend=c("15", "20","25","30"),
col=c("red", "blue","green","brown"), lty=1:2, cex=0.8)
dev.off()