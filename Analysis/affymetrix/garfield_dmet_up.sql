-- script to connect Affymetrix DMET and Amplichip Data with garfield's h_graph

DROP TABLE IF EXISTS garfield_hgraph;
CREATE TABLE garfield_hgraph(pmid int, wos_id varchar(30));
\COPY garfield_hgraph FROM '~/garfield_hgraph.csv' CSV HEADER DELIMITER ',';

DROP TABLE IF EXISTS garfield_hgraph2;
CREATE TABLE garfield_hgraph2 AS
SELECT a.pmid,b.wos_id FROM garfield_hgraph a
LEFT JOIN wos_pmid_mapping b ON 
a.pmid=b.pmid_int;
INSERT INTO garfield_hgraph2 (wos_id) values('WOS:A19633101B00025');

DROP TABLE IF EXISTS garfield_hgraph3;
CREATE TABLE garfield_hgraph3 AS
SELECT a.*.b.source_id 
FROM garfield_hgraph2 a 
INNER JOIN wos_references b on a.wos_id=b.cited_source_uid;








