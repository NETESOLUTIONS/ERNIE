\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE TABLE wos_publication_stats (
  source_id VARCHAR(30)
    CONSTRAINT wos_publication_stats_pk PRIMARY KEY USING INDEX TABLESPACE index_tbs,wos_document_identifiers
  disruption_i INTEGER,
  disruption_j INTEGER,
  disruption_k INTEGER,
  disruption FLOAT
) TABLESPACE wos_tbs;

COMMENT ON TABLE wos_publication_stats IS 'Statistics for select WoS publications';