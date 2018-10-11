-- Script to load wos_patent_mapping data from Clarivate
-- George Chacko, Oct 12, 2017

DROP TABLE IF EXISTS wos_patent_mapping;
drop table IF EXISTS wos_patent_mapping_t1;
CREATE TABLE  wos_patent_mapping_t1 (
temp varchar(19), 
patent_no varchar(30),
wos_id varchar(19),
country varchar(2)) tablespace wos;

-- INSERT PATHED FILE REFERENCE FOR SOURCE FILE
\COPY wos_patent_mapping_t1(temp,patent_no) FROM '/erniedev_data8/wos_pat_.csv' DELIMITER ',' CSV;
UPDATE wos_patent_mapping_t1 SET wos_id='WOS:'||temp;
UPDATE wos_patent_mapping_t1 SET country=substring(patent_no,1,2);
ALTER TABLE  wos_patent_mapping_t1 DROP COLUMN temp ;
CREATE INDEX wos_patent_mapping_idx 
ON wos_patent_mapping_t1(wos_id) TABLESPACE index_tbs ;

-- JOIN WITH DERWENT PATENTS 
CREATE TABLE wos_patent_mapping AS
SELECT distinct a.wos_id, a.patent_no,b.patent_num_orig,
b.patent_num_wila,b.patent_num_tsip,a.country 
FROM wos_patent_mapping_t1 a LEFT JOIN derwent_patents b 
ON substring(a.patent_no,3)=b.patent_num_wila;

CREATE INDEX wos_patent_mapping_wos_id_idx ON wos_patent_mapping (patent_no) TABLESPACE index_tbs;
CREATE INDEX wos_patent_mapping_patent_no_idx ON wos_patent_mapping (patent_no) TABLESPACE index_tbs;
-- ELiminate matches with non-US patents
UPDATE wos_patent_mapping set patent_num_orig=null,,patent_num_wila = null,
patent_num_tsip=null where country!='US';

alter table wos_patent_mapping owner to ernie_admin;
drop table wos_patent_mapping_t1;





