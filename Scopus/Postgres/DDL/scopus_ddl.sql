\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

DROP TABLE IF EXISTS scopus_publications;

CREATE TABLE scopus_publication_groups (
  sgr BIGINT,
  pub_year SMALLINT,
  pub_date DATE,
  CONSTRAINT scopus_publication_groups_pk PRIMARY KEY (sgr) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

DROP TABLE IF EXISTS scopus_publications;

CREATE TABLE scopus_publications (
  scp BIGINT
    CONSTRAINT scopus_publications_pk PRIMARY KEY USING INDEX TABLESPACE index_tbs,
  sgr BIGINT
    CONSTRAINT sp_sgr_fk REFERENCES scopus_publication_groups ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  language_code CHAR(3),
  citation_title TEXT,
  title_lang_code CHAR(3),
  abstract TEXT,
  abstract_lang_code CHAR(3)
) TABLESPACE scopus_tbs;

DROP TABLE IF EXISTS scopus_references sr;

CREATE TABLE scopus_references (
  source_scp BIGINT,
  ref_sgr BIGINT
    CONSTRAINT sr_ref_sgr_fk REFERENCES scopus_publication_groups ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT scopus_references_pk PRIMARY KEY (source_scp, ref_sgr) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;