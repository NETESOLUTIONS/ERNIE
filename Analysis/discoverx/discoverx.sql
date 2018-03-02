-- script to develop discoverx networks
-- 3/1/2018
-- Author: George Chacko

-- Pubmed Search for "DiscoverX"
DROP TABLE IF EXISTS disc_pubmed_search;
CREATE TABLE disc_pubmed_search(pmid int);
\COPY disc_pubmed_search FROM '~/ERNIE/Analysis/discoverx/discoverx' CSV DELIMITER ',';

DROP TABLE IF EXISTS  disc_pi_search;
CREATE TABLE disc_pi_search (pmid int);
\COPY disc_pi_search FROM '~/ERNIE/Analysis/discoverx/discoverx_eglen_olson_khanna_berg' CSV DELIMITER ',';

-- combine into a seedset
DROP TABLE IF EXISTS disc_seedset_pmid;
CREATE TABLE disc_seedset_pmid AS
SELECT pmid FROM disc_pubmed_search UNION
SELECT pmid FROM disc_pi_search;

-- map to wos_ids
DROP TABLE IF EXISTS disc_seedset_pmid_wosid;
CREATE TABLE disc_seedset_pmid_wosid AS
SELECT a.pmid,b.wos_id FROM disc_seedset_pmid a
LEFT JOIN wos_pmid_mapping b ON a.pmid=b.pmid_int;

-- generate citing references
DROP TABLE IF EXISTS disc_seedset_pmid_wosid_citing_gen1;
CREATE TABLE disc_seedset_pmid_wosid_citing_gen1 AS
SELECT a.*,b.source_id AS citing_gen1 
FROM disc_seedset_pmid_wosid a LEFT JOIN
wos_references b ON a.wos_id=b.cited_source_uid;

-- build edgelist (note flipped polarity)
DROP TABLE IF EXISTS disc_edgelist;
CREATE TABLE disc_edgelist AS
SELECT DISTINCT citing_gen1 as source, 'wos_id' as stype, wos_id as target, 'wos_id' as ttype
FROM disc_seedset_pmid_wosid_citing_gen1;

-- build nodelist
DROP TABLE IF EXISTS disc_nodelist_temp1;
CREATE TABLE disc_nodelist_temp1 AS
SELECT source as node FROM disc_edgelist UNION 
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
  FROM disc_edgelist
) TO '/tmp/disc_edgelist_final.csv' WITH (FORMAT CSV, HEADER);





