-- test script to test Monte-Carlo methods for networks
-- this script was specifically developed for the ERNIE project 
-- but can be used for benchmarking performance
-- George Chacko 12/8/2018
-- cleaned up bad git merge and replace 'gc_mc' with 'uz_ds' (Uzzi-dataslice)
-- DK added expresions to select most frequently used issns where multiple values exist
-- can pass parametes now
-- e.g., nohup  psql -d ernie -f /home/chackoge/ERNIE/P2_studies/Uzzi/uz_ds.sql 
-- -v year=1980 -v dataset_name=dataset1980 &
-- George Chacko 12/20/2018

SELECT NOW();

DROP TABLE IF EXISTS uz_ds1;

CREATE TABLE uz_ds1 AS
SELECT source_id, publication_year AS source_year
FROM wos_publications
WHERE publication_year::INT = :year AND document_type = 'Article';

CREATE INDEX uz_ds1_idx ON uz_ds1(source_id);

-- join to get cited references. Expect to lose some data since not all 
-- pubs will have references that meet the WHERE conditions in this query

DROP TABLE IF EXISTS uz_ds2;

CREATE TABLE uz_ds2 AS
SELECT a.*, b.cited_source_uid
FROM uz_ds1 a
JOIN wos_references b ON a.source_id = b.source_id
WHERE substring(b.cited_source_uid, 1, 4) = 'WOS:' AND length(b.cited_source_uid) = 19;

CREATE INDEX uz_ds2_idx ON uz_ds2(source_id, cited_source_uid);

-- inner join on wos_publications to get pub year of references
DROP TABLE IF EXISTS uz_ds3;

CREATE TABLE uz_ds3 AS
SELECT a.*, b.publication_year AS reference_year
FROM uz_ds2 a
JOIN wos_publications b ON a.cited_source_uid = b.source_id;

CREATE INDEX uz_ds3_idx ON uz_ds3(source_id, cited_source_uid, reference_year);

-- add issns for refs
--add issns for source_id
DROP TABLE IF EXISTS uz_ds5;

CREATE TABLE uz_ds5 AS
SELECT
  a.source_id,
  a.source_year,
  'issn' AS source_document_id_type,
  (
    SELECT wdi.document_id
    FROM wos_document_identifiers wdi
    JOIN wos_issn_stats wis ON wis.issn = wdi.document_id
    WHERE wdi.document_id_type = 'issn' AND wdi.source_id = a.source_id
    ORDER BY wis.publication_count DESC, wdi.document_id
    LIMIT 1
  ) AS source_issn,
  a.cited_source_uid,
  a.reference_year,
  'issn' AS reference_document_id_type,
  (
    SELECT wdi.document_id
    FROM wos_document_identifiers wdi
    JOIN wos_issn_stats wis ON wis.issn = wdi.document_id
    WHERE wdi.document_id_type = 'issn' AND wdi.source_id = a.cited_source_uid
    ORDER BY wis.publication_count DESC, wdi.document_id
    LIMIT 1
  ) AS reference_issn
FROM uz_ds3 a;

CREATE INDEX uz_ds5_idx ON uz_ds5(source_id, cited_source_uid, reference_year, reference_issn, source_issn,
                                  source_year);

-- select distinct 
DROP TABLE IF EXISTS uz_ds;

CREATE TABLE uz_ds AS
SELECT DISTINCT *
FROM uz_ds5;

CREATE INDEX uz_ds_idx ON uz_ds(source_id, cited_source_uid, source_issn, reference_issn);

-- ensure that ref pubs year is not greater that source_id pubyear
DROP TABLE IF EXISTS :dataset_name;

-- cleans out references published after pub_year (this is by convention)<<<<<<< HEAD
CREATE TABLE :dataset_name TABLESPACE p2_studies AS
SELECT *
FROM uz_ds
WHERE reference_year::INT <= :year;

ALTER TABLE :dataset_name SET SCHEMA public;

-- clean up
DROP TABLE uz_ds1;
DROP TABLE uz_ds2;
DROP TABLE uz_ds3;
-- DROP TABLE uz_ds4;
DROP TABLE uz_ds5;
DROP TABLE uz_ds;

SELECT NOW();





