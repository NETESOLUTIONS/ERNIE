-- script to develop discoverx networks
-- 3/4/2018
-- Author: George Chacko

-- Pubmed keyword  for "DiscoverX"
DROP TABLE IF EXISTS disc_pubmed_search;
CREATE TABLE disc_pubmed_search(pmid int);
\COPY disc_pubmed_search FROM '~/ERNIE/Analysis/discoverx/discoverx.csv' CSV DELIMITER ',';

-- Pubmed PI search
DROP TABLE IF EXISTS  disc_pi_search;
CREATE TABLE disc_pi_search (pmid int);
\COPY disc_pi_search FROM '~/ERNIE/Analysis/discoverx/discoverx_eglen_olson_khanna_berg.csv' CSV DELIMITER ',';

-- NIH ExPORTER Search
DROP TABLE IF EXISTS disc_exporter_search;
CREATE TABLE disc_exporter_search (project_num varchar(15));
\COPY disc_exporter_search FROM '~/ERNIE/Analysis/discoverx/disc_exporter.csv' CSV DELIMITER ',';

-- NIH publink from ExPORTER
DROP TABLE IF EXISTS disc_exporter_search_pmid;
CREATE TABLE disc_exporter_search_pmid AS
SELECT a.project_num,b.pmid FROM disc_exporter_search a 
INNER JOIN exporter_publink b 
ON a.project_num=b.project_number;

-- Derwent Patent Search linked to wos_ids
DROP TABLE IF EXISTS disc_patent_search;
CREATE TABLE disc_patent_search AS
Select wos_id,patent_num_orig FROM  wos_patent_mapping 
WHERE patent_num_orig IN (select patent_num from derwent_assignees 
where lower(assignee_name) like 'discoverx%' or lower(assignee_name) like 'bioseek%');

-- combine into a seedset
DROP TABLE IF EXISTS disc_seedset_pmid;
CREATE TABLE disc_seedset_pmid AS
SELECT pmid FROM disc_pubmed_search UNION
SELECT pmid FROM disc_pi_search UNION 
SELECT pmid FROM disc_exporter_search_pmid;
DELETE FROM disc_seedset_pmid WHERE pmid IS NULL;
-- map to wos_ids
DROP TABLE IF EXISTS disc_seedset_pmid_wosid;
CREATE TABLE disc_seedset_pmid_wosid AS
SELECT a.pmid,b.wos_id FROM disc_seedset_pmid a
LEFT JOIN wos_pmid_mapping b ON a.pmid=b.pmid_int;

-- exclude patent_derived citation as an option
--insert wos_ids from patent search
-- INSERT INTO disc_seedset_pmid_wosid(wos_id)
-- SELECT wos_id FROM disc_patent_search;

-- generate citing references
DROP TABLE IF EXISTS disc_seedset_pmid_wosid_citing_gen1;
CREATE TABLE disc_seedset_pmid_wosid_citing_gen1 AS
SELECT DISTINCT a.*,b.source_id AS citing_gen1 
FROM disc_seedset_pmid_wosid a LEFT JOIN
wos_references b ON a.wos_id=b.cited_source_uid;

-- build edgelist (note flipped polarity)
DROP TABLE IF EXISTS disc_edgelist_final;
CREATE TABLE disc_edgelist_final AS
SELECT DISTINCT citing_gen1 as source, 'wos_id' as stype, wos_id as target, 'wos_id' as ttype
FROM disc_seedset_pmid_wosid_citing_gen1
WHERE citing_gen1 IS NOT NULL;

-- build nodelist
DROP TABLE IF EXISTS disc_nodelist_temp1;
CREATE TABLE disc_nodelist_temp1 AS
SELECT source as node FROM disc_edgelist_final UNION 
SELECT target FROM disc_edgelist;

-- add pmid
DROP TABLE IF EXISTS disc_nodelist_temp2;
CREATE TABLE disc_nodelist_temp2 AS
SELECT a.*,b.pmid_int AS pmid FROM disc_nodelist_temp1 a
LEFT JOIN wos_pmid_mapping b ON a.node=b.wos_id;

-- add NIH grant_support
DROP TABLE IF EXISTS disc_nodelist_temp3;
CREATE TABLE disc_nodelist_temp3 AS
SELECT
  a.node, 'wos_id'::varchar(10) AS ntype,
  EXISTS(SELECT 1
         FROM exporter_publink b
         WHERE a.pmid = b.pmid :: INT AND substring(b.project_number, 4, 2) = 'DA') AS nida_support,
  EXISTS(SELECT 1
         FROM exporter_publink b
         WHERE a.pmid = b.pmid :: INT AND substring(b.project_number, 4, 2) <> 'DA') AS other_hhs_support
FROM disc_nodelist_temp2 a;
CREATE INDEX disc_nodelist_temp3_idx ON disc_nodelist_temp3(node);

--add citations
DROP TABLE IF EXISTS disc_nodelist_temp4;
CREATE TABLE disc_nodelist_temp4 AS
SELECT DISTINCT a.node,count(b.source_id) AS total_citations FROM disc_nodelist_temp3 a
LEFT JOIN  wos_references b ON a.node=b.cited_source_uid GROUP BY a.node;;

-- add publication_year
DROP TABLE IF EXISTS disc_nodelist_temp5;
CREATE TABLE disc_nodelist_temp5 AS
SELECT DISTINCT a.*,b.publication_year 
FROM disc_nodelist_temp4 a 
LEFT JOIN wos_publications b ON a.node=b.source_id;

-- join templist3 and 5
DROP TABLE IF EXISTS disc_nodelist_final;
CREATE TABLE disc_nodelist_final AS
SELECT DISTINCT a.node,a.ntype,a.nida_support,a.other_hhs_support,b.total_citations,b.publication_year
FROM disc_nodelist_temp3 a LEFT JOIN disc_nodelist_temp5 b
ON a.node=b.node WHERE a.node IS NOT NULL;

COPY (
  SELECT node AS "node:ID",
    ntype AS "ntype:string",	 
    CAST(nida_support AS text) AS "nida_support:boolean",
    CAST(other_hhs_support AS text) AS "other_hhs_support:boolean",
    publication_year AS "publication_year:int",
    total_citations AS "total_citations:int"
  FROM disc_nodelist_final
) TO '/tmp/disc_nodelist_final.csv' WITH (FORMAT CSV, HEADER);

COPY (
  SELECT source AS ":START_ID",
    target AS ":END_ID"
  FROM disc_edgelist_final
) TO '/tmp/disc_edgelist_final.csv' WITH (FORMAT CSV, HEADER);

\copy disc_edgelist_final TO '~/ERNIE/Analysis/discoverx/disc_edgelist_final.csv' CSV HEADER DELIMITER ',';




