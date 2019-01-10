-- Script to assemble dataset based on two generations of citing references
-- for the 1990 BLAST paper by Alschul
-- George Chacko 12/29/2018

-- BLAST paper is pmid:2231712
-- get first gen of citing referenceds 
DROP TABLE IF EXISTS altschul1;
CREATE TABLE altschul1 AS
SELECT source_id,cited_source_uid 
FROM wos_references WHERE
cited_source_uid IN
(SELECT wos_id FROM wos_pmid_mapping 
WHERE pmid_int=2231712);
CREATE INDEX altschul1_idx ON altschul1(source_id,cited_source_uid);

-- get second gen of citing references
DROP TABLE IF EXISTS altschul2;
CREATE TABLE altschul2 AS
SELECT a.cited_source_uid AS seed, a.source_id AS citing1, b.source_id AS citing2
FROM altschul1 a INNER JOIN wos_references b
ON a.source_id=b.cited_source_uid;
CREATE INDEX altschul2_idx ON altschul2(citing2);

-- get pubyear for second gen citing 
DROP TABLE IF EXISTS altschul3;
CREATE TABLE altschul3 AS
SELECT a.*,b.publication_year AS citing2_pubyear 
FROM altschul2 a
INNER JOIN wos_publications b 
ON a.citing2=b.source_id;
CREATE INDEX altschul3_idx ON altschul3(citing1);

-- get pubyear for first gen citing 
DROP TABLE IF EXISTS altschul4;
CREATE TABLE altschul4 AS
SELECT a.*,b.publication_year as citing1_pubyear
 FROM altschul3 a
INNER JOIN wos_publications b
ON a.citing1=b.source_id;

-- reorder columns to get dataset_altschul and build index
-- eliminate citing refs that with pubyears less than their target
DROP TABLE IF EXISTS dataset_altschul;
CREATE TABLE dataset_altschul tablespace p2_studies AS
SELECT seed,citing1,citing1_pubyear,citing2,citing2_pubyear
FROM altschul4  
WHERE citing1_pubyear <= citing2_pubyear
AND citing1_pubyear::int >= 1989;
CREATE INDEX dataset_altschul_idx ON dataset_altschul(citing1,citing2);

DROP TABLE altschul1;
DROP TABLE altschul2;
DROP TABLE altschul3;
DROP TABLE altschul4;




