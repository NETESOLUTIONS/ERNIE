\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE TABLE dataset_stats (
  year INT
    CONSTRAINT dataset_stats_pk PRIMARY KEY USING INDEX TABLESPACE index_tbs,
  unique_source_id_count INT,
  unique_cited_id_count INT,
  cited_id_count INT
);