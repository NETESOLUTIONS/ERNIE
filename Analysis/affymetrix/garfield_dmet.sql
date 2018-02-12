-- script to connect Affymetrix DMET and Amplichip Data with garfield's h_graph

DROP TABLE IF EXISTS garfield_hgraph
CREATE TABLE garfield_hgraph(pmid int, wos_id varchar(30);
COPY garfield_hgraph FROM '~/garfield_hgraph.csv' CSV HEADER DELIMITER ",':
