\set ON_ERROR_STOP on
\set ECHO all

SET default_tablespace = wosdata_ssd_tbs;

CREATE TABLE del_wos_abstracts (
  id              INTEGER,
  source_id       VARCHAR(30),
  abstract_text   VARCHAR(4000),
  source_filename VARCHAR(200)
);

CREATE TABLE del_wos_addresses (
  id               INTEGER,
  source_id        VARCHAR(30),
  address_name     VARCHAR(300),
  organization     VARCHAR(400),
  sub_organization VARCHAR(400),
  city             VARCHAR(100),
  country          VARCHAR(100),
  zip_code         VARCHAR(20),
  source_filename  VARCHAR(200)
);

CREATE TABLE del_wos_authors (
  id              INTEGER,
  source_id       VARCHAR(30),
  full_name       VARCHAR(200),
  last_name       VARCHAR(200),
  first_name      VARCHAR(200),
  seq_no          INTEGER,
  address_seq     INTEGER,
  address         VARCHAR(500),
  email_address   VARCHAR(300),
  address_id      INTEGER,
  dais_id         VARCHAR(30),
  r_id            VARCHAR(30),
  source_filename VARCHAR(200)
);

CREATE TABLE del_wos_document_identifiers (
  id               INTEGER,
  source_id        VARCHAR(30),
  document_id      VARCHAR(100),
  document_id_type VARCHAR(30),
  source_filename  VARCHAR(200)
);

CREATE TABLE del_wos_grants (
  id                 INTEGER,
  source_id          VARCHAR(30),
  grant_number       VARCHAR(500),
  grant_organization VARCHAR(400),
  funding_ack        VARCHAR(4000),
  source_filename    VARCHAR(200)
);

CREATE TABLE del_wos_keywords (
  id              INTEGER,
  source_id       VARCHAR(30),
  keyword         VARCHAR(200),
  source_filename VARCHAR(200)
);

CREATE TABLE del_wos_publications (
  id                 INTEGER,
  source_id          VARCHAR(30),
  source_type        VARCHAR(20),
  source_title       VARCHAR(300),
  language           VARCHAR(20),
  document_title     VARCHAR(2000),
  document_type      VARCHAR(50),
  has_abstract       VARCHAR(5),
  issue              VARCHAR(10),
  volume             VARCHAR(20),
  begin_page         VARCHAR(30),
  end_page           VARCHAR(30),
  publisher_name     VARCHAR(200),
  publisher_address  VARCHAR(300),
  publication_year   VARCHAR(4),
  publication_date   DATE,
  created_date       DATE,
  last_modified_date DATE,
  edition            VARCHAR(40),
  source_filename    VARCHAR(200)
);

CREATE TABLE del_wos_references (
  wos_reference_id   INTEGER,
  source_id          VARCHAR(30),
  cited_source_uid   VARCHAR(30),
  cited_title        VARCHAR(8000),
  cited_work         VARCHAR(4000),
  cited_author       VARCHAR(1000),
  cited_year         VARCHAR(40),
  cited_page         VARCHAR(200),
  created_date       DATE,
  last_modified_date DATE,
  source_filename    VARCHAR(200)
);

CREATE TABLE del_wos_titles (
  id              INTEGER,
  source_id       VARCHAR(30),
  title           VARCHAR(2000),
  type            VARCHAR(100),
  source_filename VARCHAR(200)
);

CREATE TABLE uhs_wos_abstracts (
  id              INTEGER,
  source_id       VARCHAR(30),
  abstract_text   VARCHAR(4000),
  source_filename VARCHAR(200)
);

CREATE TABLE uhs_wos_addresses (
  id               INTEGER,
  source_id        VARCHAR(30),
  address_name     VARCHAR(300),
  organization     VARCHAR(400),
  sub_organization VARCHAR(400),
  city             VARCHAR(100),
  country          VARCHAR(100),
  zip_code         VARCHAR(20),
  source_filename  VARCHAR(200)
);

CREATE TABLE uhs_wos_authors (
  id              INTEGER,
  source_id       VARCHAR(30),
  full_name       VARCHAR(200),
  last_name       VARCHAR(200),
  first_name      VARCHAR(200),
  seq_no          INTEGER,
  address_seq     INTEGER,
  address         VARCHAR(500),
  email_address   VARCHAR(300),
  address_id      INTEGER,
  dais_id         VARCHAR(30),
  r_id            VARCHAR(30),
  source_filename VARCHAR(200)
);

CREATE TABLE uhs_wos_document_identifiers (
  id               INTEGER,
  source_id        VARCHAR(30),
  document_id      VARCHAR(100),
  document_id_type VARCHAR(30),
  source_filename  VARCHAR(200)
);

CREATE TABLE uhs_wos_grants (
  id                 INTEGER,
  source_id          VARCHAR(30),
  grant_number       VARCHAR(500),
  grant_organization VARCHAR(400),
  funding_ack        VARCHAR(4000),
  source_filename    VARCHAR(200)
);

CREATE TABLE uhs_wos_keywords (
  id              INTEGER,
  source_id       VARCHAR(30),
  keyword         VARCHAR(200),
  source_filename VARCHAR(200)
);

CREATE TABLE uhs_wos_publications (
  id                 INTEGER,
  source_id          VARCHAR(30),
  source_type        VARCHAR(20),
  source_title       VARCHAR(300),
  language           VARCHAR(20),
  document_title     VARCHAR(2000),
  document_type      VARCHAR(50),
  has_abstract       VARCHAR(5),
  issue              VARCHAR(10),
  volume             VARCHAR(20),
  begin_page         VARCHAR(30),
  end_page           VARCHAR(30),
  publisher_name     VARCHAR(200),
  publisher_address  VARCHAR(300),
  publication_year   VARCHAR(4),
  publication_date   DATE,
  created_date       DATE,
  last_modified_date DATE,
  edition            VARCHAR(40),
  source_filename    VARCHAR(200)
);

CREATE TABLE uhs_wos_references (
  wos_reference_id   INTEGER,
  source_id          VARCHAR(30),
  cited_source_uid   VARCHAR(30),
  cited_title        VARCHAR(8000),
  cited_work         VARCHAR(4000),
  cited_author       VARCHAR(1000),
  cited_year         VARCHAR(40),
  cited_page         VARCHAR(200),
  created_date       DATE,
  last_modified_date DATE,
  source_filename    VARCHAR(200)
);

CREATE TABLE uhs_wos_titles (
  id              INTEGER,
  source_id       VARCHAR(30),
  title           VARCHAR(2000),
  type            VARCHAR(100),
  source_filename VARCHAR(200)
);

CREATE TABLE wos_patent_mapping (
  wos_id         VARCHAR(30) NOT NULL,
  patent_num     VARCHAR(30) NOT NULL,
  patent_orig    VARCHAR(20),
  patent_country VARCHAR(2),
  CONSTRAINT wos_patent_mapping_pk
  PRIMARY KEY (patent_num, wos_id)
  USING INDEX TABLESPACE indexes
);

CREATE INDEX patent_orig_index
  ON wos_patent_mapping (patent_orig);

CREATE TABLE wos_pmid_manual_mapping (
  wos_uid  VARCHAR(30),
  pmid     VARCHAR(30),
  pmid_int INTEGER,
  details  TEXT
);

CREATE TABLE wos_pmid_mapping (
  wos_uid      VARCHAR(30)                                              NOT NULL
    CONSTRAINT wos_pmid_mapping_pk
    PRIMARY KEY
    USING INDEX TABLESPACE indexes,
  pmid         VARCHAR(30)                                              NOT NULL,
  pmid_int     INTEGER                                                  NOT NULL,
  wos_pmid_seq INTEGER DEFAULT nextval('wos_pmid_sequence' :: REGCLASS) NOT NULL
);

CREATE UNIQUE INDEX wpm_pmid_int_uk
  ON wos_pmid_mapping (pmid_int);

CREATE TABLE wos_document_identifiers (
  id               INTEGER,
  source_id        VARCHAR(30) NOT NULL,
  document_id      VARCHAR(100),
  document_id_type VARCHAR(30) NOT NULL,
  source_filename  VARCHAR(200)
);

CREATE UNIQUE INDEX wos_document_identifiers_uk
  ON wos_document_identifiers (source_id, document_id_type, document_id)
TABLESPACE indexes;

CREATE TABLE wos_titles (
  id              INTEGER,
  source_id       VARCHAR(30)   NOT NULL,
  title           VARCHAR(2000) NOT NULL,
  type            VARCHAR(100)  NOT NULL,
  source_filename VARCHAR(200),
  CONSTRAINT wos_titles_pk
  PRIMARY KEY (source_id, type)
  USING INDEX TABLESPACE indexes
);

CREATE TABLE wos_abstracts (
  id              INTEGER,
  source_id       VARCHAR(30),
  abstract_text   VARCHAR(4000),
  source_filename VARCHAR(200)
);

CREATE INDEX wos_abstracts_sourceid_index
  ON wos_abstracts (source_id)
TABLESPACE indexes;

CREATE TABLE wos_authors (
  id              INTEGER,
  source_id       VARCHAR(30) NOT NULL,
  full_name       VARCHAR(200),
  last_name       VARCHAR(200),
  first_name      VARCHAR(200),
  seq_no          INTEGER     NOT NULL,
  address_seq     INTEGER,
  address         VARCHAR(500),
  email_address   VARCHAR(300),
  address_id      INTEGER,
  dais_id         VARCHAR(30),
  r_id            VARCHAR(30),
  source_filename VARCHAR(200)
);

CREATE UNIQUE INDEX wos_authors_uk
  ON wos_authors (source_id, seq_no, address_id)
TABLESPACE indexes;

CREATE TABLE wos_keywords (
  id              INTEGER,
  source_id       VARCHAR(30)  NOT NULL,
  keyword         VARCHAR(200) NOT NULL,
  source_filename VARCHAR(200),
  CONSTRAINT wos_keywords_pk
  PRIMARY KEY (source_id, keyword)
  USING INDEX TABLESPACE indexes
);

CREATE TABLE wos_grants (
  id                 INTEGER,
  source_id          VARCHAR(30)  NOT NULL,
  grant_number       VARCHAR(500) NOT NULL,
  grant_organization VARCHAR(400),
  funding_ack        VARCHAR(4000),
  source_filename    VARCHAR(200)
);

CREATE UNIQUE INDEX wos_grants_uk
  ON wos_grants (source_id, grant_number, grant_organization)
TABLESPACE indexes;

CREATE INDEX wos_grant_source_id_index
  ON wos_grants (source_id)
TABLESPACE indexes;

CREATE TABLE wos_addresses (
  id               INTEGER,
  source_id        VARCHAR(30)  NOT NULL,
  address_name     VARCHAR(300) NOT NULL,
  organization     VARCHAR(400),
  sub_organization VARCHAR(400),
  city             VARCHAR(100),
  country          VARCHAR(100),
  zip_code         VARCHAR(20),
  source_filename  VARCHAR(200),
  CONSTRAINT wos_addresses_pk
  PRIMARY KEY (source_id, address_name)
  USING INDEX TABLESPACE indexes
);

CREATE TABLE wos_references (
  wos_reference_id   INTEGER,
  source_id          VARCHAR(30) NOT NULL,
  cited_source_uid   VARCHAR(30) NOT NULL,
  cited_title        VARCHAR(8000),
  cited_work         VARCHAR(8000),
  cited_author       VARCHAR(2000),
  cited_year         VARCHAR(40),
  cited_page         VARCHAR(200),
  created_date       DATE,
  last_modified_date DATE,
  source_filename    VARCHAR(200),
  CONSTRAINT wos_references_pk
  PRIMARY KEY (source_id, cited_source_uid)
  USING INDEX TABLESPACE indexes
);

CREATE INDEX ssd_ref_source_id_index2
  ON wos_references (cited_source_uid, source_id);

CREATE TABLE wos_publications (
  begin_page         VARCHAR(30),
  created_date       DATE        NOT NULL,
  document_title     VARCHAR(2000),
  document_type      VARCHAR(50) NOT NULL,
  edition            VARCHAR(40) NOT NULL,
  end_page           VARCHAR(30),
  has_abstract       VARCHAR(5)  NOT NULL,
  id                 INTEGER,
  issue              VARCHAR(10),
  language           VARCHAR(20) NOT NULL,
  last_modified_date DATE        NOT NULL,
  publication_date   DATE        NOT NULL,
  publication_year   INTEGER     NOT NULL,
  publisher_address  VARCHAR(300),
  publisher_name     VARCHAR(200),
  source_filename    VARCHAR(200),
  source_id          VARCHAR(30) NOT NULL
    CONSTRAINT wos_publications_pk
    PRIMARY KEY
    USING INDEX TABLESPACE indexes,
  source_title       VARCHAR(300),
  source_type        VARCHAR(20) NOT NULL,
  volume             VARCHAR(20)
);

CREATE INDEX wos_publications_publication_year_i
  ON wos_publications(publication_year)
TABLESPACE indexes;