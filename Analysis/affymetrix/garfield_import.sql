-- Script to generate csv files for import into neo4j
-- This is the affymetrix case study tracing the affy seedset of <= 1991 to the DMET Plus
-- Panel of 2017
-- Author: George Chacko 2/20/2018

-- End point is the garfield_hgraph series, which contains 23 wos_ids from Garfield's microarray historiograph
-- Starting point is all papers identified in a keyword search in PubMed for DMET PLus
-- Publications are connected/related by citation. The target is cited by the source.

DROP TABLE IF EXISTS garfield_hgraph_end;
CREATE TABLE garfield_hgraph_end AS
SELECT source_id, publication_year 
FROM wos_publications WHERE source_id IN 
(select distinct wos_id from garfield_hgraph2) AND
publication_year <= 1992;

DROP TABLE IF EXISTS garfield_gen1;
CREATE TABLE garfield_gen1 AS
SELECT source_id AS source, cited_source_uid AS target,
'source'::varchar(10) AS stype, 'endref'::varchar(10) AS ttype
FROM wos_references WHERE cited_source_uid IN
(select source_id from garfield_hgraph_end);
CREATE INDEX garfield_gen1_idx ON garfield_gen1(source);

DROP TABLE IF EXISTS garfield_gen2;
CREATE TABLE garfield_gen2 AS
SELECT source_id AS source, cited_source_uid AS target,
'source'::varchar(10) AS stype, 'target'::varchar(10) AS ttype
FROM wos_references WHERE cited_source_uid IN
(select source from garfield_gen1);
CREATE INDEX garfield_gen2_idx ON garfield_gen2(source);

DROP TABLE IF EXISTS garfield_dmet_begina;
CREATE TABLE garfield_dmet_begina AS
SELECT source_id AS source, cited_source_uid AS target,
'startref'::varchar(10) AS stype, 'target'::varchar(10) AS ttype
FROM wos_references WHERE source_id IN 
(select wos_id from garfield_dmet3);
CREATE INDEX garfield_dmet_begina_idx on garfield_dmet_begina(target);

DROP TABLE IF EXISTS garfield_dmet_begin;
CREATE TABLE garfield_dmet_begin AS
SELECT a.* FROM garfield_dmet_begina a INNER JOIN
wos_publications b ON a.target=b.source_id;

DROP TABLE IF EXISTS garfield_node_assembly;
CREATE TABLE  garfield_node_assembly(node_id varchar(16),
node_name varchar(19),stype varchar(10),ttype varchar(10));

--build node_table
--gen1
INSERT INTO garfield_node_assembly(node_id,node_name,stype) 
SELECT 'n'||substring(source,5),source,stype
FROM garfield_gen1;

INSERT INTO garfield_node_assembly(node_id,node_name,ttype) 
SELECT 'n'||substring(target,5),target,ttype
FROM garfield_gen1;

--gen2
INSERT INTO garfield_node_assembly(node_id,node_name,stype) 
SELECT 'n'||substring(source,5),source,stype
FROM garfield_gen2;

INSERT INTO garfield_node_assembly(node_id,node_name,ttype) 
SELECT 'n'||substring(target,5),target,ttype
FROM garfield_gen2;

--garfield_dmet_begin
INSERT INTO garfield_node_assembly(node_id,node_name,stype) 
SELECT 'n'||substring(source,5),source,stype
FROM garfield_dmet_begin;

INSERT INTO garfield_node_assembly(node_id,node_name,ttype) 
SELECT 'n'||substring(target,5),target,ttype
FROM garfield_dmet_begin;
CREATE INDEX garfield_node_assembly_idx ON garfield_node_assembly(node_id);

DROP TABLE IF EXISTS garfield_nodelist;
CREATE TABLE garfield_nodelist AS
SELECT DISTINCT * FROM garfield_node_assembly;

--build edge_table
DROP TABLE IF EXISTS garfield_edge_table;
CREATE TABLE garfield_edge_table(snid varchar(19), tnid varchar(19), source varchar(19), target varchar(19),
stype varchar(10),ttype varchar(10));

INSERT INTO garfield_edge_table SELECT 'n'||substring(source,5) AS snid,
'n'||substring(target,5) as tnid, source, target, stype, ttype
FROM garfield_gen1;

INSERT INTO garfield_edge_table SELECT 'n'||substring(source,5) AS snid,
'n'||substring(target,5) as tnid, source, target, stype, ttype
FROM garfield_gen2;

INSERT INTO garfield_edge_table SELECT 'n'||substring(source,5) AS snid,
'n'||substring(target,5) as tnid, source, target, stype, ttype
FROM garfield_dmet_begin;
CREATE INDEX garfield_edge_table_idx ON garfield_edge_table(snid,tnid);

DROP TABLE IF EXISTS garfield_edgelist;
CREATE TABLE garfield_edgelist AS
SELECT DISTINCT * FROM garfield_edge_table
ORDER BY snid,tnid;

-- create formatted nodelist with unique node_ids
DROP TABLE IF EXISTS garfield_nodelist_formatted_a;
CREATE TABLE garfield_nodelist_formatted_a (node_id varchar(16), node_name varchar(19), stype varchar(10), ttype varchar(10), startref varchar(10), endref varchar(10));
INSERT INTO garfield_nodelist_formatted_a (node_id,node_name,stype,ttype) SELECT DISTINCT * FROM garfield_nodelist;			   
UPDATE garfield_nodelist_formatted_a SET startref=1 WHERE stype='startref';
UPDATE garfield_nodelist_formatted_a SET startref=0 WHERE stype='source' OR stype IS NULL;
UPDATE garfield_nodelist_formatted_a SET endref=1 WHERE ttype='endref';
UPDATE garfield_nodelist_formatted_a SET endref=0 WHERE ttype='target' OR ttype IS NULL;

DROP TABLE IF EXISTS garfield_nodelist_formatted_b;
CREATE TABLE garfield_nodelist_formatted_b AS
SELECT DISTINCT node_id, node_name, startref, endref FROM garfield_nodelist_formatted_a;
CREATE INDEX garfield_nodelist_formatted_b_idx ON garfield_nodelist_formatted_b(node_name);

DROP TABLE IF EXISTS garfield_nodelist_formatted_b_pmid;
CREATE TABLE garfield_nodelist_formatted_b_pmid AS
SELECT a.*,b.pmid_int FROM garfield_nodelist_formatted_b a 
LEFT JOIN wos_pmid_mapping b ON a.node_name=b.wos_id;

DROP TABLE IF EXISTS garfield_nodelist_formatted_b_pmid_grants;
CREATE TABLE garfield_nodelist_formatted_b_pmid_grants AS
SELECT a.*,b.project_number FROM garfield_nodelist_formatted_b_pmid a
LEFT JOIN exporter_publink b ON a.pmid_int=b.pmid::int;

ALTER TABLE garfield_nodelist_formatted_b_pmid_grants ADD COLUMN ic varchar(2);
ALTER TABLE garfield_nodelist_formatted_b_pmid_grants ADD COLUMN nida varchar(10);
ALTER TABLE garfield_nodelist_formatted_b_pmid_grants ADD COLUMN other_nih varchar(10);

UPDATE TABLE garfield_nodelist_formatted_b_pmid_grants SET ic=substring(project_number,4,2);
UPDATE TABLE garfield_nodelist_formatted_b_pmid_grants SET nida='1' WHERE ic='DA';
UPDATE TABLE garfield_nodelist_formatted_b_pmid_grants SET nida='0' WHERE nida IS NULL;
UPDATE TABLE garfield_nodelist_formatted_b_pmid_grants SET other_nih='1' WHERE ic IS NOT NULL AND nida='0';
UPDATE TABLE garfield_nodelist_formatted_b_pmid_grants SET other_nih='0' WHERE other_nih IS NULL;

DROP TABLE IF EXISTS garfield_nodelist_final;
CREATE TABLE garfield_nodelist_final AS
SELECT DISTINCT, node_id, node_name, startref, endref, nida, other_nih 
FROM garfield_nodelist_formatted_b_pmid_grants;

-- copy tables to /tmp for import
\copy garfield_nodelist_final TO  '/tmp/garfield_nodelist.csv' WITH (FORMAT CSV, HEADER, FORCE_QUOTE (node_name));

\copy garfield_edgelist TO '/tmp/garfield_edgelist.csv' WITH (FORMAT CSV, HEADER, FORCE_QUOTE (source,target));


