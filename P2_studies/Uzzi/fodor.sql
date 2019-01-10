-- Script to assemble dataset based on two generations of citing references
-- for the 1994 PNAS  paper by Pease/Fodor  on DNA microarrays
-- George Chacko 12/29/2018

-- Fodor paper is pmid:8197176
-- get first gen of citing referenceds 
DROP TABLE IF EXISTS fodor1;
CREATE TABLE fodor1 AS
SELECT source_id,cited_source_uid 
FROM wos_references WHERE
cited_source_uid IN
(SELECT wos_id FROM wos_pmid_mapping 
WHERE pmid_int=8197176);

-- get second gen of citing references
DROP TABLE IF EXISTS fodor2;
CREATE TABLE fodor2 AS
SELECT a.cited_source_uid AS seed, a.source_id AS citing1, b.source_id AS citing2
FROM fodor1 a INNER JOIN wos_references b
ON a.source_id=b.cited_source_uid;
CREATE INDEX fodor2_idx ON fodor2(citing2);

-- get pubyear for second gen citing 
DROP TABLE IF EXISTS fodor3;
CREATE TABLE fodor3 AS
SELECT a.*,b.publication_year AS citing2_pubyear 
FROM fodor2 a
INNER JOIN wos_publications b 
ON a.citing2=b.source_id;
CREATE INDEX fodor3_idx ON fodor3(citing1);

-- get pubyear for first gen citing 
DROP TABLE IF EXISTS fodor4;
CREATE TABLE fodor4 AS
SELECT a.*,b.publication_year as citing1_pubyear
 FROM fodor3 a
INNER JOIN wos_publications b
ON a.citing1=b.source_id;

-- reorder columns to get dataset_fodor and build index
-- eliminate citing refs that with pubyears less than their target
DROP TABLE IF EXISTS dataset_fodor;
CREATE TABLE dataset_fodor tablespace p2_studies AS
SELECT seed,citing1,citing1_pubyear,citing2,citing2_pubyear
FROM fodor4  
WHERE citing1_pubyear <= citing2_pubyear
AND citing1_pubyear::int >= 1989;
CREATE INDEX dataset_fodor_idx ON dataset_fodor(citing1,citing2);

DROP TABLE fodor1;
DROP TABLE fodor2;
DROP TABLE fodor3;
DROP TABLE fodor4;




