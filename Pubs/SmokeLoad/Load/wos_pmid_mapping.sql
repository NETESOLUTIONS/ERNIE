-- Script to load wos_pmid_mapping data from Clarivate
-- George Chacko, Oct 13, 2017
-- Is not parameterized like annual_wos_pmid_load.sql, which should not be used 
-- until it's made compatible with ERNIE

DROP TABLE IF EXISTS wos_pmid_mapping;

CREATE TABLE wos_pmid_mapping (
  wos_id   VARCHAR(19),
  pmid     VARCHAR,
  pmid_int INT
) TABLESPACE wos_tbs;

-- INSERT PATHED FILE REFERENCE FOR SOURCE FILE
\COPY wos_pmid_mapping (wos_id,pmid)
FROM '/tmp/wos_pmid.csv' HEADER DELIMITER ',' CSV;
UPDATE wos_pmid_mapping
SET pmid_int = substring(pmid, 9) :: INT;

CREATE INDEX wos_pmid_mapping_wos_id_idx
  ON wos_pmid_mapping (wos_id, pmid_int) TABLESPACE index_tbs;
CREATE INDEX wos_pmid_mapping_pmid_idx
  ON wos_pmid_mapping (pmid_int, wos_id) TABLESPACE index_tbs;
ALTER TABLE wos_pmid_mapping
  OWNER TO ernie_admin;


