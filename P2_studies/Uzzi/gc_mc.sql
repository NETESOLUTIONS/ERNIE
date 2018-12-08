-- test script to test Monte-Carlo methods for networks
-- this script was specifically developed for the ERNIE project 
-- but can be used for benchmarking performance
-- George Chacko 12/8/2018
-- this version restricts output to the 1980 dataset
-- you can point it at other years by replacing 1980 with year of choice, e.g. 1985

SELECT NOW();

DROP TABLE IF EXISTS gc_mc1;
CREATE TABLE gc_mc1 AS
SELECT source_id, publication_year AS source_year 
FROM wos_publications
WHERE publication_year::int = 1980
AND document_type='Article'; 
CREATE INDEX gc_mc1_idx ON gc_mc1(source_id);

-- join to get cited references. Expect to lose some data since not all 
-- pubs will have references that meet the WHERE conditions in this query
DROP TABLE IF EXISTS gc_mc2;
CREATE TABLE gc_mc2 AS
SELECT a.*,b.cited_source_uid
FROM gc_mc1 a INNER JOIN wos_references b 
ON a.source_id=b.source_id
WHERE substring(b.cited_source_uid,1,4)='WOS:'
AND length(b.cited_source_uid)=19;
CREATE INDEX gc_mc2_idx ON gc_mc2(source_id,cited_source_uid);

DROP TABLE IF EXISTS gc_mc3;
CREATE TABLE gc_mc3 AS
SELECT a.*,b.publication_year AS reference_year
FROM gc_mc2 a INNER JOIN wos_publications b
ON a.cited_source_uid=b.source_id;
CREATE INDEX gc_mc3_idx ON gc_mc3(source_id,cited_source_uid,reference_year);

DROP TABLE IF EXISTS gc_mc4;
CREATE TABLE gc_mc4 AS
SELECT  a.*,b.document_id as reference_issn,b.document_id_type
FROM gc_mc3 a INNER JOIN wos_document_identifiers b
ON a.cited_source_uid=b.source_id 
WHERE document_id_type='issn';
CREATE INDEX gc_mc4_idx ON gc_mc4(source_id,cited_source_uid,reference_year,reference_issn);

DROP TABLE IF EXISTS gc_mc5;
CREATE TABLE gc_mc5 AS
SELECT a.source_id,
a.source_year,
b.document_id AS source_issn,
b.document_id_type AS source_document_id_type,
a.cited_source_uid,
a.reference_year,
a.reference_issn,
a.document_id_type AS reference_document_id_type
FROM gc_mc4 a INNER JOIN wos_document_identifiers b
ON a.source_id=b.source_id
WHERE b.document_id_type='issn';

CREATE INDEX gc_mc5_idx ON gc_mc5(source_id,cited_source_uid,reference_year,reference_issn,source_issn,
source_year);

DROP TABLE IF EXISTS gc_mc;
CREATE TABLE gc_mc AS
SELECT DISTINCT * from gc_mc5;
CREATE INDEX gc_mc_idx ON gc_mc(source_id,cited_source_uid,source_issn,reference_issn);

DROP TABLE IF EXISTS dataset1980;
CREATE TABLE dataset1980 TABLESPACE p2_studies AS
SELECT * from gc_mc 
-- cleans out references published after pub_year (this is by convention)
WHERE reference_year::int <= 1980;

\copy (select * from dataset1980) TO '/erniedev_data10/P2_studies/data_slices/dataset1980.csv' CSV HEADER DELIMITER ',';

SELECT NOW();
