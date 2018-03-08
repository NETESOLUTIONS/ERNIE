-- script to connect Affymetrix DMET and Amplichip Data with garfield's h_graph

DROP TABLE IF EXISTS garfield_dmet;
CREATE TABLE garfield_dmet(pmid int, wos_id varchar(30));
\COPY garfield_dmet FROM '~/ERNIE/Analysis/affymetrix/garfield_dmet.csv' CSV HEADER DELIMITER ',';

DROP TABLE IF EXISTS garfield_dmet2;
CREATE TABLE garfield_dmet2 AS
SELECT a.pmid,b.wos_id 
FROM garfield_dmet a
LEFT JOIN wos_pmid_mapping b ON
a.pmid=b.pmid_int;

UPDATE garfield_dmet2 SET wos_id='WOS:000419564600018' WHERE pmid=29296186;
UPDATE garfield_dmet2 SET wos_id='WOS:000419561600094' WHERE pmid=29245979;
UPDATE garfield_dmet2 SET wos_id='WOS:000373951000001' WHERE pmid=26731477;
UPDATE garfield_dmet2 SET wos_id='WOS:000351380100001' WHERE pmid=25802476;

DROP TABLE IF EXISTS garfield_dmet3;
CREATE TABLE garfield_dmet3 AS
SELECT a.wos_id,b.cited_source_uid as cited_gen1
FROM garfield_dmet2 a 
LEFT JOIN wos_references b
ON a.wos_id=b.source_id;









