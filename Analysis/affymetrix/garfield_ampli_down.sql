-- script to connect Affymetrix Amplichip Data with garfield's h_graph

DROP TABLE IF EXISTS garfield_ampli;
CREATE TABLE garfield_ampli(pmid int, wos_id varchar(30));
\COPY garfield_ampli FROM '~/ERNIE/Analysis/affymetrix/garfield_amplichip.csv' CSV HEADER DELIMITER ',';

DROP TABLE IF EXISTS garfield_ampli2;
CREATE TABLE garfield_ampli2 AS
SELECT a.pmid,b.wos_id 
FROM garfield_ampli a
LEFT JOIN wos_pmid_mapping b ON
a.pmid=b.pmid_int;
CREATE INDEX garfield_ampli2_idx ON garfield_ampli2(wos_id);

DROP TABLE IF EXISTS garfield_ampli3;
CREATE TABLE garfield_ampli3 AS
SELECT a.wos_id,b.cited_source_uid as cited_gen1
FROM garfield_ampli2 a 
LEFT JOIN wos_references b
ON a.wos_id=b.source_id;










