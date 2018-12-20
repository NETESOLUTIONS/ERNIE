\set ON_ERROR_STOP on
\set ECHO all

SET default_tablespace = wos_tbs;

-- region Main tables
CREATE TABLE IF NOT EXISTS wos_document_identifiers (
  id                SERIAL,
  source_id         VARCHAR(30)  NOT NULL DEFAULT '',
  document_id       VARCHAR(100) NOT NULL DEFAULT '',
  document_id_type  VARCHAR(30)  NOT NULL DEFAULT '',
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP             DEFAULT current_timestamp,
  CONSTRAINT wos_document_identifiers_pk PRIMARY KEY (source_id, document_id_type, document_id)
) TABLESPACE wos_tbs;

-- 48m:56s
CREATE INDEX IF NOT EXISTS wdi_document_id_type_document_id_i
  ON wos_document_identifiers (document_id_type, document_id) TABLESPACE index_tbs;

COMMENT ON TABLE wos_document_identifiers
IS 'Thomson Reuters: WoS - WoS document identifiers of publications such as doi';

COMMENT ON COLUMN wos_document_identifiers.id
IS ' Example: 1';

COMMENT ON COLUMN wos_document_identifiers.source_id
IS 'UT. Example: WOS:000354914100020';

COMMENT ON COLUMN wos_document_identifiers.document_id
IS ' Example: CI7AA';

COMMENT ON COLUMN wos_document_identifiers.document_id_type
IS 'accession_no/issn/eissn/doi/eisbn/art_no etc.. Example: doi';

COMMENT ON COLUMN wos_document_identifiers.source_filename
IS 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';

CREATE TABLE wos_titles (
  id                SERIAL,
  source_id         VARCHAR(30)   NOT NULL,
  title             VARCHAR(2000) NOT NULL,
  type              VARCHAR(100)  NOT NULL,
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP DEFAULT current_timestamp,
  CONSTRAINT wos_titles_pk PRIMARY KEY (source_id, type) USING INDEX TABLESPACE index_tbs
) TABLESPACE wos_tbs;

COMMENT ON TABLE wos_titles
IS 'Thomson Reuters: WoS - WoS title of publications';

COMMENT ON COLUMN wos_titles.id
IS ' Example: 1';

COMMENT ON COLUMN wos_titles.source_id
IS ' Example: WOS:000354914100020';

COMMENT ON COLUMN wos_titles.title
IS ' Example: MEDICAL JOURNAL OF AUSTRALIA';

COMMENT ON COLUMN wos_titles.type
IS 'source, item,source_abbrev,abbrev_iso,abbrev_11,abbrev_29, etc.. Example: source';

COMMENT ON COLUMN wos_titles.source_filename
IS 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';

-- region wos_abstracts
CREATE TABLE wos_abstracts (
  id                SERIAL,
  source_id         VARCHAR(30)  NOT NULL,
  abstract_text     TEXT         NOT NULL,
  source_filename   VARCHAR(200) NOT NULL,
  last_updated_time TIMESTAMP DEFAULT current_timestamp
) TABLESPACE wos_tbs;

ALTER TABLE wos_abstracts
  ADD CONSTRAINT wos_abstracts_pk PRIMARY KEY (source_id) USING INDEX TABLESPACE index_tbs;

COMMENT ON TABLE wos_abstracts
IS $$Thomson Reuters: WoS - WoS abstract of publications$$;

COMMENT ON COLUMN wos_abstracts.id
IS $$ Example: 16753$$;

COMMENT ON COLUMN wos_abstracts.source_id
IS $$UT. Example: WOS:000362820500006$$;

COMMENT ON COLUMN wos_abstracts.abstract_text
IS $$Publication abstract. Multiple sections are separated by two line feeds (LF).$$;

COMMENT ON COLUMN wos_abstracts.source_filename
IS $$source xml file. Example: WR_2015_20160212115351_CORE_00011.xml$$;
-- endregion

CREATE TABLE wos_authors (
  id                SERIAL,
  source_id         VARCHAR(30) NOT NULL DEFAULT '',
  full_name         VARCHAR(200),
  last_name         VARCHAR(200),
  first_name        VARCHAR(200),
  seq_no            INTEGER     NOT NULL DEFAULT 0,
  address_seq       INTEGER,
  address           VARCHAR(500),
  email_address     VARCHAR(300),
  address_id        INTEGER     NOT NULL DEFAULT 0,
  dais_id           VARCHAR(30),
  r_id              VARCHAR(30),
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP            DEFAULT current_timestamp,
  CONSTRAINT wos_authors_pk PRIMARY KEY (source_id, seq_no, address_id)

) TABLESPACE wos_tbs;

CREATE INDEX IF NOT EXISTS wos_id_idtype_idx
  ON wos_document_identifiers (document_id_type, document_id);

CREATE TABLE wos_keywords (
  id                SERIAL,
  source_id         VARCHAR(30)  NOT NULL,
  keyword           VARCHAR(200) NOT NULL,
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP DEFAULT current_timestamp,
  CONSTRAINT wos_keywords_pk PRIMARY KEY (source_id, keyword) USING INDEX TABLESPACE index_tbs
) TABLESPACE wos_tbs;

CREATE TABLE wos_grants (
  id                 SERIAL,
  source_id          VARCHAR(30)  NOT NULL DEFAULT '',
  grant_number       VARCHAR(500) NOT NULL DEFAULT '',
  grant_organization VARCHAR(400) NOT NULL DEFAULT '',
  funding_ack        VARCHAR(4000),
  source_filename    VARCHAR(200),
  last_updated_time  TIMESTAMP             DEFAULT current_timestamp,
  CONSTRAINT wos_grants_pk PRIMARY KEY (source_id, grant_number, grant_organization)
) TABLESPACE wos_tbs;

CREATE INDEX wos_grant_source_id_index
  ON wos_grants (source_id) TABLESPACE index_tbs;

CREATE TABLE wos_addresses (
  id                SERIAL CONSTRAINT wos_addresses_pk PRIMARY KEY USING INDEX TABLESPACE index_tbs,
  source_id         VARCHAR(30)  NOT NULL,
  address_name      VARCHAR(300) NOT NULL,
  organization      VARCHAR(400),
  sub_organization  VARCHAR(400),
  city              VARCHAR(100),
  country           VARCHAR(100),
  zip_code          VARCHAR(20),
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP DEFAULT current_timestamp
) TABLESPACE wos_tbs;

-- region wos_patent_mapping
CREATE TABLE wos_patent_mapping (
  patent_country    VARCHAR(2),
  patent_id         VARCHAR(30),
  patent_type       VARCHAR(30) NOT NULL DEFAULT '',
  cited_source_uid  VARCHAR(30),
  wos_id            VARCHAR(30) NOT NULL,
  last_updated_time TIMESTAMP DEFAULT current_timestamp,
  CONSTRAINT wos_patent_mapping_pk PRIMARY KEY (patent_country, patent_id, patent_type, cited_source_uid)
  USING INDEX TABLESPACE index_tbs
) TABLESPACE wos_tbs;

CREATE INDEX IF NOT EXISTS wpm_cited_source_uid_i
  ON wos_patent_mapping (cited_source_uid) TABLESPACE index_tbs;

COMMENT ON TABLE wos_patent_mapping
IS 'Patents citing publications';

COMMENT ON COLUMN wos_patent_mapping.patent_country
IS 'Two-letter country code. Example: US';

COMMENT ON COLUMN wos_patent_mapping.patent_type
IS 'Patent type. Example: A1';

COMMENT ON COLUMN wos_patent_mapping.patent_id
IS 'Raw patent number, non-zero padded for US. Example: 9234044';

COMMENT ON COLUMN wos_patent_mapping.cited_source_uid
IS 'Cited publication''s WoS uid. Example: WOS:A1979JG31200004';

-- TODO Deprecate and later remove
COMMENT ON COLUMN wos_patent_mapping.wos_id
IS 'Raw original cited publication''s id. Example: A1979JG31200004';
-- endregion

CREATE TABLE wos_pmid_manual_mapping (
  wos_uid           VARCHAR(30),
  pmid              VARCHAR(30),
  pmid_int          INTEGER,
  details           TEXT,
  last_updated_time TIMESTAMP DEFAULT current_timestamp
) TABLESPACE wos_tbs;

-- region wos_pmid_mapping
CREATE TABLE wos_pmid_mapping (
  wos_pmid_seq SERIAL      NOT NULL,
  wos_uid      VARCHAR(30) NOT NULL,
  pmid         VARCHAR(30),
  pmid_int     INTEGER
) TABLESPACE wos_tbs;

ALTER TABLE wos_pmid_mapping
  ADD CONSTRAINT wos_pmid_mapping_pk PRIMARY KEY (wos_uid) USING INDEX TABLESPACE index_tbs;

CREATE UNIQUE INDEX wpm_pmid_int_uk
  ON wos_pmid_mapping (pmid_int) TABLESPACE index_tbs;

-- (Dev) 5m:45s
CREATE UNIQUE INDEX wpm_pmid_uk
  ON wos_pmid_mapping (pmid) TABLESPACE index_tbs;

COMMENT ON TABLE wos_pmid_mapping
IS 'Thomson Reuters: WoS - maps WoS to pmids';

COMMENT ON COLUMN wos_pmid_mapping.wos_pmid_seq
IS 'internal sequence number. Example: 1';

COMMENT ON COLUMN wos_pmid_mapping.wos_uid
IS ' Example: WOS:A1976CP17000008';

COMMENT ON COLUMN wos_pmid_mapping.pmid
IS ' Example: MEDLINE:1000001';

COMMENT ON COLUMN wos_pmid_mapping.pmid_int
IS ' Example: 1000001';
-- endregion

-- region wos_publication_subjects
CREATE TABLE IF NOT EXISTS wos_publication_subjects (
  wos_subject_id              SERIAL       NOT NULL,
  source_id                   VARCHAR(30)  NOT NULL,
  subject_classification_type VARCHAR(100) NOT NULL
    CHECK (subject_classification_type IN ('traditional', 'extended')),
  subject                     VARCHAR(200) NOT NULL,
  source_filename             VARCHAR(200),
  last_updated_time           TIMESTAMP DEFAULT now(),
  CONSTRAINT wos_publication_subjects_pk PRIMARY KEY (source_id, subject_classification_type, subject) USING INDEX TABLESPACE index_tbs
) TABLESPACE wos_tbs;

COMMENT ON TABLE wos_publication_subjects
IS 'Thomson Reuters: WoS - WoS subjects of publications';
COMMENT ON COLUMN wos_publication_subjects.wos_subject_id
IS ' Example: 1';
COMMENT ON COLUMN wos_publication_subjects.source_id
IS ' Example: WOS:A1975AN26800010';
COMMENT ON COLUMN wos_publication_subjects.subject_classification_type
IS ' Every record from journal in Web of Science Core
Collection database will have this element. It will either be traditional or extended';

COMMENT ON COLUMN wos_publication_subjects.subject
IS 'Represents the Subject area. Example: International Relations';

COMMENT ON COLUMN wos_publication_subjects.source_filename
IS 'Source xml file. Example: WR_1975_20160727231652_CORE_0001.xml';
-- endregion

-- region wos_publications
CREATE TABLE wos_publications (
  begin_page         VARCHAR(30),
  created_date       DATE        NOT NULL,
  document_title     VARCHAR(2000),
  document_type      VARCHAR(50) NOT NULL,
  edition            VARCHAR(40) NOT NULL,
  end_page           VARCHAR(30),
  has_abstract       VARCHAR(5)  NOT NULL,
  id                 SERIAL      NOT NULL,
  issue              VARCHAR(10),
  language           VARCHAR(20) NOT NULL,
  last_modified_date DATE        NOT NULL,
  publication_date   DATE        NOT NULL,
  publication_year   VARCHAR(4)  NOT NULL,
  publisher_address  VARCHAR(300),
  publisher_name     VARCHAR(200),
  source_filename    VARCHAR(200),
  source_id          VARCHAR(30) PRIMARY KEY USING INDEX TABLESPACE index_tbs,
  source_title       VARCHAR(300),
  source_type        VARCHAR(20) NOT NULL,
  volume             VARCHAR(20),
  last_updated_time  TIMESTAMP DEFAULT current_timestamp
) TABLESPACE wos_tbs;

-- Dev 6m:03s
-- Prod 12m:51s
CREATE INDEX wp_publication_year_i
  ON wos_publications (publication_year) TABLESPACE index_tbs;

COMMENT ON TABLE wos_publications
IS 'Main Web of Science publication table';

COMMENT ON COLUMN wos_publications.begin_page
IS ' Example: 1421';

COMMENT ON COLUMN wos_publications.created_date
IS ' Example: 2016-03-18';

COMMENT ON COLUMN wos_publications.document_title
IS 'Paper title. Example: Point-of-care testing for coeliac disease antibodies.';

COMMENT ON COLUMN wos_publications.document_type
IS ' Example: Article';

COMMENT ON COLUMN wos_publications.edition
IS ' Example: WOS.SCI';

COMMENT ON COLUMN wos_publications.end_page
IS ' Example: 1432';

COMMENT ON COLUMN wos_publications.has_abstract
IS 'Y or N. Example: Y';

COMMENT ON COLUMN wos_publications.id
IS 'id is always an integer- is an internal (PARDI) number. Example: 1';

COMMENT ON COLUMN wos_publications.issue
IS ' Example: 8';

COMMENT ON COLUMN wos_publications.language
IS ' Example: English';

COMMENT ON COLUMN wos_publications.last_modified_date
IS ' Example: 2016-03-18';

COMMENT ON COLUMN wos_publications.publication_date
IS ' Example: 2015-05-04';

COMMENT ON COLUMN wos_publications.publication_year
IS ' Example: 2015';

COMMENT ON COLUMN wos_publications.publisher_address
IS ' Example: LEVEL 2, 26-32 PYRMONT BRIDGE RD, PYRMONT, NSW 2009, AUSTRALIA';

COMMENT ON COLUMN wos_publications.publisher_name
IS ' Example: AUSTRALASIAN MED PUBL CO LTD';

COMMENT ON COLUMN wos_publications.source_filename
IS 'Source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';

COMMENT ON COLUMN wos_publications.source_id
IS 'Paper Id (Web of Science UT). Example: WOS:000354914100020';

COMMENT ON COLUMN wos_publications.source_title
IS 'Journal title. Example: MEDICAL JOURNAL OF AUSTRALIA';

COMMENT ON COLUMN wos_publications.source_type
IS ' Example: Journal';

COMMENT ON COLUMN wos_publications.volume
IS ' Example: 202';
-- endregion

-- region wos_references
CREATE TABLE wos_references (
  wos_reference_id   SERIAL,
  source_id          VARCHAR(30) NOT NULL,
  cited_source_uid   VARCHAR(30) NOT NULL, -- Contracting column seems to cause table rewrite that runs out of disk space
  --  cited_title TYPE VARCHAR(8000) should be enough
  cited_title        VARCHAR(80000),
  cited_work         TEXT,
  cited_author       VARCHAR(3000),
  cited_year         VARCHAR(40),
  cited_page         VARCHAR(400),
  created_date       DATE,
  last_modified_date DATE,
  source_filename    VARCHAR(200),
  last_updated_time  TIMESTAMP DEFAULT current_timestamp
) TABLESPACE wos_tbs;

ALTER TABLE wos_references
  ADD CONSTRAINT wos_references_pk PRIMARY KEY (source_id, cited_source_uid) USING INDEX TABLESPACE index_tbs;

CREATE INDEX wr_cited_source_uid_i
  ON wos_references (cited_source_uid) TABLESPACE index_tbs;

COMMENT ON TABLE wos_references
IS 'Thomson Reuters: WoS - WoS cited references';

COMMENT ON COLUMN wos_references.wos_reference_id
IS 'auto-increment integer, serving as a row key in distributed systems. Example: 1';

COMMENT ON COLUMN wos_references.source_id
IS 'UT. Example: WOS:000273726900017';

COMMENT ON COLUMN wos_references.cited_source_uid
IS 'UT. Example: WOS:000226230700068';

COMMENT ON COLUMN wos_references.cited_title
IS ' Example: Cytochrome P450 oxidoreductase gene mutations….';

COMMENT ON COLUMN wos_references.cited_work
IS ' Example: JOURNAL OF CLINICAL ENDOCRINOLOGY & METABOLISM';

COMMENT ON COLUMN wos_references.cited_author
IS ' Example: Fukami, M';

COMMENT ON COLUMN wos_references.cited_year
IS ' Example: 2005';

COMMENT ON COLUMN wos_references.cited_page
IS ' Example: 414';

COMMENT ON COLUMN wos_references.created_date
IS ' Example: 2016-03-31';

COMMENT ON COLUMN wos_references.last_modified_date
IS ' Example: 2016-03-31';

COMMENT ON COLUMN wos_references.source_filename
IS 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';
-- endregion
-- endregion

-- region Deletion history tables
CREATE TABLE del_wos_abstracts (
  id                INTEGER,
  source_id         VARCHAR(30),
  abstract_text     TEXT,
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP DEFAULT current_timestamp,
  deleted_time      TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

CREATE TABLE del_wos_addresses (
  id                INTEGER,
  source_id         VARCHAR(30),
  address_name      VARCHAR(300),
  organization      VARCHAR(400),
  sub_organization  VARCHAR(400),
  city              VARCHAR(100),
  country           VARCHAR(100),
  zip_code          VARCHAR(20),
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP DEFAULT current_timestamp,
  deleted_time      TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

CREATE TABLE del_wos_authors (
  id                INTEGER,
  source_id         VARCHAR(30),
  full_name         VARCHAR(200),
  last_name         VARCHAR(200),
  first_name        VARCHAR(200),
  seq_no            INTEGER,
  address_seq       INTEGER,
  address           VARCHAR(500),
  email_address     VARCHAR(300),
  address_id        INTEGER,
  dais_id           VARCHAR(30),
  r_id              VARCHAR(30),
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP DEFAULT current_timestamp,
  deleted_time      TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

CREATE TABLE del_wos_document_identifiers (
  id                INTEGER,
  source_id         VARCHAR(30),
  document_id       VARCHAR(100),
  document_id_type  VARCHAR(30),
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP DEFAULT current_timestamp,
  deleted_time      TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

CREATE TABLE del_wos_grants (
  id                 INTEGER,
  source_id          VARCHAR(30),
  grant_number       VARCHAR(500),
  grant_organization VARCHAR(400),
  funding_ack        VARCHAR(4000),
  source_filename    VARCHAR(200),
  last_updated_time  TIMESTAMP,
  deleted_time       TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

CREATE TABLE del_wos_keywords (
  id                INTEGER,
  source_id         VARCHAR(30),
  keyword           VARCHAR(200),
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP,
  deleted_time      TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

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
  source_filename    VARCHAR(200),
  last_updated_time  TIMESTAMP,
  deleted_time       TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

CREATE TABLE del_wos_references (
  wos_reference_id   INTEGER,
  source_id          VARCHAR(30),
  cited_source_uid   VARCHAR(30),
  cited_title        VARCHAR(80000),
  cited_work         TEXT,
  cited_author       VARCHAR(3000),
  cited_year         VARCHAR(40),
  cited_page         VARCHAR(200),
  created_date       DATE,
  last_modified_date DATE,
  source_filename    VARCHAR(200),
  last_updated_time  TIMESTAMP,
  deleted_time       TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

CREATE TABLE del_wos_titles (
  id                INTEGER,
  source_id         VARCHAR(30),
  title             VARCHAR(2000),
  type              VARCHAR(100),
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP,
  deleted_time      TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;
-- endregion

-- region Update history tables
CREATE TABLE uhs_wos_abstracts (
  id                INTEGER,
  source_id         VARCHAR(30),
  abstract_text     TEXT,
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP,
  uhs_updated_time  TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

CREATE TABLE uhs_wos_addresses (
  id                INTEGER,
  source_id         VARCHAR(30),
  address_name      VARCHAR(300),
  organization      VARCHAR(400),
  sub_organization  VARCHAR(400),
  city              VARCHAR(100),
  country           VARCHAR(100),
  zip_code          VARCHAR(20),
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP,
  uhs_updated_time  TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

CREATE TABLE uhs_wos_authors (
  id                INTEGER,
  source_id         VARCHAR(30),
  full_name         VARCHAR(200),
  last_name         VARCHAR(200),
  first_name        VARCHAR(200),
  seq_no            INTEGER,
  address_seq       INTEGER,
  address           VARCHAR(500),
  email_address     VARCHAR(300),
  address_id        INTEGER,
  dais_id           VARCHAR(30),
  r_id              VARCHAR(30),
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP,
  uhs_updated_time  TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

CREATE TABLE uhs_wos_document_identifiers (
  id                INTEGER,
  source_id         VARCHAR(30),
  document_id       VARCHAR(100),
  document_id_type  VARCHAR(30),
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP,
  uhs_updated_time  TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

CREATE TABLE uhs_wos_grants (
  id                 INTEGER,
  source_id          VARCHAR(30),
  grant_number       VARCHAR(500),
  grant_organization VARCHAR(400),
  funding_ack        VARCHAR(4000),
  source_filename    VARCHAR(200),
  last_updated_time  TIMESTAMP,
  uhs_updated_time   TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

CREATE TABLE uhs_wos_keywords (
  id                INTEGER,
  source_id         VARCHAR(30),
  keyword           VARCHAR(200),
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP,
  uhs_updated_time  TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

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
  source_filename    VARCHAR(200),
  last_updated_time  TIMESTAMP,
  uhs_updated_time   TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

CREATE TABLE uhs_wos_references (
  wos_reference_id   INTEGER,
  source_id          VARCHAR(30),
  cited_source_uid   VARCHAR(30),
  cited_title        VARCHAR(80000),
  cited_work         TEXT,
  cited_author       VARCHAR(3000),
  cited_year         VARCHAR(40),
  cited_page         VARCHAR(200),
  created_date       DATE,
  last_modified_date DATE,
  source_filename    VARCHAR(200),
  last_updated_time  TIMESTAMP,
  uhs_updated_time   TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;

CREATE TABLE uhs_wos_titles (
  id                INTEGER,
  source_id         VARCHAR(30),
  title             VARCHAR(2000),
  type              VARCHAR(100),
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP,
  uhs_updated_time  TIMESTAMP DEFAULT current_timestamp
) TABLESPACE history_tbs;
-- endregion

CREATE TABLE update_log_wos (
  id                 SERIAL,
  last_updated       TIMESTAMP,
  num_wos            INTEGER,
  num_new            INTEGER,
  num_update         INTEGER,
  num_delete         INTEGER,
  source_filename    VARCHAR(200),
  record_count       BIGINT,
  source_file_size   BIGINT,
  process_start_time TIMESTAMP
) TABLESPACE wos_tbs;

ALTER TABLE update_log_wos
  ADD CONSTRAINT update_log_wos_pk PRIMARY KEY (id) USING INDEX TABLESPACE index_tbs;

COMMENT ON TABLE update_log_wos
IS 'WoS tables - update log table for WoS';

COMMENT ON TABLE update_log_wos
IS 'WoS tables - update log table for WoS';
