\set ON_ERROR_STOP on
\set ECHO all 

--  Script to extract relevant data for Generic csv input of wosIDs
--  Author: George Chacko 12/29/2017
--  Either replace generic with case study name or rename case-study input file with generic
--  The output of this file should be passed to the .R batch file in the same Github folder
--  The output of the .R file (tab delimited) should be passed to Samet's Network Analyzer


\timing
DROP TABLE IF EXISTS generic1;
CREATE TABLE generic1(source VARCHAR, pmid VARCHAR, trimmed_pmid INT,wosid VARCHAR, matched_wosuid VARCHAR, matched_pmid INT);
\COPY GENERIC1 FROM '/home/chackoge/generic_enriched.csv' CSV HEADER DELIMITER ',';

-- merge wosids
ALTER TABLE generic1 ADD COLUMN merged_wosids varchar(30);
UPDATE generic1 SET merged_wosids=matched_wosuid;
UPDATE generic1 SET merged_wosids=wosid WHERE matched_wosuid IS NULL;

-- merge pmids
ALTER TABLE generic1 ADD COLUMN merged_pmids varchar(30);
UPDATE generic1 SET merged_pmids=trimmed_pmid;
UPDATE generic1 SET merged_pmids=matched_pmid WHERE trimmed_pmid IS NULL;

-- extract first generation of citing references
DROP TABLE IF EXISTS generic2;
CREATE TABLE generic2 AS
SELECT DISTINCT a.merged_wosids,b.source_id AS citing_wosids_gen1 
FROM generic1 a INNER JOIN wos_references b ON 
a.merged_wosids=b.cited_source_uid;

CREATE INDEX generic2_idx on generic2(citing_wosids_gen1);
ANALYZE generic2;

EXPLAIN SELECT DISTINCT a.*,b.source_id AS citing_wosids_gen2 
FROM generic2 a INNER JOIN
wos_references b ON a.citing_wosids_gen1=b.cited_source_uid;

DROP TABLE IF EXISTS generic3;
CREATE TABLE generic3 AS
SELECT DISTINCT a.*,b.source_id AS citing_wosids_gen2 
FROM generic2 a INNER JOIN wos_references b 
ON a.citing_wosids_gen1=b.cited_source_uid;

CREATE INDEX generic3_idx on generic3(citing_wosids_gen2);

DROP TABLE IF EXISTS generic4;
CREATE TABLE generic4 AS
SELECT a.*,b.pmid_int AS citing_pmids_gen1 FROM generic3 a
LEFT JOIN wos_pmid_mapping b ON
a.citing_wosids_gen1=b.wos_uid;

DROP TABLE IF EXISTS generic5;
CREATE TABLE generic5 AS
SELECT a.*,b.pmid_int AS citing_pmids_gen2 FROM generic4 a
LEFT JOIN wos_pmid_mapping b ON
a.citing_wosids_gen2=b.wos_uid
ORDER BY merged_wosids, citing_wosids_gen1;

CREATE INDEX citing_pmids_gen1_idx on generic5(citing_pmids_gen1);
CREATE INDEX citing_pmids_gen2_idx on generic5(citing_pmids_gen2);


DROP TABLE IF EXISTS generic6;
CREATE TABLE generic6 AS
SELECT a.*,b.core_project_num AS grants_gen1 FROM generic5 a
LEFT JOIN spires_pub_projects b on 
a.citing_pmids_gen1=b.pmid;

DROP TABLE IF EXISTS generic7;
CREATE TABLE generic7 AS
SELECT a.*,b.core_project_num AS grants_gen2 FROM generic6 a
LEFT JOIN spires_pub_projects b on 
a.citing_pmids_gen2=b.pmid;

DROP TABLE IF EXISTS generic8;
CREATE TABLE generic8 AS SELECT merged_wosids AS all_wosids FROM generic7 
UNION SELECT citing_wosids_gen1 FROM generic7 
UNION SELECT citing_wosids_gen2 from generic7;

CREATE INDEX all_wosids_idx ON generic8(all_wosids);

DROP TABLE IF EXISTS generic9;
CREATE TABLE generic9 AS SELECT a.all_wosids,b.source_id FROM generic8 a 
INNER JOIN wos_references b ON a.all_wosids=b.cited_source_uid 
WHERE b.source_id in (select all_wosids from generic8);

CREATE INDEX generic9_all_wosids_idx ON generic9(all_wosids);

DROP TABLE IF EXISTS generic10;
CREATE TABLE generic10 AS 
SELECT a.all_wosids,b.full_name FROM generic9 a
INNER JOIN wos_authors b on a.all_wosids=b.source_id;

-- switching to Samet's floating point world....

DROP TABLE IF EXISTS generic91;
CREATE TABLE  generic91 AS SELECT source_id AS SOURCE,
'wosid1'::varchar(10) AS stype, all_wosids AS target, 
'wosid2'::varchar(10) AS ttype FROM  generic9;

DROP TABLE IF EXISTS generic11;
CREATE TABLE generic11 AS SELECT DISTINCT  * from generic10;

DROP TABLE IF EXISTS generic111;
CREATE TABLE  generic111 AS SELECT DISTINCT all_wosids 
AS SOURCE, 'wos_id'::varchar(10) as stype, full_name as target, 
'author' as ttype from generic10;

DROP TABLE IF EXISTS generic12;
CREATE TABLE  generic12 AS
SELECT * from generic91
UNION SELECT  * FROM generic111;

DROP TABLE IF EXISTS generic_final;
CREATE TABLE generic_final (id serial, source varchar(30), stype varchar(30),
target varchar(100),ttype varchar(30));

INSERT INTO generic_final (source,stype,target,ttype) SELECT * from  generic12; 
\COPY generic_final TO '/tmp/generic_final.csv' CSV HEADER;


