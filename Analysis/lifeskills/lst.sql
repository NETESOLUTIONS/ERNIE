-- script to assemble a nodelist and edgelist for a graph spanning the President's report on 
-- combating addiction and the LST dataset.
-- Author George Chacko 2/26/2018

-- Assemble Trump report citations, WSIPP, and Surgeon General data  (Didi Cross and George Chacko)
-- Load all_wosids and all_pmids

-- data from Trump Commission Report
DROP TABLE IF EXISTS pcreport_start;
CREATE TABLE pcreport_start (wos_id varchar(19));
\COPY pcreport_start (wos_id) FROM '~/ERNIE/Analysis/lifeskills/trump_wosids.csv' CSV HEADER DELIMITER ',';

--data from Surgeon General's Report
DROP TABLE IF EXISTS sg_start;
CREATE TABLE sg_start (wos_id varchar(19));
\COPY sg_start (wos_id) FROM '~/ERNIE/Analysis/lifeskills/sg_80thp_wosid.csv' CSV HEADER DELIMITER ',';

-- data from WSIPP report
DROP TABLE IF EXISTS wsipp_start;
CREATE  TABLE wsipp_start (pmid int);
\copy wsipp_start(pmid) FROM '~/ERNIE/Analysis/lifeskills/wsipp_pmid.csv' CSV HEADER DELIMITER ',';

-- all scraped wosids
DROP TABLE IF EXISTS lst_wosids;
CREATE TABLE lst_wosids (wos_id varchar(19));
\copy lst_wosids FROM '~/ERNIE/Analysis/lifeskills/lst_wosid' CSV HEADER DELIMITER ',';

-- all scraped pmids 
DROP TABLE IF EXISTS lst_pmids;
CREATE TABLE lst_pmids (pmid varchar(19));
\copy lst_pmids FROM '~/ERNIE/Analysis/lifeskills/lst_pmid' CSV HEADER DELIMITER ',';

-- merge wos_ids and pmids
DROP TABLE IF EXISTS lst_pmids_wosids;
CREATE TABLE lst_pmids_wosids (pmid int, wos_id varchar(19));
INSERT INTO lst_pmids_wosids(pmid) 
SELECT DISTINCT pmid::int FROM lst_pmids;
INSERT INTO lst_pmids_wosids(wos_id) 
SELECT DISTINCT wos_id FROM lst_wosids;

DROP TABLE IF EXISTS lst_interim;
CREATE TABLE lst_interim AS
SELECT a.*,b.wos_id as matching_wos_id 
FROM lst_pmids_wosids a LEFT JOIN wos_pmid_mapping b
ON a.pmid::int=b.pmid_int;
ALTER TABLE lst_interim ADD COLUMN merged_wos_id varchar(19);
UPDATE lst_interim SET merged_wos_id=coalesce(wos_id,matching_wos_id);

DROP TABLE IF EXISTS lst_all;
CREATE TABLE lst_all AS
SELECT DISTINCT merged_wos_id from lst_interim;
CREATE INDEX lst_all_idx on lst_all(merged_wos_id);

-- get citing references
DROP TABLE IF EXISTS lst_citing;
CREATE TABLE lst_citing AS
SELECT a.merged_wos_id AS wosid, b.source_id as citing_gen1
FROM lst_all a INNER JOIN wos_references b ON
a.merged_wos_id=b.cited_source_uid;

--create edgelist
DROP TABLE IF EXISTS lst_edgelist;
CREATE TABLE lst_edgelist (source varchar(19),stype varchar(10),target varchar(19),ttype varchar(10));
-- note source target assignments since citing is source
INSERT INTO lst_edgelist
SELECT citing_gen1 AS source, 'wos_id', wosid AS target, 'wos_id' as ttype FROM lst_citing;
INSERT INTO lst_edgelist
SELECT 'wsipp' AS source,'policy' AS stype, wos_id AS target,'wos_id' AS ttype 
FROM wos_pmid_mapping WHERE pmid_int IN (select  pmid from wsipp_start);
INSERT INTO lst_edgelist
SELECT 'white_house' AS source, 'policy' AS stype,wos_id as target, 'wos_id' AS ttype FROM pcreport_start;
INSERT INTO lst_edgelist
SELECT 'surgeon_general' AS source, 'policy' AS stype,wos_id as target, 'wos_id' AS ttype FROM sg_start;

DROP TABLE IF EXISTS lst_edgelist_final;
CREATE TABLE lst_edgelist_final AS
SELECT DISTINCT * FROM lst_edgelist;

-- create nodelist
DROP TABLE IF EXISTS lst_nodelist;
CREATE TABLE lst_nodelist (node varchar(19), ntype varchar(10));
INSERT INTO lst_nodelist
SELECT source, stype FROM lst_edgelist;
INSERT INTO lst_nodelist
SELECT target, ttype FROM lst_edgelist;

DROP TABLE IF EXISTS lst_nodelist_final;
CREATE TABLE lst_nodelist_final AS
SELECT DISTINCT * FROM lst_nodelist;

-- CONNECT TO NIH GRANTS
DROP TABLE IF EXISTS grant_tmp;
CREATE TABLE grant_tmp AS
SELECT a.node,a.ntype,b.pmid_int FROM lst_nodelist_final a
LEFT JOIN wos_pmid_mapping b ON
a.node=b.wos_id;
CREATE INDEX grant_tmp_idx ON grant_tmp(pmid_int);

DROP TABLE IF EXISTS lst_nodelist_final_grants;
CREATE TABLE lst_nodelist_final_grants AS
SELECT
  a.*,
  EXISTS(SELECT 1
         FROM exporter_publink b
         WHERE a.pmid_int = b.pmid :: INT AND substring(b.project_number, 4, 2) = 'DA') AS nida_support,
  EXISTS(SELECT 1
         FROM exporter_publink b
         WHERE a.pmid_int = b.pmid :: INT AND substring(b.project_number, 4, 2) <> 'DA') AS other_hhs_support
FROM grant_tmp a;
CREATE INDEX lst_nodelist_final_grants_idx On lst_nodelist_final_grants(node);
-- add citations as an atttribute

DROP TABLE IF EXISTS lst_final_nodelist_grants_citations_a;
CREATE TABLE lst_final_nodelist_grants_citations_a AS
SELECT a.node,count(b.source_id) as total_citations 
FROM lst_nodelist_final_grants a
LEFT JOIN wos_references b ON a.node=b.cited_source_uid
GROUP BY a.node;

DROP TABLE IF EXISTS lst_final_nodelist_grants_citations;
CREATE TABLE lst_final_nodelist_grants_citations AS
SELECT DISTINCT a.*,b.total_citations FROM lst_nodelist_final_grants a
LEFT JOIN lst_final_nodelist_grants_citations_a b ON a.node=b.node;

DROP TABLE IF EXISTS lst_final_nodelist_grants_citations_years;
CREATE TABLE lst_final_nodelist_grants_citations_years AS
SELECT a.*,b.publication_year FROM lst_final_nodelist_grants_citations a
LEFT JOIN wos_publications b on a.node=b.source_id;

COPY (
  SELECT node AS "node:ID",
    ntype AS "ntype:string",	 
    CAST(nida_support AS text) AS "nida_support:boolean",
    CAST(other_hhs_support AS text) AS "other_hhs_support:boolean",
    publication_year AS "publication_year:int",
    total_citations AS "total_citations:int"
  FROM lst_final_nodelist_grants_citations_years
) TO '/tmp/lst_nodelist_final.csv' WITH (FORMAT CSV, HEADER);

COPY (
  SELECT source AS ":START_ID",
    target AS ":END_ID"
  FROM lst_edgelist_final
) TO '/tmp/lst_edgelist_final.csv' WITH (FORMAT CSV, HEADER);


