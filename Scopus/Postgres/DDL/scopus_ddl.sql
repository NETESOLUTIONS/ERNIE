\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

DROP TABLE IF EXISTS scopus_publication_groups CASCADE;

CREATE TABLE scopus_publication_groups (
  sgr BIGINT,
  pub_year SMALLINT,
  pub_date DATE,
  CONSTRAINT scopus_publication_groups_pk PRIMARY KEY (sgr) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

DROP TABLE IF EXISTS scopus_publications CASCADE;

CREATE TABLE scopus_publications (
  scp BIGINT
    CONSTRAINT scopus_publications_pk PRIMARY KEY USING INDEX TABLESPACE index_tbs,
  sgr BIGINT
    CONSTRAINT sp_sgr_fk REFERENCES scopus_publication_groups ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,

/*Element citation-language contains the language(s) of the original document. If the document
is published in parallel translation, up to three languages may be given.*/
--   language_code CHAR(3),

  citation_title TEXT,
  title_lang_code CHAR(3),
  --   abstract TEXT,
  --   abstract_lang_code CHAR(3),
  correspondence_person_indexed_name TEXT,
  correspondence_orgs TEXT,
  correspondence_city TEXT,
  correspondence_country TEXT,
  correspondence_e_address TEXT
) TABLESPACE scopus_tbs;

DROP TABLE IF EXISTS scopus_pub_authors CASCADE;

CREATE TABLE scopus_pub_authors (
  scp BIGINT
    CONSTRAINT spa_source_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  author_seq SMALLINT,
  auid BIGINT,
  author_indexed_name TEXT,
  author_surname TEXT,
  author_given_name TEXT,
  author_initials TEXT,
  author_e_address TEXT,
  CONSTRAINT scopus_pub_authors_pk PRIMARY KEY (scp, author_seq) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

DROP TABLE IF EXISTS scopus_references CASCADE;

CREATE TABLE scopus_references (
  scp BIGINT
    CONSTRAINT sr_source_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  ref_sgr BIGINT,
    -- FK is possible to enable only after the complete data load
    -- CONSTRAINT sr_ref_sgr_fk REFERENCES scopus_publication_groups ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  pub_ref_id SMALLINT,
  CONSTRAINT scopus_references_pk PRIMARY KEY (scp, ref_sgr, pub_ref_id) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;
