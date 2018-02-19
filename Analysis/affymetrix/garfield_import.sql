<<<<<<< HEAD
-- revised simplified version of garfield trace data to DMET
DROP TABLE IF EXISTS garfield_hgraph_end;
CREATE TABLE garfield_hgraph_end AS
SELECT source_id, publication_year 
FROM wos_publications WHERE source_id IN 
(select distinct wos_id from garfield_hgraph2) AND
publication_year <= 1992;

DROP TABLE IF EXISTS garfield_gen1;
CREATE TABLE garfield_gen1 AS
SELECT source_id AS source, cited_source_uid AS target,
'pub'::varchar(10) AS pub, 'endref'::varchar(10) AS ref
FROM wos_references WHERE cited_source_uid IN
(select source_id from garfield_hgraph_end);
CREATE INDEX garfield_gen1_idx ON garfield_gen1(pub);

DROP TABLE IF EXISTS garfield_gen2;
CREATE TABLE garfield_gen2 AS
SELECT source_id AS source, cited_source_uid AS target,
'pub'::varchar(10) AS pub, 'ref'::varchar(10) AS ref
FROM wos_references WHERE cited_source_uid IN
(select source from garfield_gen1);
CREATE INDEX garfield_gen2_idx ON garfield_gen2(pub);

DROP TABLE IF EXISTS garfield_dmet_begina;
CREATE TABLE garfield_dmet_begina AS
SELECT source_id AS source, cited_source_uid AS target,
'startpub'::varchar(10) AS pub, 'ref'::varchar(10) AS ref
FROM wos_references WHERE source_id IN 
(select wos_id from garfield_dmet3);
CREATE INDEX garfield_dmet_begina_idx on garfield_dmet_begina(target);

DROP TABLE IF EXISTS garfield_dmet_begin;
CREATE TABLE garfield_dmet_begin AS
SELECT a.* FROM garfield_dmet_begina a INNER JOIN
wos_publications b ON a.target=b.source_id;

DROP TABLE IF EXISTS garfield_node_assembly;
CREATE TABLE  garfield_node_assembly(node_id varchar(16),
node_name varchar(19),pub varchar(10),ref varchar(10));

--build node_table
--gen1
INSERT INTO garfield_node_assembly(node_id,node_name,pub,ref) 
SELECT 'n'||substring(source,5),source,pub,'none' 
AS ref FROM garfield_gen1;

INSERT INTO garfield_node_assembly(node_id,node_name,pub,ref) 
SELECT 'n'||substring(target,5),target,'none' 
AS ref, ref FROM garfield_gen1;

--gen2
INSERT INTO garfield_node_assembly(node_id,node_name,pub,ref) 
SELECT 'n'||substring(source,5),source,pub,'none' 
AS ref FROM garfield_gen2;

INSERT INTO garfield_node_assembly(node_id,node_name,pub,ref) 
SELECT 'n'||substring(target,5),target,'none' 
AS ref, ref FROM garfield_gen2;

--garfield_dmet_begin
INSERT INTO garfield_node_assembly(node_id,node_name,pub,ref) 
SELECT 'n'||substring(source,5),source,pub,'none' 
AS ref FROM garfield_dmet_begin;

INSERT INTO garfield_node_assembly(node_id,node_name,pub,ref) 
SELECT 'n'||substring(target,5),target,'none' 
AS ref, ref FROM garfield_dmet_begin;
CREATE INDEX garfield_node_assembly_idx ON garfield_node_assembly(node_id);

DROP TABLE IF EXISTS garfield_nodelist;
CREATE TABLE garfield_nodelist AS
SELECT DISTINCT * FROM garfield_node_assembly;

--build edge_table
DROP TABLE IF EXISTS garfield_edge_table;
CREATE TABLE garfield_edge_table(start_id varchar(16), end_id varchar(17),
source varchar(19),target varchar(19), type varchar(10));

INSERT INTO garfield_edge_table SELECT 'n'||substring(source,5) AS start_id,
'n'||substring(target,5) as end_ID, source, target, 'cites' AS type 
FROM garfield_gen1;

INSERT INTO garfield_edge_table SELECT 'n'||substring(source,5) AS start_id,
'n'||substring(target,5) as end_ID, source, target, 'cites' AS type 
FROM garfield_gen2;

INSERT INTO garfield_edge_table SELECT 'n'||substring(source,5) AS start_id,
'n'||substring(target,5) as end_ID, source, target, 'cites' AS type 
FROM garfield_dmet_begin;

CREATE INDEX garfield_edge_table_idx ON garfield_edge_table(start_id,end_id);

DROP TABLE IF EXISTS garfield_edgelist;
CREATE TABLE garfield_edgelist AS
SELECT DISTINCT * FROM garfield_edge_table
ORDER BY start_id, end_id;

-- copy tables to /tmp for import
\copy garfield_nodelist TO  '/tmp/garfield_nodelist.csv' WITH (FORMAT CSV, HEADER, FORCE_QUOTE (node_name));

\copy garfield_edgelist TO '/tmp/garfield_edgelist.csv' WITH (FORMAT CSV, HEADER, FORCE_QUOTE (source,target));










=======
-- script to load affymetrix data into neo4j
-- Author: George Chacko 2/18/2018
-- see accompanying instruction file garfield_neo4j* that shuts neo4j down, loads data, and starts it up again

drop table if exists garfield_beginning;
create table garfield_beginning AS
SELECT citing_gen1 AS source, wos_id as target,'citing_gen1'::varchar(15) AS stype,
'wos_id_b'::varchar(15) AS ttype from garfield_hgraph4 where citing_gen1 is not null 
AND wos_id is not null;

drop table if exists garfield_intermediate;
create table garfield_intermediate AS
SELECT citing_gen2 AS source, citing_gen1 as target,'citing_gen2'::varchar(15) 
AS stype,'citing_gen1'::varchar(15) AS ttype 
FROM garfield_hgraph4 where citing_gen2 is not null 
AND citing_gen1 is not null;

drop table if exists garfield_dmet4;
create table garfield_dmet4 as select * from garfield_dmet3 
where length(cited_gen1) = 19;

drop table if exists garfield_end;
create table garfield_end AS
select wos_id as source, cited_gen1 as target, 'wos_id_e'::varchar(15) as stype,
'cited_gen1'::varchar(15) as ttype from garfield_dmet4;

drop table if exists garfield_all;
create table garfield_all as select * from garfield_beginning union select * from garfield_intermediate union select * from garfield_end;

drop table if exists garfield_nodes;
create table garfield_nodes as select distinct 'publication' as ntype, *  
from (select source as node from garfield_all where source is not null  union select target as node from garfield_all where target is not null )c;

\copy garfield_nodes to '/tmp/garfield_nodes.csv' with (FORMAT CSV, HEADER TRUE, FORCE_QUOTE *);
\copy garfield_all to '/tmp/garfield_all.csv' with (FORMAT CSV, HEADER TRUE, FORCE_QUOTE *);

drop table if exists garfield_nodes_ID;
create table garfield_nodes_ID as select 'n'||substring(node,5) as "node_ID",* from garfield_nodes;
\copy garfield_nodes_ID to '/tmp/garfield_nodes_ID.csv' WITH (FORMAT CSV, HEADER, FORCE_QUOTE (node));

drop table if exists garfield_all_ID;
create table garfield_all_ID as select 'n'||substring(source,5) 
AS "START_ID",'n'||substring(target,5) 
AS "END_ID", 'cites'::varchar(15) as ":TYPE",* from garfield_all;
\copy garfield_all_ID to '/tmp/garfield_all_ID.csv' WITH (FORMAT CSV, HEADER, FORCE_QUOTE (source,target));
>>>>>>> d3908df6ee043d94c2eeca730912182607ea1f77

