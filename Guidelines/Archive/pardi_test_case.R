# This script automates the test case for PARDI of annotating AHRQ CLinical Guidelines with NIH's fingerprints
# across relevant grants, publications, patents, therapeutics, and clinical trials data.

setwd("~/")
library(RPostgreSQL)
drv <- dbDriver('PostgreSQL')
con <- dbConnect(drv,dbname='pardi')
dbSendQuery(con, "DROP TABLE IF EXISTS temp_ncgc1;")
dbSendQuery(con, "CREATE TABLE temp_ncgc1 (uid INT, pmid INT, ahrq_uid INT);")
dbSendQuery(con,"COPY temp_ncgc1 FROM '/tmp/pmid.csv' DELIMITER ',' CSV HEADER;")

# Add URL column
dbSendQuery(con,"ALTER TABLE temp_ncgc1 ADD COLUMN url VARCHAR;")
dbSendQuery(con,"UPDATE temp_ncgc1 SET url='https://www.guideline.gov/content.aspx?id='||ahrq_uid;")
# Join with PMCID and WosIDs
dbSendQuery(con, "DROP TABLE IF EXISTS temp_ncgc2;")
dbSendQuery(con,"CREATE TABLE temp_ncgc2 AS SELECT a.pmid,b.pmcid,c.wos_uid FROM temp_ncgc a LEFT JOIN pmid_pmcid_mapping b ON a.pmid=b.pmid 
LEFT JOIN wos_pmid_mapping c ON a.pmid=SUBSTRING(c.pmid,9)::INT;")

# Join wih wos_references to get cited_source_uid
dbSendQuery(con, "DROP TABLE IF EXISTS temp_ncgc3;")
dbSendQuery(con,"CREATE TABLE temp_ncgc3 as SELECT  a.*,b.cited_source_uid FROM temp_ncgc2 a LEFT JOIN wos_references b on a.wos_uid=b.source_id;")

# Cleaning up cited_source_uid with WosClean.R

table1 <- dbGetQuery(con,"SELECT * from temp_ncgc3;")
table1[is.na(table1)] <-"NONE"
if(exists ("WosClean",mode="function")) rm(WosClean)
source("/pardidata1/PARDI_WoS/WosClean.R")
print(table1)

library(dplyr)
table1 <- table1 %>% rowwise() %>% mutate(cln_cited_source_uid=WosClean(cited_source_uid)) %>% data.frame()

# Write cleaned up table back into PostgreSQL
dbSendQuery(con,"DROP TABLE IF EXISTS temp_ncgc4;")
dbWriteTable(con,"temp_ncgc4",table1,row.names=FALSE)

# Fish out cited PMIDs from mapping table
dbSendQuery(con, "DROP TABLE IF EXISTS temp_ncgc5;")
dbSendQuery(con,"CREATE TABLE temp_ncgc5 AS SELECT a.*,b.pmid AS cited_pmid FROM temp_ncgc4 a LEFT JOIN wos_pmid_mapping b ON a.cln_cited_source_uid=b.wos_uid;")
dbSendQuery(con,"UPDATE temp_ncgc5 SET cited_pmid=cln_cited_source_uid WHERE SUBSTRING(cln_cited_source_uid,1,4)='MEDL';")
# Replace NONE with NULL for easier counting
dbSendQuery(con,"UPDATE temp_ncgc5 SET wos_uid=NULL where wos_uid='NONE';")
dbSendQuery(con,"UPDATE temp_ncgc5 SET cited_source_uid=NULL where cited_source_uid='NONE';")
dbSendQuery(con,"UPDATE temp_ncgc5 SET pmcid=NULL WHERE pmcid='NONE';")
dbSendQuery(con,"UPDATE temp_ncgc5 set cln_cited_source_uid=NULL WHERE cln_cited_source_uid='NONE';")
dbSendQuery(con,"DROP TABLE IF EXISTS temp_ncgc6;")
dbSendQuery(con,"CREATE TABLE temp_ncgc6 AS SELECT a.*,b.full_project_num_dc,b.activity_code,b.admin_phs_org_code,b.phs_agency_code_dc,b.pmid as spires_pmid  FROM temp_ncgc5 a 
LEFT JOIN spires_pub_projects b ON substring(a.cited_pmid,9)::int=b.pmid::int;")
table2 <- dbGetQuery(con,"SELECT * from temp_ncgc6;")
lapply(dbListConnections(PostgreSQL()), dbDisconnect)
dbDisconnect(con)
dbUnloadDriver(drv)
rm(con)
rm(drv)















