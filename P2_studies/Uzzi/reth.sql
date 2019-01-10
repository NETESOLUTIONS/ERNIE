-- Script to assemble dataset based on two generations of citing references
-- for the 1989 Nature paper by Reth on antigen receptor tail motifs
-- aka Reth motif, ARAM, ITAM. George Chacko 12/29/2018

-- Reth paper is pmid:2927501
-- get first gen of citing referenceds 
DROP TABLE IF EXISTS reth1;
CREATE TABLE reth1 AS
SELECT source_id,cited_source_uid 
FROM wos_references WHERE
cited_source_uid IN
(SELECT wos_id FROM wos_pmid_mapping 
WHERE pmid_int=2927501);

-- get second gen of citing references
DROP TABLE IF EXISTS reth2;
CREATE TABLE reth2 AS
SELECT a.cited_source_uid AS seed, a.source_id AS citing1, b.source_id AS citing2
FROM reth1 a INNER JOIN wos_references b
ON a.source_id=b.cited_source_uid;
CREATE INDEX reth2_idx ON reth2(citing2);

-- get pubyear for second gen citing 
DROP TABLE IF EXISTS reth3;
CREATE TABLE reth3 AS
SELECT a.*,b.publication_year AS citing2_pubyear 
FROM reth2 a
INNER JOIN wos_publications b 
ON a.citing2=b.source_id;
CREATE INDEX reth3_idx ON reth3(citing1);

-- get pubyear for first gen citing 
DROP TABLE IF EXISTS reth4;
CREATE TABLE reth4 AS
SELECT a.*,b.publication_year as citing1_pubyear
 FROM reth3 a
INNER JOIN wos_publications b
ON a.citing1=b.source_id;

-- reorder columns to get dataset_reth and build index
-- eliminate citing refs that with pubyears less than their target
DROP TABLE IF EXISTS dataset_reth;
CREATE TABLE dataset_reth tablespace p2_studies AS
SELECT seed,citing1,citing1_pubyear,citing2,citing2_pubyear
FROM reth4  
WHERE citing1_pubyear <= citing2_pubyear
AND citing1_pubyear::int >= 1989;
CREATE INDEX dataset_reth_idx ON dataset_reth(citing1,citing2);

DROP TABLE reth1;
DROP TABLE reth2;
DROP TABLE reth3;
DROP TABLE reth4;



