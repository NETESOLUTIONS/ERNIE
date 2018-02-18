-- script to load affymetrix data into neo4j
-- Author: George Chacko 2/18/2018
-- see accompanying shell script that shuts neo4j down, loads data, and starts it up again

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

