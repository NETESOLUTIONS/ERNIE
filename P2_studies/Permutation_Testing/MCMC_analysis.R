# script to import test data for Uzzi Fig 1 A
# George Chacko

#clean(workspace)
rm(list=ls())
library(dplyr)
#read in data
obs<- read.csv("~/Downloads/observed_frequency.csv",stringsAsFactors=FALSE,header=FALSE)
r1 <- read.csv("~/Downloads/random_frequency_1.csv",stringsAsFactors=FALSE,header=FALSE)
r2 <- read.csv("~/Downloads/random_frequency_2.csv",stringsAsFactors=FALSE,header=FALSE)
r3 <- read.csv("~/Downloads/random_frequency_3.csv",stringsAsFactors=FALSE,header=FALSE)
r4 <- read.csv("~/Downloads/random_frequency_4.csv",stringsAsFactors=FALSE,header=FALSE)
r5 <- read.csv("~/Downloads/random_frequency_5.csv",stringsAsFactors=FALSE,header=FALSE)
r6 <- read.csv("~/Downloads/random_frequency_6.csv",stringsAsFactors=FALSE,header=FALSE)
r7 <- read.csv("~/Downloads/random_frequency_7.csv",stringsAsFactors=FALSE,header=FALSE)
r8 <- read.csv("~/Downloads/random_frequency_8.csv",stringsAsFactors=FALSE,header=FALSE)
r9 <- read.csv("~/Downloads/random_frequency_9.csv",stringsAsFactors=FALSE,header=FALSE)
r10 <- read.csv("~/Downloads/random_frequency_10.csv",stringsAsFactors=FALSE,header=FALSE)

print(paste("No of rows in observed:",nrow(obs),sep=" "))
print(paste("No of rows in r1:",nrow(r1),sep=" "))
print(paste("No of rows in r2:",nrow(r2),sep=" "))
print(paste("No of rows in r3:",nrow(r3),sep=" "))
print(paste("No of rows in r4:",nrow(r4),sep=" "))
print(paste("No of rows in r5:",nrow(r5),sep=" "))
print(paste("No of rows in r6:",nrow(r6),sep=" "))
print(paste("No of rows in r7:",nrow(r7),sep=" "))
print(paste("No of rows in r8:",nrow(r8),sep=" "))
print(paste("No of rows in r9:",nrow(r9),sep=" "))
print(paste("No of rows in r10:",nrow(r10),sep=" "))

R1 <- rbind(r1,r2,r3,r4,r5,r6,r7,r8,r9,r10)
print(paste("No of rows in R1:",nrow(R1),sep=" "))

R2 <- R1 %>% group_by(V1) %>% summarize(mean_r=mean(V2,na.rm=TRUE),sd_r=sd(V2,na.rm=TRUE))
print(paste("No of rows in R2:",nrow(R2),sep=" "))
print(head(R2))

# Remove rows with NA and 0 for SD
R3 <- R2 %>% filter(sd_r!=0) %>% filter(!is.na(sd_r))
print(head(R3))
print(paste("No of rows in R3:",nrow(R3),sep=" "))

# Examine intersection of journal pairs in the two sets
print(paste("The number of common journal pairs in the observed and background sets is:" ,length(intersect(obs$V1,R3$V1))),sep=" ")
print(paste("Unique journal pairs for the observed and combined background sets is:",nrow(obs),"&",nrow(R3),"respectively.",sep=" "))

print("The burning question is, 'What about the remaining 55005 pairs?")

#calculate z-scores
# first merge observed with combined background
combined <- merge(obs,R3,by="V1")
combined <- combined %>% mutate(z_score=(V2-mean_r)/sd_r) %>% select(journal_pair=V1,obs=V2,mean_bg=mean_r,sd_bg=sd_r,z_score)

