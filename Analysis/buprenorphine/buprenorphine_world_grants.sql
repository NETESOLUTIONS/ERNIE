-- Extract World Grant Information from buprenorphine_data

DROP TABLE IF EXISTS buprenorphine_world_grants;
CREATE TABLE buprenorphine_world_grants AS
SELECT a.wos_id,b.* FROM case_buprenorphine_citation_network_years a 
INNER JOIN wos_grants b on a.wos_id=b.source_id;
\copy buprenorphine_world_grants TO '/erniedev_data2/buprenorphine.csv' WITH (FORMAT CSV, HEADER);
