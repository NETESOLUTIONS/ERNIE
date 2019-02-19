-- test script to test Monte-Carlo methods for networks
-- this script was specifically developed for the ERNIE project 
-- but can be used for benchmarking performance
-- George Chacko 10/25/2018

SELECT NOW();
-- randomly select 1000 publications from the period 2005-2010
DROP TABLE IF EXISTS reth_ds1;
CREATE TABLE reth_ds1 AS
SELECT distinct citing1 as source_id, citing1_pubyear AS source_year 
FROM dataset_reth;
CREATE INDEX reth_ds1_idx ON reth_ds1(source_id);

-- join to get cited references. Expect to lose some data since not all 
-- pubs will have references that meet the WHERE conditions in this query
DROP TABLE IF EXISTS reth_ds2;
CREATE TABLE reth_ds2 AS
SELECT a.*,b.cited_source_uid
FROM reth_ds1 a INNER JOIN wos_references b 
ON a.source_id=b.source_id
WHERE substring(b.cited_source_uid,1,4)='WOS:'
AND length(b.cited_source_uid)=19;
CREATE INDEX reth_ds2_idx ON reth_ds2(source_id,cited_source_uid);

DROP TABLE IF EXISTS reth_ds3;
CREATE TABLE reth_ds3 AS
SELECT a.*,b.publication_year AS reference_year
FROM reth_ds2 a INNER JOIN wos_publications b
ON a.cited_source_uid=b.source_id;
CREATE INDEX reth_ds3_idx ON reth_ds3(source_id,cited_source_uid,reference_year);

DROP TABLE IF EXISTS reth_ds4;
CREATE TABLE reth_ds4 AS
SELECT  a.*,b.document_id as reference_issn,b.document_id_type
FROM reth_ds3 a LEFT JOIN wos_document_identifiers b
ON a.cited_source_uid=b.source_id 
WHERE document_id_type='issn';
CREATE INDEX reth_ds4_idx ON reth_ds4(source_id,cited_source_uid,reference_year,reference_issn);

DROP TABLE IF EXISTS reth_ds5;
CREATE TABLE reth_ds5 AS
SELECT a.source_id,
a.source_year,
b.document_id AS source_issn,
b.document_id_type AS source_document_id_type,
a.cited_source_uid,
a.reference_year,
a.reference_issn,
a.document_id_type AS reference_document_id_type
FROM reth_ds4 a LEFT JOIN wos_document_identifiers b
ON a.source_id=b.source_id
WHERE b.document_id_type='issn';

CREATE INDEX reth_ds5_idx ON reth_ds5(source_id,cited_source_uid,reference_year,reference_issn,source_issn,
source_year);

DROP TABLE IF EXISTS reth_mc;
CREATE TABLE reth_mc AS
SELECT DISTINCT * from reth_ds5;
CREATE INDEX reth_mc_idx ON reth_ds(source_id,cited_source_uid,source_issn,reference_issn);

DROP TABLE reth_ds1;
DROP TABLE reth_ds2;
DROP TABLE reth_ds3;
DROP TABLE reth_ds4
DROP TABLE reth_ds5;;

SELECT NOW();


