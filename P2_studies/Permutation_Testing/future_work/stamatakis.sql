-- Script to assemble dataset based on two generations of citing references
-- for the 1990 BLAST paper by Alschul
-- George Chacko 12/29/2018

-- RaxML paper is pmid:16928733
-- get first gen of citing referenceds 
DROP TABLE IF EXISTS stamatakis1;
CREATE TABLE stamatakis1 AS
SELECT source_id,cited_source_uid 
FROM wos_references WHERE
cited_source_uid IN
(SELECT wos_id FROM wos_pmid_mapping 
WHERE pmid_int=16928733);
CREATE INDEX stamatakis1_idx ON stamatakis1(source_id,cited_source_uid);

-- get second gen of citing references
DROP TABLE IF EXISTS stamatakis2;
CREATE TABLE stamatakis2 AS
SELECT a.cited_source_uid AS seed, a.source_id AS citing1, b.source_id AS citing2
FROM stamatakis1 a INNER JOIN wos_references b
ON a.source_id=b.cited_source_uid;
CREATE INDEX stamatakis2_idx ON stamatakis2(citing2);

-- get pubyear for second gen citing 
DROP TABLE IF EXISTS stamatakis3;
CREATE TABLE stamatakis3 AS
SELECT a.*,b.publication_year AS citing2_pubyear 
FROM stamatakis2 a
INNER JOIN wos_publications b 
ON a.citing2=b.source_id;
CREATE INDEX stamatakis3_idx ON stamatakis3(citing1);

-- get pubyear for first gen citing 
DROP TABLE IF EXISTS stamatakis4;
CREATE TABLE stamatakis4 AS
SELECT a.*,b.publication_year as citing1_pubyear
 FROM stamatakis3 a
INNER JOIN wos_publications b
ON a.citing1=b.source_id;

-- reorder columns to get dataset_stamatakis and build index
-- eliminate citing refs that with pubyears less than their target
DROP TABLE IF EXISTS dataset_stamatakis;
CREATE TABLE dataset_stamatakis tablespace p2_studies AS
SELECT seed,citing1,citing1_pubyear,citing2,citing2_pubyear
FROM stamatakis4  
WHERE citing1_pubyear <= citing2_pubyear
AND citing1_pubyear::int >= 1989;
CREATE INDEX dataset_stamatakis_idx ON dataset_stamatakis(citing1,citing2);

DROP TABLE stamatakis1;
DROP TABLE stamatakis2;
DROP TABLE stamatakis3;
DROP TABLE stamatakis4;




