\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE TABLE IF NOT EXISTS wos_issn_stats (
  issn CHAR(9)
    CONSTRAINT wos_issn_stats_pk PRIMARY KEY USING INDEX TABLESPACE index_tbs,
  publication_count INTEGER
) TABLESPACE wos_tbs;