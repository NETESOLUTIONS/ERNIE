# Ivacaftor Analysis
# This script analyzes SQL and Network Analysis output files
# Author George Chacko 1/30/2018

rm(list=ls())
setwd("~/Desktop/ivacaftor/")
library(dplyr)
system("ls ~/Desktop/ivacaftor/")

# Import data files
# iva_auth_pmid_scores <- read.csv("~/Desktop/ivacaftor/author_scores_pmid.csv",stringsAsFactors=FALSE)
# iva_pubs_pmid <- read.csv("~/Desktop/ivacaftor/publication_scores_pmid.csv",stringsAsFactors=FALSE)
iva_auth_wos_scores <- read.csv("~/Desktop/ivacaftor/author_scores_wos.csv",stringsAsFactors=FALSE)
iva_pubs_wos <- read.csv("~/Desktop/ivacaftor/publication_scores_wos.csv",stringsAsFactors=FALSE)
iva_years <- read.delim("ivacaftor_citation_network_years.txt",stringsAsFactors=F,sep="\t")
iva_loc <-read.delim("ivacaftor_citation_network_locations.txt",stringsAsFactors=F,sep="\t")
iva_auth_wos <- read.delim("ivacaftor_citation_network_authors.txt",stringsAsFactors=F,sep="\t")

# Group authors by wos_id
iva_auth_wos_counts <- iva_auth_wos %>% select(wos_id,full_name) %>% group_by(wos_id) %>% summarize(auth_counts=length(full_name))

# Import State Department list of countries and add USA to it
library(stringdist)
countries <- read.delim("~/Desktop/ivacaftor/countries4",stringsAsFactors=F)
countries[44,1] <- "Cote d'Ivoire"
countries <- rbind(c("USA"),countries)

# Add Levenshtein based match to State Dept. names
iva_loc <- iva_loc %>% mutate(cmatch=amatch(tolower(iva_loc$country),tolower(countries$country_name),maxDist=1))

# Identify outliers and correct them
flubs <- unique(iva_loc[is.na(iva_loc$cmatch),5])
corrections <- data.frame(cbind(sort(flubs),corrected=rep("",length(flubs))),stringsAsFactors=FALSE)
corrections[corrections$V1=="AUSTL.",2] <- "AUSTRALIA"
corrections[corrections$V1=="Congo",2] <- "CONGO DEMOCRATIC REPUBLIC OF THE"
corrections[corrections$V1=="Czech Republic",2] <- "CZECHIA"
corrections[corrections$V1=="CZECH REPUBLIC",2] <- "CZECHIA"
corrections[corrections$V1=="CZECHOSLOVAKIA",2] <- "CZECHIA"
corrections[corrections$V1=="Dominican Rep",2] <- "DOMINICAN REPUBLIC"
corrections[corrections$V1=="England",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="ENGLAND",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="FED REP GER",2] <- "GERMANY"
corrections[corrections$V1=="GER DEM REP",2] <- "GERMANY"
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
corrections[corrections$V1=="U Arab Emirates",2] <- "UNITED ARAB EMIRATES"
corrections[corrections$V1=="UK",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="USSR",2] <- "RUSSIA"
corrections[corrections$V1=="Wales",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="WALES",2] <- "UNITED KINGDOM"
corrections[corrections$V1=="WEST GERMANY",2] <- "GERMANY"
corrections[corrections$V1=="Yugoslavia",2] <- "SERBIA"
corrections[corrections$V1=="YUGOSLAVIA",2] <- "SERBIA"
corrections[corrections$V1=="U ARAB EMIRATES",2] <- "UNITED ARAB EMIRATES"
corrections[corrections$V1=="U Arab Emirates",2] <- "UNITED ARAB EMIRATES"
corrections[corrections$V1=="AUUSTL.",2] <- "AUSTRALIA"
# Add corrected country columns to iva_loc
iva_loc <- iva_loc %>% mutate(corrected=ifelse(country %in% corrections$V1,"",country))

# Make specific corrections to country_names
iva_loc[iva_loc$country=="AUSTL.",7] <- "AUSTRALIA"
iva_loc[iva_loc$country=="Congo",7] <- "CONGO DEMOCRATIC REPUBLIC OF THE"
iva_loc[iva_loc$country=="Czech Republic",7] <- "CZECHIA"
iva_loc[iva_loc$country=="CZECH REPUBLIC",7] <- "CZECHIA"
iva_loc[iva_loc$country=="CZECHOSLOVAKIA",7] <- "CZECHIA"
iva_loc[iva_loc$country=="Dominican Rep",7] <- "DOMINICAN REPUBLIC"
iva_loc[iva_loc$country=="England",7] <- "UNITED KINGDOM"
iva_loc[iva_loc$country=="ENGLAND",7] <- "UNITED KINGDOM"
iva_loc[iva_loc$country=="FED REP GER",7] <- "GERMANY"
iva_loc[iva_loc$country=="GER DEM REP",7] <- "GERMANY"
iva_loc[iva_loc$country=="LONDON",7] <- "UNITED KINGDOM"
iva_loc[iva_loc$country=="Neth Antilles",7] <- "NETHERLANDS"
iva_loc[iva_loc$country=="North Ireland",7] <- "UNITED KINGDOM"
iva_loc[iva_loc$country=="NORTH IRELAND",7] <- "UNITED KINGDOM"
iva_loc[iva_loc$country=="Peoples R China",7] <- "CHINA"
iva_loc[iva_loc$country=="PEOPLES R CHINA",7] <- "CHINA"
iva_loc[iva_loc$country=="Rep of Georgia",7] <- "GEORGIA"
iva_loc[iva_loc$country=="REUNION",7] <- "FRANCE"
iva_loc[iva_loc$country=="Scotland",7] <- "UNITED KINGDOM"
iva_loc[iva_loc$country=="SCOTLAND",7] <- "UNITED KINGDOM"
iva_loc[iva_loc$country=="SENEGAMBIA",7] <- "SENEGAL"
iva_loc[iva_loc$country=="Serbia Monteneg",7] <- "SERBIA"
iva_loc[iva_loc$country=="Trinid & Tobago",7] <- "TRINIDAD & TOBAGO"
iva_loc[iva_loc$country=="TX77025",7] <- "USA"
iva_loc[iva_loc$country=="U Arab Emirates",7] <- "UNITED ARAB EMIRATES"
iva_loc[iva_loc$country=="UK",7] <- "UNITED KINGDOM"
iva_loc[iva_loc$country=="USSR",7] <- "RUSSIA"
iva_loc[iva_loc$country=="Wales",7] <- "UNITED KINGDOM"
iva_loc[iva_loc$country=="WALES",7] <- "UNITED KINGDOM"
iva_loc[iva_loc$country=="WEST GERMANY",7] <- "GERMANY"
iva_loc[iva_loc$country=="Yugoslavia",7] <- "SERBIA"
iva_loc[iva_loc$country=="YUGOSLAVIA",7] <- "SERBIA"
iva_loc[iva_loc$country=="U ARAB EMIRATES",7] <- "UNITED ARAB EMIRATES"
iva_loc[iva_loc$country=="U Arab Emirates",7] <- "UNITED ARAB EMIRATES"
iva_loc[iva_loc$country=="AUUSTL.",7] <- "AUSTRALIA"

iva_loc$corrected <- toupper(iva_loc$corrected)

# clean up names and merge by LN, FI
iva_auth_wos <- iva_auth_wos %>% arrange(full_name) %>% 
mutate(l_n=sub(",.*$", "", full_name)) %>% 
mutate(f_n=sub("^.*,"," ", full_name)) %>% mutate(f_i="")
iva_auth_wos$f_i <- substring(trimws(iva_auth_wos$f_n),1,1)
iva_auth_wos <- iva_auth_wos %>% mutate(clean_name=paste(l_n,f_i,sep=", "))
iva_auth_wos$clean_name <- toupper(iva_auth_wos$clean_name)
iva_auth_wos_counts <- iva_auth_wos %>% select(wos_id,clean_name) %>% 
group_by(wos_id) %>% summarize(auth_counts=length(clean_name))

print(paste("The earliest pub in this set is dated:",min(iva_years$publication_year),sep=" "))

print(paste("The latest pub in this set is dated:",max(iva_years$publication_year),sep=" "))

print(paste("The number of authors is estimated to be:", length(unique(iva_auth_wos$clean_name)),sep=""))

print(paste("The authors published from:", length(unique(iva_loc$corrected)),"countries.",sep=" "))

print(paste("The authors published:",  length(unique(iva_pubs_wos$publication)),"papers.",sep=" "))