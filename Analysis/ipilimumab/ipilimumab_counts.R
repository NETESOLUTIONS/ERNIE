# Ipilimumab Analysis
# This script analyzes SQL and Network Analysis output files
# Author George Chacko 1/27/2018

rm(list=ls())
setwd("~/Desktop/ipilimumab/")
library(dplyr)
system("ls ~/Desktop/ipilimumab/")

# Import data files
# ipi_auth_pmid_scores <- read.csv("~/Desktop/ipilimumab/author_scores_pmid.csv",stringsAsFactors=FALSE)
# ipi_pubs_pmid <- read.csv("~/Desktop/ipilimumab/publication_scores_pmid.csv",stringsAsFactors=FALSE)
ipi_acuth_wos_scores <- read.csv("~/Desktop/ipilimumab/author_scores_wos.csv",stringsAsFactors=FALSE)
ipi_pubs_wos <- read.csv("~/Desktop/ipilimumab/publication_scores_wos.csv",stringsAsFactors=FALSE)
ipi_years <- read.delim("ipilimumab_citation_network_years.txt",stringsAsFactors=F,sep="\t")
ipi_loc <-read.delim("ipilimumab_citation_network_locations.txt",stringsAsFactors=F,sep="\t")
ipi_auth_wos <- read.delim("ipilimumab_citation_network_authors.txt",stringsAsFactors=F,sep="\t")

# Group authors by wos_id
ipi_auth_wos_counts <- ipi_auth_wos %>% select(wos_id,full_name) %>% group_by(wos_id) %>% summarize(auth_counts=length(full_name))

# Import State Department list of countries and add USA to it
library(stringdist)
countries <- read.delim("~/Desktop/ipilimumab/countries4",stringsAsFactors=F)
countries[44,1] <- "Cote d'Ivoire"
countries <- rbind(c("USA"),countries)

# Add Levenshtein based match to State Dept. names
ipi_loc <- ipi_loc %>% mutate(cmatch=amatch(tolower(ipi_loc$country),tolower(countries$country_name),maxDist=1))

# Identify outliers and correct them
flubs <- unique(ipi_loc[is.na(ipi_loc$cmatch),5])
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

# Add corrected country columns to ipi_loc
ipi_loc <- ipi_loc %>% mutate(corrected=ifelse(country %in% corrections$V1,"",country))

# Make specific corrections
ipi_loc[ipi_loc$country=="AUSTL.",7] <- "AUSTRALIA"
ipi_loc[ipi_loc$country=="Congo",7] <- "CONGO DEMOCRATIC REPUBLIC OF THE"
ipi_loc[ipi_loc$country=="Czech Republic",7] <- "CZECHIA"
ipi_loc[ipi_loc$country=="CZECH REPUBLIC",7] <- "CZECHIA"
ipi_loc[ipi_loc$country=="CZECHOSLOVAKIA",7] <- "CZECHIA"
ipi_loc[ipi_loc$country=="Dominican Rep",7] <- "DOMINICAN REPUBLIC"
ipi_loc[ipi_loc$country=="England",7] <- "UNITED KINGDOM"
ipi_loc[ipi_loc$country=="ENGLAND",7] <- "UNITED KINGDOM"
ipi_loc[ipi_loc$country=="FED REP GER",7] <- "GERMANY"
ipi_loc[ipi_loc$country=="GER DEM REP",7] <- "GERMANY"
ipi_loc[ipi_loc$country=="LONDON",7] <- "UNITED KINGDOM"
ipi_loc[ipi_loc$country=="Neth Antilles",7] <- "NETHERLANDS"
ipi_loc[ipi_loc$country=="North Ireland",7] <- "UNITED KINGDOM"
ipi_loc[ipi_loc$country=="NORTH IRELAND",7] <- "UNITED KINGDOM"
ipi_loc[ipi_loc$country=="Peoples R China",7] <- "CHINA"
ipi_loc[ipi_loc$country=="PEOPLES R CHINA",7] <- "CHINA"
ipi_loc[ipi_loc$country=="Rep of Georgia",7] <- "GEORGIA"
ipi_loc[ipi_loc$country=="REUNION",7] <- "FRANCE"
ipi_loc[ipi_loc$country=="Scotland",7] <- "UNITED KINGDOM"
ipi_loc[ipi_loc$country=="SCOTLAND",7] <- "UNITED KINGDOM"
ipi_loc[ipi_loc$country=="SENEGAMBIA",7] <- "SENEGAL"
ipi_loc[ipi_loc$country=="Serbia Monteneg",7] <- "SERBIA"
ipi_loc[ipi_loc$country=="Trinid & Tobago",7] <- "TRINIDAD & TOBAGO"
ipi_loc[ipi_loc$country=="TX77025",7] <- "USA"
ipi_loc[ipi_loc$country=="U Arab Emirates",7] <- "UNITED ARAB EMIRATES"
ipi_loc[ipi_loc$country=="UK",7] <- "UNITED KINGDOM"
ipi_loc[ipi_loc$country=="USSR",7] <- "RUSSIA"
ipi_loc[ipi_loc$country=="Wales",7] <- "UNITED KINGDOM"
ipi_loc[ipi_loc$country=="WALES",7] <- "UNITED KINGDOM"
ipi_loc[ipi_loc$country=="WEST GERMANY",7] <- "GERMANY"
ipi_loc[ipi_loc$country=="Yugoslavia",7] <- "SERBIA"
ipi_loc[ipi_loc$country=="YUGOSLAVIA",7] <- "SERBIA"
ipi_loc$corrected <- toupper(ipi_loc$corrected)

# clean up names and merge by LN, FI
ipi_auth_wos <- ipi_auth_wos %>% arrange(full_name) %>% 
mutate(l_n=sub(",.*$", "", full_name)) %>% 
mutate(f_n=sub("^.*,"," ", full_name)) %>% mutate(f_i="")
ipi_auth_wos$f_i <- substring(trimws(ipi_auth_wos$f_n),1,1)
ipi_auth_wos <- ipi_auth_wos %>% mutate(clean_name=paste(l_n,f_i,sep=", "))
ipi_auth_wos$clean_name <- toupper(ipi_auth_wos$clean_name)
ipi_auth_wos_counts <- ipi_auth_wos %>% select(wos_id,clean_name) %>% 
group_by(wos_id) %>% summarize(auth_counts=length(clean_name))

