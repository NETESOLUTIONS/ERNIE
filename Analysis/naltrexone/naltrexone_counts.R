# Naltrexone Analysis
# This script analyzes SQL and Network Analysis output files
# Author George Chacko 1/29/2018

rm(list=ls())
setwd("~/Desktop/naltrexone/")
library(dplyr)
system("ls ~/Desktop/naltrexone/")

# Import data files
# nal_auth_pmid_scores <- read.csv("~/Desktop/naltrexone/author_scores_pmid.csv",stringsAsFactors=FALSE)
# nal_pubs_pmid <- read.csv("~/Desktop/naltrexone/publication_scores_pmid.csv",stringsAsFactors=FALSE)
nal_auth_wos_scores <- read.csv("~/Desktop/naltrexone/author_scores_wos.csv",stringsAsFactors=FALSE)
nal_pubs_wos <- read.csv("~/Desktop/naltrexone/publication_scores_wos.csv",stringsAsFactors=FALSE)
nal_years <- read.delim("naltrexone_citation_network_years.txt",stringsAsFactors=F,sep="\t")
nal_loc <-read.delim("naltrexone_citation_network_locations.txt",stringsAsFactors=F,sep="\t")
nal_auth_wos <- read.delim("naltrexone_citation_network_authors.txt",stringsAsFactors=F,sep="\t")

# Group authors by wos_id
nal_auth_wos_counts <- nal_auth_wos %>% select(wos_id,full_name) %>% group_by(wos_id) %>% summarize(auth_counts=length(full_name))

# Import State Department list of countries and add USA to it
library(stringdist)
countries <- read.delim("~/Desktop/naltrexone/countries4",stringsAsFactors=F)
countries[44,1] <- "Cote d'Ivoire"
countries <- rbind(c("USA"),countries)

# Add Levenshtein based match to State Dept. names
nal_loc <- nal_loc %>% mutate(cmatch=amatch(tolower(nal_loc$country),tolower(countries$country_name),maxDist=1))

# Identify outliers and correct them
flubs <- unique(nal_loc[is.na(nal_loc$cmatch),5])
corrections <- data.frame(cbind(sort(flubs),corrected=rep("",length(flubs))),stringsAsFactors=FALSE)
corrections[corrections$V1=="AUSTL.",2] <- "AUSTRALIA"
corrections[corrections$V1=="BAHAMAS",2] <- "BAHAMAS THE"
corrections[corrections$V1=="Congo",2] <- "CONGO DEMOCRATIC REPUBLIC OF THE"
corrections[corrections$V1=="Czech Republic",2] <- "CZECHIA"
corrections[corrections$V1=="CZECH REPUBLIC",2] <- "CZECHIA"
corrections[corrections$V1=="CZECHOSLOVAKIA",2] <- "CZECHIA"
corrections[corrections$V1=="Dominican Rep",2] <- "DOMINICAN REPUBLIC"
corrections[corrections$V1=="England",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="ENGLAND",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="FED REP GER",2] <- "GERMANY"
corrections[corrections$V1=="GER DEM REP",2] <- "GERMANY"
corrections[corrections$V1=="EAST GERMANY",2] <- "GERMANY"
corrections[corrections$V1=="BUNDES REPUBLIK",2] <- "GERMANY"
corrections[corrections$V1=="LONDON",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="Neth Antilles",2] <- "NETHERLANDS"
corrections[corrections$V1=="North Ireland",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="NORTH IRELAND",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="Peoples R China",2] <- "CHINA"
corrections[corrections$V1=="PEOPLES R CHINA",2] <- "CHINA"
corrections[corrections$V1=="Rep of Georgia",2] <- "GEORGIA"
corrections[corrections$V1=="REUNION",2] <- "FRANCE"
corrections[corrections$V1=="Scotland",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="SCOTLAND",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="SENEGAMBIA",2] <- "SENEGAL"
corrections[corrections$V1=="Serbia Monteneg",2] <- "SERBIA"
corrections[corrections$V1=="Trinid & Tobago",2] <- "TRINIDAD & TOBAGO"
corrections[corrections$V1=="TX77025",2] <- "USA"
corrections[corrections$V1=="CA92037",2] <- "USA"
corrections[corrections$V1=="U Arab Emirates",2] <- "UNITED ARAB EMIRATES"
corrections[corrections$V1=="U ARAB EMIRATES",2] <- "UNITED ARAB EMIRATES"
corrections[corrections$V1=="UK",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="USSR",2] <- "RUSSIA"
corrections[corrections$V1=="Wales",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="WALES",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="WEST GERMANY",2] <- "GERMANY"
corrections[corrections$V1=="Yugoslavia",2] <- "SERBIA"
corrections[corrections$V1=="YUGOSLAVIA",2] <- "SERBIA"
corrections[corrections$V1=="ITALIA",2] <- "ITALY"
corrections[corrections$V1=="MONGOL PEO REP",2] <- "MONGOLIA"
corrections[corrections$V1=="PAPUA N GUINEA",2] <- "PAPUA NEW GUINEA"
corrections[corrections$V1=="UKSSR",2] <- "RUSSIA"
corrections[corrections$V1=="UNITED ARAB REP",2] <- "UNITED ARAB EMIRATES"
corrections[corrections$V1=="UPPER VOLTA",2] <- "RUSSIA"
corrections[corrections$V1=="YORKSHIRE",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="W Ind Assoc St",2] <- "GRENADA"


# Add corrected country columns to nal_loc
nal_loc <- nal_loc %>% mutate(corrected=ifelse(country %in% corrections$V1,"",country))

# Make specific corrections to country_names
nal_loc[nal_loc$country=="AUSTL.",2] <- "AUSTRALIA"
nal_loc[nal_loc$country=="BAHAMAS",2] <- "BAHAMAS THE"
nal_loc[nal_loc$country=="Congo",2] <- "CONGO DEMOCRATIC REPUBLIC OF THE"
nal_loc[nal_loc$country=="Czech Republic",2] <- "CZECHIA"
nal_loc[nal_loc$country=="CZECH REPUBLIC",2] <- "CZECHIA"
nal_loc[nal_loc$country=="CZECHOSLOVAKIA",2] <- "CZECHIA"
nal_loc[nal_loc$country=="Dominican Rep",2] <- "DOMINICAN REPUBLIC"
nal_loc[nal_loc$country=="England",2] <- "UNITED KINGDOM"
nal_loc[nal_loc$country=="ENGLAND",2] <- "UNITED KINGDOM"
nal_loc[nal_loc$country=="FED REP GER",2] <- "GERMANY"
nal_loc[nal_loc$country=="GER DEM REP",2] <- "GERMANY"
nal_loc[nal_loc$country=="EAST GERMANY",2] <- "GERMANY"
nal_loc[nal_loc$country=="BUNDES REPUBLIK",2] <- "GERMANY"
nal_loc[nal_loc$country=="LONDON",2] <- "UNITED KINGDOM"
nal_loc[nal_loc$country=="Neth Antilles",2] <- "NETHERLANDS"
nal_loc[nal_loc$country=="North Ireland",2] <- "UNITED KINGDOM"
nal_loc[nal_loc$country=="NORTH IRELAND",2] <- "UNITED KINGDOM"
nal_loc[nal_loc$country=="Peoples R China",2] <- "CHINA"
nal_loc[nal_loc$country=="PEOPLES R CHINA",2] <- "CHINA"
nal_loc[nal_loc$country=="Rep of Georgia",2] <- "GEORGIA"
nal_loc[nal_loc$country=="REUNION",2] <- "FRANCE"
nal_loc[nal_loc$country=="Scotland",2] <- "UNITED KINGDOM"
nal_loc[nal_loc$country=="SCOTLAND",2] <- "UNITED KINGDOM"
nal_loc[nal_loc$country=="SENEGAMBIA",2] <- "SENEGAL"
nal_loc[nal_loc$country=="Serbia Monteneg",2] <- "SERBIA"
nal_loc[nal_loc$country=="Trinid & Tobago",2] <- "TRINIDAD & TOBAGO"
nal_loc[nal_loc$country=="TX77025",2] <- "USA"
nal_loc[nal_loc$country=="CA92037",2] <- "USA"
nal_loc[nal_loc$country=="U Arab Emirates",2] <- "UNITED ARAB EMIRATES"
nal_loc[nal_loc$country=="U ARAB EMIRATES",2] <- "UNITED ARAB EMIRATES"
nal_loc[nal_loc$country=="UK",2] <- "UNITED KINGDOM"
nal_loc[nal_loc$country=="USSR",2] <- "RUSSIA"
nal_loc[nal_loc$country=="Wales",2] <- "UNITED KINGDOM"
nal_loc[nal_loc$country=="WALES",2] <- "UNITED KINGDOM"
nal_loc[nal_loc$country=="WEST GERMANY",2] <- "GERMANY"
nal_loc[nal_loc$country=="Yugoslavia",2] <- "SERBIA"
nal_loc[nal_loc$country=="YUGOSLAVIA",2] <- "SERBIA"
nal_loc[nal_loc$country=="ITALIA",2] <- "ITALY"
nal_loc[nal_loc$country=="MONGOL PEO REP",2] <- "MONGOLIA"
nal_loc[nal_loc$country=="PAPUA N GUINEA",2] <- "PAPUA NEW GUINEA"
nal_loc[nal_loc$country=="UKSSR",2] <- "RUSSIA"
nal_loc[nal_loc$country=="UNITED ARAB REP",2] <- "UNITED ARAB EMIRATES"
nal_loc[nal_loc$country=="UPPER VOLTA",2] <- "RUSSIA"
nal_loc[nal_loc$country=="YORKSHIRE",2] <- "UNITED KINGDOM"
nal_loc[nal_loc$country=="W Ind Assoc St",2] <- "GRENADA"
nal_loc$corrected <- toupper(nal_loc$corrected)

# clean up names and merge by LN, FI
nal_auth_wos <- nal_auth_wos %>% arrange(full_name) %>% 
mutate(l_n=sub(",.*$", "", full_name)) %>% 
mutate(f_n=sub("^.*,"," ", full_name)) %>% mutate(f_i="")
nal_auth_wos$f_i <- substring(trimws(nal_auth_wos$f_n),1,1)
nal_auth_wos <- nal_auth_wos %>% mutate(clean_name=paste(l_n,f_i,sep=", "))
nal_auth_wos$clean_name <- toupper(nal_auth_wos$clean_name)
nal_auth_wos_counts <- nal_auth_wos %>% select(wos_id,clean_name) %>% 
group_by(wos_id) %>% summarize(auth_counts=length(clean_name))
# Estimate Missing Records
temp1 <- merge(nal_years,nal_loc,all.x=T)
total_counts <- temp1 %>% select(publication_year,wos_id) %>% unique() %>% group_by(publication_year) %>% summarize(total_pubs=length(wos_id))
address_counts <- temp1 %>% filter(!is.na(country)) %>% select(publication_year,wos_id) %>% unique %>% group_by(publication_year) %>% summarize(address_pubs=length(wos_id))
nal_missing_data <- merge(total_counts,address_counts,all.x=T)
nal_missing_data[is.na(nal_missing_data$address_pubs),3] <- 0

nal_year_pub <- nal_years %>% select(publication_year,wos_id) %>% unique() %>% group_by(publication_year) %>% summarize(pub_count=length(wos_id))

wos_missing_data <- read.csv("publication_addresses_stats.csv",stringsAsFactors=F)

library(ggplot2)
p1_nal <- qplot(publication_year,100*(address_pubs/total_pubs),data=nal_missing_data,geom=c("point","line"),ylab="percent publications with author addresses",main="naltrexone") + theme_bw()

p2_nal <- qplot(publication_year,pub_count,data=nal_year_pub,geom=c("point","line")) + theme_bw()

p3_allwos <- p3_allwos <- qplot(publication_year,100*(pub_with_an_address_count/pub_count),data=wos_missing_data,geom=c("point","line"),ylab="",xlab="",main="All WoS") + theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank())
pdf("p1_nal.pdf")
print(p1_nal)
dev.off()
pdf("p2_nal.pdf")
print(p2_nal)
dev.off()

library(grid)

vp <- viewport(width = 0.3, height = 0.3, x = 0.97,
     y = unit(4, "lines"), just = c("right",
         "bottom"))
         
         full <- function() {
     print(p1_nal)
     theme_set(theme_bw(base_size = 8))
     theme_bw()
     print(p3_allwos, vp = vp)
     theme_set(theme_bw())}

pdf("missing_addresses_nal.pdf")
full()
dev.off()