\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
SET search_path TO public;

-- region failed_files_lexis_nexis
DROP TABLE IF EXISTS failed_files_lexis_nexis CASCADE;
CREATE TABLE failed_files_lexis_nexis (
  xml_filename TEXT NOT NULL,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT failed_files_lexis_nexis_pk PRIMARY KEY (xml_filename) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;
COMMENT ON TABLE failed_files_lexis_nexis IS 'Log of XML files which failed parsing';
COMMENT ON COLUMN failed_files_lexis_nexis.xml_filename IS 'XML filename';
COMMENT ON COLUMN failed_files_lexis_nexis.last_updated_time IS 'ERNIE last updated time;
