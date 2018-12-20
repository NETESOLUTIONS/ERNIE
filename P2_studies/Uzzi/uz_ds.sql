-- test script to test Monte-Carlo methods for networks
-- this script was specifically developed for the ERNIE project 
-- but can be used for benchmarking performance
-- George Chacko 12/8/2018
-- this version restricts output to the 1980 dataset
-- you can point it at other years by replacing 1980 with year of choice, e.g. 1980
-- cleaned up bad git merge and replace 'gc_mc' with 'uz_ds' (Uzzi-dataslice)
-- George Chacko 12/20/2018

SELECT NOW();

DROP TABLE IF EXISTS uz_ds1;
CREATE TABLE uz_ds1 AS
SELECT source_id, publication_year AS source_year 
FROM wos_publications
WHERE publication_year::int = 1980
AND document_type='Article'; 
CREATE INDEX uz_ds1_idx ON uz_ds1(source_id);

-- join to get cited references. Expect to lose some data since not all 
-- pubs will have references that meet the WHERE conditions in this query

DROP TABLE IF EXISTS uz_ds2;
CREATE TABLE uz_ds2 AS
SELECT a.*,b.cited_source_uid
FROM uz_ds1 a INNER JOIN wos_references b 
ON a.source_id=b.source_id
WHERE substring(b.cited_source_uid,1,4)='WOS:'
AND length(b.cited_source_uid)=19;
CREATE INDEX uz_ds2_idx ON uz_ds2(source_id,cited_source_uid);

-- inner join on wos_publications to get pub year of references
DROP TABLE IF EXISTS uz_ds3;
CREATE TABLE uz_ds3 AS
SELECT a.*,b.publication_year AS reference_year
FROM uz_ds2 a INNER JOIN wos_publications b
ON a.cited_source_uid=b.source_id;
CREATE INDEX uz_ds3_idx ON uz_ds3(source_id,cited_source_uid,reference_year);

-- add issns for refs
DROP TABLE IF EXISTS uz_ds4;
CREATE TABLE uz_ds4 AS
SELECT  a.*,b.document_id as reference_issn,b.document_id_type
FROM uz_ds3 a INNER JOIN wos_document_identifiers b
ON a.cited_source_uid=b.source_id 
WHERE document_id_type='issn';
CREATE INDEX uz_ds4_idx ON uz_ds4(source_id,cited_source_uid,reference_year,reference_issn);

--add issns for source_id
DROP TABLE IF EXISTS uz_ds5;
CREATE TABLE uz_ds5 AS
SELECT a.source_id,
a.source_year,
b.document_id AS source_issn,
b.document_id_type AS source_document_id_type,
a.cited_source_uid,
a.reference_year,
a.reference_issn,
a.document_id_type AS reference_document_id_type
FROM uz_ds4 a INNER JOIN wos_document_identifiers b
ON a.source_id=b.source_id
WHERE b.document_id_type='issn';

CREATE INDEX uz_ds5_idx ON uz_ds5(source_id,cited_source_uid,reference_year,reference_issn,source_issn,
source_year);

-- select distinct 
DROP TABLE IF EXISTS uz_ds;
CREATE TABLE uz_ds AS
SELECT DISTINCT * from uz_ds5;
CREATE INDEX uz_ds_idx ON uz_ds(source_id,cited_source_uid,source_issn,reference_issn);

-- ensure that ref pubs year is not greater that source_id pubyear
DROP TABLE IF EXISTS dataset1980;
-- cleans out references published after pub_year (this is by convention)<<<<<<< HEAD
CREATE TABLE dataset1980 TABLESPACE p2_studies AS
SELECT * FROM  uz_ds 
WHERE  reference_year::int <= 1980;
ALTER TABLE dataset1980 SET SCHEMA public;

-- clean up
DROP TABLE uz_ds1;
DROP TABLE uz_ds2;
DROP TABLE uz_ds3;
DROP TABLE uz_ds4;
DROP TABLE uz_ds5;
DROP TABLE uz_ds;

SELECT NOW();





