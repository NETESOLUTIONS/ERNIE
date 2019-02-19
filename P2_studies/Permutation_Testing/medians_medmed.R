#################################
# On Desktop machine for blast_95

# Blast_95 data

bl95_zsc_med <- fread("bl95_zsc_med.csv")
d20_cit <- fread("dataset1995_cit_counts.csv")
cit_bl95 <- merge(bl95_zsc_med, d20_cit, by.x = "source_id", by.y = "source_id")
cit_bl95_90 <- cit_bl95[citation_count > quantile(cit_bl95$citation_count, 0.9)]
cit_bl95_90 <- cit_bl95_90[order(citation_count)]
fwrite(cit_bl95,file='cit_bl95.csv',row.names=FALSE)
fwrite(cit_bl95_90,file='cit_bl95_90.csv',row.names=FALSE)
cit_bl95_90_gp <- cit_bl95_90[, `:=`(gp, "x")]
interval <- floor(nrow(cit_bl95_90)/10)
x <- interval * 9 + 1
y <- nrow(cit_bl95_90_gp)

cit_bl95_90_gp$gp[1:interval] <- "gp1"
cit_bl95_90_gp$gp[interval + 1:interval] <- "gp2"
cit_bl95_90_gp$gp[interval * 2 + 1:interval] <- "gp3"
cit_bl95_90_gp$gp[interval * 3 + 1:interval] <- "gp4"
cit_bl95_90_gp$gp[interval * 4 + 1:interval] <- "gp5"
cit_bl95_90_gp$gp[interval * 5 + 1:interval] <- "gp6"
cit_bl95_90_gp$gp[interval * 6 + 1:interval] <- "gp7"
cit_bl95_90_gp$gp[interval * 7 + 1:interval] <- "gp8"
cit_bl95_90_gp$gp[interval * 8 + 1:interval] <- "gp9"
cit_bl95_90_gp$gp[x:y] <- "gp10"

cit_bl95_90_gp$gp <- factor(cit_bl95_90_gp$gp, levels = c("gp1", "gp2", "gp3", 
	"gp4", "gp5", "gp6", "gp7", "gp8", "gp9", "gp10"))
cit_bl95_90_gp <- cit_bl95_90_gp[, .(med_med = median(med), med_ten = median(ten), 
	med_one = median(one)), by = "gp"]
mcit_bl95_90_gp <- melt(cit_bl95_90_gp, id = "gp")
fwrite(mcit_bl95_90_gp,file='mcit_bl95_90_gp.csv',row.names=FALSE)
rm(x)
rm(y)
rm(interval)
qplot(gp, value, data = mcit_bl95_90_gp, facets = variable ~ .,main="bl_95")

# On Desktop machine for nb_blast95
nbl95_zsc_med <- fread("nbl95_zsc_med.csv")
d20_cit <- fread("dataset1995_cit_counts.csv")
cit_nbl95 <- merge(nbl95_zsc_med, d20_cit, by.x = "source_id", by.y = "source_id")

cit_nbl95_90 <- cit_nbl95[citation_count > quantile(cit_nbl95$citation_count, 0.9)]
cit_nbl95_90 <- cit_nbl95_90[order(citation_count)]

fwrite(cit_nbl95,file='cit_nbl95.csv',row.names=FALSE)
fwrite(cit_nbl95_90,file='cit_bl95_90.csv',row.names=FALSE)
cit_nbl95_90_gp <- cit_nbl95_90[, `:=`(gp, "x")]
interval <- floor(nrow(cit_nbl95_90)/10)
x <- interval * 9 + 1
y <- nrow(cit_nbl95_90_gp)

cit_nbl95_90_gp$gp[1:interval] <- "gp1"
cit_nbl95_90_gp$gp[interval + 1:interval] <- "gp2"
cit_nbl95_90_gp$gp[interval * 2 + 1:interval] <- "gp3"
cit_nbl95_90_gp$gp[interval * 3 + 1:interval] <- "gp4"
cit_nbl95_90_gp$gp[interval * 4 + 1:interval] <- "gp5"
cit_nbl95_90_gp$gp[interval * 5 + 1:interval] <- "gp6"
cit_nbl95_90_gp$gp[interval * 6 + 1:interval] <- "gp7"
cit_nbl95_90_gp$gp[interval * 7 + 1:interval] <- "gp8"
cit_nbl95_90_gp$gp[interval * 8 + 1:interval] <- "gp9"
cit_nbl95_90_gp$gp[x:y] <- "gp10"

cit_nbl95_90_gp$gp <- factor(cit_nbl95_90_gp$gp, levels = c("gp1", "gp2", "gp3", 
	"gp4", "gp5", "gp6", "gp7", "gp8", "gp9", "gp10"))
cit_nbl95_90_gp <- cit_nbl95_90_gp[, .(med_med = median(med), med_ten = median(ten), 
	med_one = median(one)), by = "gp"]
mcit_nbl95_90_gp <- melt(cit_nbl95_90_gp, id = "gp")
fwrite(mcit_nbl95_90_gp,file='mcit_nbl95_90_gp.csv',row.names=FALSE)
rm(x)
rm(y)
rm(interval)
qplot(gp, value, data = mcit_nbl95_90_gp, facets = variable ~ .,main="nbl95")

# blast_2000
rm(list = ls())
library(data.table)
bl20_zsc_med <- fread("bl20_zsc_med.csv")
d20_cit <- fread("dataset2000_cit_counts.csv")
cit_bl20 <- merge(bl20_zsc_med, d20_cit, by.x = "source_id", by.y = "source_id")

cit_bl20_90 <- cit_bl20[citation_count > quantile(cit_bl20$citation_count, 0.9)]
cit_bl20_90 <- cit_bl20_90[order(citation_count)]
cit_bl20_90_gp <- cit_bl20_90[, `:=`(gp, "x")]

fwrite(cit_bl20,file='cit_bl20.csv',row.names=FALSE)
fwrite(cit_bl20_90,file='cit_bl20_90.csv',row.names=FALSE)

interval <- floor(nrow(cit_bl20_90)/10)
x <- interval * 9 + 1
y <- nrow(cit_bl20_90_gp)

cit_bl20_90_gp$gp[1:interval] <- "gp1"
cit_bl20_90_gp$gp[interval + 1:interval] <- "gp2"
cit_bl20_90_gp$gp[interval * 2 + 1:interval] <- "gp3"
cit_bl20_90_gp$gp[interval * 3 + 1:interval] <- "gp4"
cit_bl20_90_gp$gp[interval * 4 + 1:interval] <- "gp5"
cit_bl20_90_gp$gp[interval * 5 + 1:interval] <- "gp6"
cit_bl20_90_gp$gp[interval * 6 + 1:interval] <- "gp7"
cit_bl20_90_gp$gp[interval * 7 + 1:interval] <- "gp8"
cit_bl20_90_gp$gp[interval * 8 + 1:interval] <- "gp9"
cit_bl20_90_gp$gp[x:y] <- "gp10"

cit_bl20_90_gp$gp <- factor(cit_bl20_90_gp$gp, levels = c("gp1", "gp2", "gp3", 
	"gp4", "gp5", "gp6", "gp7", "gp8", "gp9", "gp10"))
cit_bl20_90_gp <- cit_bl20_90_gp[, .(med_med = median(med), med_ten = median(ten), 
	med_one = median(one)), by = "gp"]
mcit_bl20_90_gp <- melt(cit_bl20_90_gp, id = "gp")
fwrite(mcit_bl20_90_gp,file='mcit_bl20_90_gp.csv',row.names=FALSE)
rm(x)
rm(y)
rm(interval)
qplot(gp, value, data = mcit_bl20_90_gp, facets = variable ~ .,main="bl20")

# nb_blast_2000
rm(list = ls())
library(data.table)
nbl20_zsc_med <- fread("nbl20_zsc_med.csv")
d20_cit <- fread("dataset2000_cit_counts.csv")
cit_nbl20 <- merge(nbl20_zsc_med, d20_cit, by.x = "source_id", by.y = "source_id")

cit_nbl20_90 <- cit_nbl20[citation_count > quantile(cit_nbl20$citation_count, 0.9)]
cit_nbl20_90 <- cit_nbl20_90[order(citation_count)]

fwrite(cit_nbl20,file='cit_nbl20.csv',row.names=FALSE)
fwrite(cit_nbl20_90,file='cit_nbl20_90.csv',row.names=FALSE)


cit_nbl20_90_gp <- cit_nbl20_90[, `:=`(gp, "x")]
interval <- floor(nrow(cit_nbl20_90)/10)
x <- interval * 9 + 1
y <- nrow(cit_nbl20_90_gp)

cit_nbl20_90_gp$gp[1:interval] <- "gp1"
cit_nbl20_90_gp$gp[interval + 1:interval] <- "gp2"
cit_nbl20_90_gp$gp[interval * 2 + 1:interval] <- "gp3"
cit_nbl20_90_gp$gp[interval * 3 + 1:interval] <- "gp4"
cit_nbl20_90_gp$gp[interval * 4 + 1:interval] <- "gp5"
cit_nbl20_90_gp$gp[interval * 5 + 1:interval] <- "gp6"
cit_nbl20_90_gp$gp[interval * 6 + 1:interval] <- "gp7"
cit_nbl20_90_gp$gp[interval * 7 + 1:interval] <- "gp8"
cit_nbl20_90_gp$gp[interval * 8 + 1:interval] <- "gp9"
cit_nbl20_90_gp$gp[x:y] <- "gp10"

cit_nbl20_90_gp$gp <- factor(cit_nbl20_90_gp$gp, levels = c("gp1", "gp2", "gp3", 
	"gp4", "gp5", "gp6", "gp7", "gp8", "gp9", "gp10"))
cit_nbl20_90_gp <- cit_nbl20_90_gp[, .(med_med = median(med), med_ten = median(ten), 
	med_one = median(one)), by = "gp"]
mcit_nbl20_90_gp <- melt(cit_nbl20_90_gp, id = "gp")
fwrite(mcit_nbl20_90_gp,file='mcit_nbl20_90_gp.csv',row.names=FALSE)
rm(x)
rm(y)
rm(interval)
qplot(gp, value, data = mcit_nbl20_90_gp, facets = variable ~ .,main="nbl20")

# blast_2005

bl25_zsc_med <- fread("bl25_zsc_med.csv")
d25_cit <- fread("dataset2005_cit_counts.csv")
cit_bl25 <- merge(bl25_zsc_med, d25_cit, by.x ="source_id", by.y = "source_id")

cit_bl25_90 <- cit_bl25[citation_count > quantile(cit_bl25$citation_count, 0.9)]
cit_bl25_90 <- cit_bl25_90[order(citation_count)]

fwrite(cit_bl25,file='cit_bl25.csv',row.names=FALSE)
fwrite(cit_bl25_90,file='cit_bl25_90.csv',row.names=FALSE)

cit_bl25_90_gp <- cit_bl25_90[, `:=`(gp, "x")]
interval <- floor(nrow(cit_bl25_90)/10)
x <- interval * 9 + 1
y <- nrow(cit_bl25_90_gp)

cit_bl25_90_gp$gp[1:interval] <- "gp1"
cit_bl25_90_gp$gp[interval + 1:interval] <- "gp2"
cit_bl25_90_gp$gp[interval * 2 + 1:interval] <- "gp3"
cit_bl25_90_gp$gp[interval * 3 + 1:interval] <- "gp4"
cit_bl25_90_gp$gp[interval * 4 + 1:interval] <- "gp5"
cit_bl25_90_gp$gp[interval * 5 + 1:interval] <- "gp6"
cit_bl25_90_gp$gp[interval * 6 + 1:interval] <- "gp7"
cit_bl25_90_gp$gp[interval * 7 + 1:interval] <- "gp8"
cit_bl25_90_gp$gp[interval * 8 + 1:interval] <- "gp9"
cit_bl25_90_gp$gp[x:y] <- "gp10"

cit_bl25_90_gp$gp <- factor(cit_bl25_90_gp$gp, levels = c("gp1", "gp2", "gp3", 
	"gp4", "gp5", "gp6", "gp7", "gp8", "gp9", "gp10"))
cit_bl25_90_gp <- cit_bl25_90_gp[, .(med_med = median(med), med_ten = median(ten), 
	med_one = median(one)), by = "gp"]
mcit_bl25_90_gp <- melt(cit_bl25_90_gp, id = "gp")
fwrite(mcit_bl25_90_gp,file='mcit_bl25_90_gp.csv',row.names=FALSE)
rm(x)
rm(y)
rm(interval)
qplot(gp, value, data = mcit_bl25_90_gp, facets = variable ~ .,main="bl25")

# nb_blast_2005
nbl25_zsc_med <- fread("nbl25_zsc_med.csv")
d25_cit <- fread("dataset2005_cit_counts.csv")
cit_nbl25 <- merge(nbl25_zsc_med, d25_cit, by.x ="source_id", by.y = "source_id")

cit_nbl25_90 <- cit_nbl25[citation_count > quantile(cit_nbl25$citation_count, 0.9)]
cit_nbl25_90 <- cit_nbl25_90[order(citation_count)]
cit_nbl25_90_gp <- cit_nbl25_90[, `:=`(gp, "x")]

fwrite(cit_nbl25,file='cit_nbl25.csv',row.names=FALSE)
fwrite(cit_nbl25_90,file='cit_nbl25_90.csv',row.names=FALSE)


interval <- floor(nrow(cit_nbl25_90)/10)
x <- interval * 9 + 1
y <- nrow(cit_nbl25_90_gp)

cit_nbl25_90_gp$gp[1:interval] <- "gp1"
cit_nbl25_90_gp$gp[interval + 1:interval] <- "gp2"
cit_nbl25_90_gp$gp[interval * 2 + 1:interval] <- "gp3"
cit_nbl25_90_gp$gp[interval * 3 + 1:interval] <- "gp4"
cit_nbl25_90_gp$gp[interval * 4 + 1:interval] <- "gp5"
cit_nbl25_90_gp$gp[interval * 5 + 1:interval] <- "gp6"
cit_nbl25_90_gp$gp[interval * 6 + 1:interval] <- "gp7"
cit_nbl25_90_gp$gp[interval * 7 + 1:interval] <- "gp8"
cit_nbl25_90_gp$gp[interval * 8 + 1:interval] <- "gp9"
cit_nbl25_90_gp$gp[x:y] <- "gp10"

cit_nbl25_90_gp$gp <- factor(cit_nbl25_90_gp$gp, levels = c("gp1", "gp2", "gp3", 
	"gp4", "gp5", "gp6", "gp7", "gp8", "gp9", "gp10"))
cit_nbl25_90_gp <- cit_nbl25_90_gp[, .(med_med = median(med), med_ten = median(ten), 
	med_one = median(one)), by = "gp"]
mcit_nbl25_90_gp <- melt(cit_nbl25_90_gp, id = "gp")
fwrite(mcit_nbl25_90_gp,file='mcit_nbl25_90_gp.csv',row.names=FALSE)
rm(x)
rm(y)
rm(interval)
qplot(gp, value, data = mcit_nbl25_90_gp, facets = variable ~ .,main="nbl25")

# ks_95
ks95_zsc_med <- fread("ks95_zsc_med.csv")
d95_cit <- fread("dataset1995_cit_counts.csv")
cit_ks95 <- merge(ks95_zsc_med, d95_cit, by.x = "source_id", by.y = "source_id")

cit_ks95_90 <- cit_ks95[citation_count > quantile(cit_ks95$citation_count, 0.9)]
cit_ks95_90 <- cit_ks95_90[order(citation_count)]
cit_ks95_90_gp <- cit_ks95_90[, `:=`(gp, "x")]
fwrite(cit_ks95, file = "cit_ks95.csv", row.names = FALSE)
fwrite(cit_ks95_90, file = "cit_ks95_90.csv", row.names = FALSE)
interval <- floor(nrow(cit_ks95_90)/10)
x <- interval*9 + 1
y <- nrow(cit_ks95_90_gp)

cit_ks95_90_gp$gp[1:interval] <- "gp1"
cit_ks95_90_gp$gp[interval+1:interval] <- "gp2"
cit_ks95_90_gp$gp[interval * 2 + 1:interval] <- "gp3"
cit_ks95_90_gp$gp[interval * 3 + 1:interval] <- "gp4"
cit_ks95_90_gp$gp[interval * 4 + 1:interval] <- "gp5"
cit_ks95_90_gp$gp[interval * 5 + 1:interval] <- "gp6"
cit_ks95_90_gp$gp[interval * 6 + 1:interval] <- "gp7"
cit_ks95_90_gp$gp[interval * 7 + 1:interval] <- "gp8"
cit_ks95_90_gp$gp[interval * 8 + 1:interval] <- "gp9"
cit_ks95_90_gp$gp[x:y] <- "gp10"

cit_ks95_90_gp$gp <- factor(cit_ks95_90_gp$gp, levels = c("gp1", "gp2", "gp3", 
	"gp4", "gp5", "gp6", "gp7", "gp8", "gp9", "gp10"))
cit_ks95_90_gp <- cit_ks95_90_gp[, .(med_med = median(med), med_ten = median(ten), 
	med_one = median(one)), by = "gp"]
mcit_cit_ks95_90_gp <- melt(cit_ks95_90_gp, id = "gp")
fwrite(mcit_cit_ks95_90_gp, file = "mcit_cit_ks95_90_gp.csv", row.names = FALSE)
rm(x)
rm(y)
rm(interval)
qplot(gp, value, data = mcit_cit_ks95_90_gp, facets = variable ~ ., main = "ks25")

# cocit_95
cs95_zsc_med <- fread("cs95_zsc_med.csv")
d95_cit <- fread("dataset1995_cit_counts.csv")
cit_cs95 <- merge(cs95_zsc_med, d95_cit, by.x = "source_id", by.y = "source_id")

cit_cs95_90 <- cit_cs95[citation_count > quantile(cit_ks95$citation_count, 0.9)]
cit_cs95_90 <- cit_cs95_90[order(citation_count)]
cit_cs95_90_gp <- cit_cs95_90[, `:=`(gp, "x")]
fwrite(cit_cs95, file = "cit_cs95.csv", row.names = FALSE)
fwrite(cit_cs95_90, file = "cit_cs95_90.csv", row.names = FALSE)
interval <- floor(nrow(cit_cs95_90)/10)
x <- interval * 9 + 1
y <- nrow(cit_cs95_90_gp)

cit_cs95_90_gp$gp[1:interval] <- "gp1"
cit_cs95_90_gp$gp[interval + 1:interval] <- "gp2"
cit_cs95_90_gp$gp[interval * 2 + 1:interval] <- "gp3"
cit_cs95_90_gp$gp[interval * 3 + 1:interval] <- "gp4"
cit_cs95_90_gp$gp[interval * 4 + 1:interval] <- "gp5"
cit_cs95_90_gp$gp[interval * 5 + 1:interval] <- "gp6"
cit_cs95_90_gp$gp[interval * 6 + 1:interval] <- "gp7"
cit_cs95_90_gp$gp[interval * 7 + 1:interval] <- "gp8"
cit_cs95_90_gp$gp[interval * 8 + 1:interval] <- "gp9"
cit_cs95_90_gp$gp[x:y] <- "gp10"

cit_cs95_90_gp$gp <- factor(cit_cs95_90_gp$gp, levels = c("gp1", "gp2", "gp3", "gp4", "gp5", "gp6", 
	"gp7", "gp8", "gp9", "gp10"))
cit_cs95_90_gp <- cit_cs95_90_gp[, .(med_med = median(med), med_ten = median(ten), med_one = median(one)), 
	by = "gp"]
mcit_cit_cs95_90_gp <- melt(cit_cs95_90_gp, id = "gp")
fwrite(mcit_cit_cs95_90_gp, file = "mcit_cit_cs95_90_gp.csv", row.names = FALSE)
rm(x)
rm(y)
rm(interval)
qplot(gp, value, data = mcit_cit_cs95_90_gp, facets = variable ~ ., main = "cs25")

# nm_cocit_95
nm_cs95_zsc_med <- fread("nm_cs95_zsc_med.csv")
d95_cit <- fread("dataset1995_cit_counts.csv")
cit_nmcs95 <- merge(nm_cs95_zsc_med, d95_cit, by.x = "source_id", by.y = "source_id")

cit_nmcs95_90 <- cit_nmcs95[citation_count > quantile(cit_ks95$citation_count, 0.9)]
cit_nmcs95_90 <- cit_nmcs95_90[order(citation_count)]
cit_nmcs95_90_gp <- cit_nmcs95_90[, `:=`(gp, "x")]
fwrite(cit_nmcs95, file = "cit_nmcs95.csv", row.names = FALSE)
fwrite(cit_nmcs95_90, file = "cit_nmcs95_90.csv", row.names = FALSE)
interval <- floor(nrow(cit_nmcs95_90)/10)
x <- interval * 9 + 1
y <- nrow(cit_nmcs95_90_gp)

cit_nmcs95_90_gp$gp[1:interval] <- "gp1"
cit_nmcs95_90_gp$gp[interval + 1:interval] <- "gp2"
cit_nmcs95_90_gp$gp[interval * 2 + 1:interval] <- "gp3"
cit_nmcs95_90_gp$gp[interval * 3 + 1:interval] <- "gp4"
cit_nmcs95_90_gp$gp[interval * 4 + 1:interval] <- "gp5"
cit_nmcs95_90_gp$gp[interval * 5 + 1:interval] <- "gp6"
cit_nmcs95_90_gp$gp[interval * 6 + 1:interval] <- "gp7"
cit_nmcs95_90_gp$gp[interval * 7 + 1:interval] <- "gp8"
cit_nmcs95_90_gp$gp[interval * 8 + 1:interval] <- "gp9"
cit_nmcs95_90_gp$gp[x:y] <- "gp10"

cit_nmcs95_90_gp$gp <- factor(cit_nmcs95_90_gp$gp, levels = c("gp1", "gp2", "gp3", "gp4", "gp5", "gp6", 
	"gp7", "gp8", "gp9", "gp10"))
cit_nmcs95_90_gp <- cit_nmcs95_90_gp[, .(med_med = median(med), med_ten = median(ten), med_one = median(one)), 
	by = "gp"]
mcit_cit_nmcs95_90_gp <- melt(cit_nmcs95_90_gp, id = "gp")
fwrite(mcit_cit_nmcs95_90_gp, file = "mcit_cit_nmcs95_90_gp.csv", row.names = FALSE)
rm(x)
rm(y)
rm(interval)
qplot(gp, value, data = mcit_cit_nmcs95_90_gp, facets = variable ~ ., main = "nm_cs25")
