/*
	ERNIE WoS DDL.

  Creates the following tables in the wos tablespace:
    wos_abstracts
    wos_addresses
    wos_authors
    wos_document_identifiers
    wos_grants
    wos_keywords
    wos_publications
    wos_publication_subjects
    wos_titles
  Creates the following table in the wos_references tablespace:
    wos_references
    
*/

CREATE TABLE IF NOT EXISTS wos_abstracts (
  id                SERIAL       NOT NULL,
  source_id         VARCHAR(30)  NOT NULL
    CONSTRAINT wos_abstracts_pk PRIMARY KEY USING INDEX TABLESPACE index_tbs,
  abstract_text     TEXT         NOT NULL,
  source_filename   VARCHAR(200) NOT NULL,
  last_updated_time TIMESTAMP DEFAULT now()
) TABLESPACE wos_tbs;
COMMENT ON TABLE wos_abstracts
IS 'Thomson Reuters: WoS - WoS abstract of publications';
COMMENT ON COLUMN wos_abstracts.id
IS ' Example: 16753';
COMMENT ON COLUMN wos_abstracts.source_id
IS 'UT. Example: WOS:000362820500006';
COMMENT ON COLUMN wos_abstracts.abstract_text
IS 'Publication abstract. Multiple sections are separated by two line feeds (LF).';
COMMENT ON COLUMN wos_abstracts.source_filename
IS 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';

------------------------------------------------------------------------------------------------------

CREATE TABLE wos_addresses (
  id                SERIAL       NOT NULL,
  source_id         VARCHAR(30)  NOT NULL,
  address_name      VARCHAR(300) NOT NULL,
  organization      VARCHAR(400),
  sub_organization  VARCHAR(400),
  city              VARCHAR(100),
  country           VARCHAR(100),
  zip_code          VARCHAR(20),
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT wos_addresses_pk PRIMARY KEY (source_id, address_name) USING INDEX TABLESPACE index_tbs
) TABLESPACE wos_tbs;
COMMENT ON TABLE wos_addresses
IS 'Thomson Reuters: WoS - WoS address where publications are written';
COMMENT ON COLUMN wos_addresses.id
IS ' Example: 1';
COMMENT ON COLUMN wos_addresses.source_id
IS 'UT. Example: WOS:000354914100020';
COMMENT ON COLUMN wos_addresses.address_name
IS ' Example: Eastern Hlth Clin Sch, Melbourne, Vic, Australia';
COMMENT ON COLUMN wos_addresses.organization
IS ' Example: Walter & Eliza Hall Institute';
COMMENT ON COLUMN wos_addresses.sub_organization
IS ' Example: Dipartimento Fis';
COMMENT ON COLUMN wos_addresses.city
IS ' Example: Cittadella Univ';
COMMENT ON COLUMN wos_addresses.country
IS ' Example: Italy';
COMMENT ON COLUMN wos_addresses.zip_code
IS ' Example: I-09042';
COMMENT ON COLUMN wos_addresses.source_filename
IS 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';

------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS wos_authors (
  id                SERIAL                                      NOT NULL,
  source_id         VARCHAR(30) DEFAULT '' :: CHARACTER VARYING NOT NULL,
  full_name         VARCHAR(200),
  last_name         VARCHAR(200),
  first_name        VARCHAR(200),
  seq_no            INTEGER DEFAULT 0                           NOT NULL,
  address_seq       INTEGER,
  address           VARCHAR(500),
  email_address     VARCHAR(300),
  address_id        INTEGER DEFAULT 0                           NOT NULL,
  dais_id           VARCHAR(30),
  r_id              VARCHAR(30),
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT wos_authors_pk PRIMARY KEY (source_id, seq_no, address_id) USING INDEX TABLESPACE index_tbs
) TABLESPACE wos_tbs;
COMMENT ON TABLE wos_authors
IS 'Thomson Reuters: WoS - WoS authors of publications';
COMMENT ON COLUMN wos_authors.id
IS ' Example: 15135';
COMMENT ON COLUMN wos_authors.source_id
IS 'UT. Example: WOS:000078266100010';
COMMENT ON COLUMN wos_authors.full_name
IS ' Example: Charmandaris, V';
COMMENT ON COLUMN wos_authors.last_name
IS ' Example: Charmandaris';
COMMENT ON COLUMN wos_authors.first_name
IS ' Example: V';
COMMENT ON COLUMN wos_authors.seq_no
IS ' Example: 6';
COMMENT ON COLUMN wos_authors.address_seq
IS ' Example: 1';
COMMENT ON COLUMN wos_authors.address
IS ' Example: Univ Birmingham, Sch Psychol, Birmingham B15 2TT, W Midlands, England';
COMMENT ON COLUMN wos_authors.email_address
IS ' Example: k.j.linnell@bham.ac.uk';
COMMENT ON COLUMN wos_authors.address_id
IS ' Example: 7186';
COMMENT ON COLUMN wos_authors.dais_id
IS ' Example: 16011591';
COMMENT ON COLUMN wos_authors.r_id
IS ' Example: A-7196-2008';
COMMENT ON COLUMN wos_authors.source_filename
IS 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';

------------------------------------------------------------------------------------------------------

CREATE TABLE wos_document_identifiers (
  id                SERIAL                                       NOT NULL,
  source_id         VARCHAR(30) DEFAULT '' :: CHARACTER VARYING  NOT NULL,
  document_id       VARCHAR(100) DEFAULT '' :: CHARACTER VARYING NOT NULL,
  document_id_type  VARCHAR(30) DEFAULT '' :: CHARACTER VARYING  NOT NULL,
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT wos_document_identifiers_pk PRIMARY KEY (source_id, document_id_type, document_id) --
  USING INDEX TABLESPACE index_tbs
) TABLESPACE wos_tbs;
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

------------------------------------------------------------------------------------------------------

CREATE TABLE wos_grants (
  id                 SERIAL                                       NOT NULL,
  source_id          VARCHAR(30) DEFAULT '' :: CHARACTER VARYING  NOT NULL,
  grant_number       VARCHAR(500) DEFAULT '' :: CHARACTER VARYING NOT NULL,
  grant_organization VARCHAR(400) DEFAULT '' :: CHARACTER VARYING NOT NULL,
  funding_ack        VARCHAR(4000),
  source_filename    VARCHAR(200),
  last_updated_time  TIMESTAMP DEFAULT now(),
  CONSTRAINT wos_grants_pk PRIMARY KEY (source_id, grant_number, grant_organization) USING INDEX TABLESPACE index_tbs
) TABLESPACE wos_tbs;
COMMENT ON TABLE wos_grants
IS 'Thomson Reuters: WoS - WoS grants that fund publications';
COMMENT ON COLUMN wos_grants.id
IS ' Example: 14548';
COMMENT ON COLUMN wos_grants.source_id
IS ' Example: WOS:000340028400057';
COMMENT ON COLUMN wos_grants.grant_number
IS ' Example: NNG04GC89G';
COMMENT ON COLUMN wos_grants.grant_organization
IS ' Example: NASA LTSA grant';
COMMENT ON COLUMN wos_grants.funding_ack
IS ' Example: We thank Molly Peeples, Paul Torrey, Manolis Papastergis, and….';
COMMENT ON COLUMN wos_grants.source_filename
IS 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';

------------------------------------------------------------------------------------------------------

CREATE TABLE wos_keywords (
  id                SERIAL       NOT NULL,
  source_id         VARCHAR(30)  NOT NULL,
  keyword           VARCHAR(200) NOT NULL,
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT wos_keywords_pk PRIMARY KEY (source_id, keyword) USING INDEX TABLESPACE index_tbs
) TABLESPACE wos_tbs;
COMMENT ON TABLE wos_keywords
IS 'Thomson Reuters: WoS - WoS keyword of publications';
COMMENT ON COLUMN wos_keywords.id
IS ' Example: 62849';
COMMENT ON COLUMN wos_keywords.source_id
IS 'UT. Example: WOS:000353971800007';
COMMENT ON COLUMN wos_keywords.keyword
IS ' Example: NEONATAL INTRACRANIAL INJURY';
COMMENT ON COLUMN wos_keywords.source_filename
IS 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';

------------------------------------------------------------------------------------------------------

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
  source_id          VARCHAR(30) NOT NULL CONSTRAINT wos_publications_pk PRIMARY KEY USING INDEX TABLESPACE index_tbs,
  source_title       VARCHAR(300),
  source_type        VARCHAR(20) NOT NULL,
  volume             VARCHAR(20),
  last_updated_time  TIMESTAMP DEFAULT now()
) TABLESPACE wos_tbs;

-- Prod 12m:51s
-- Dev 6m:03s
CREATE INDEX wp_publication_year_i
  ON wos_publications (publication_year) TABLESPACE index_tbs;

COMMENT ON TABLE wos_publications
IS 'Main Web of Science publication table';
COMMENT ON COLUMN wos_publications.begin_page
IS ' Example: 1421';
COMMENT ON COLUMN wos_publications.created_date
IS ' Example: 2016-03-18';
COMMENT ON COLUMN wos_publications.document_title
IS ' Example: Point-of-care testing for coeliac disease antibodies…';
COMMENT ON COLUMN wos_publications.document_type
IS ' Example: Article';
COMMENT ON COLUMN wos_publications.edition
IS ' Example: WOS.SCI';
COMMENT ON COLUMN wos_publications.end_page
IS ' Example: 1432';
COMMENT ON COLUMN wos_publications.has_abstract
IS 'Y or N. Example: Y';
COMMENT ON COLUMN wos_publications.id
IS 'id is always an integer- is an internal (ERNIE) number. Example: 1';
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
IS 'source xml file. Example: WR_2015_20160212115351_CORE_00011.xml';
COMMENT ON COLUMN wos_publications.source_id
IS 'Paper Id (Web of Science UT). Example: WOS:000354914100020';
COMMENT ON COLUMN wos_publications.source_title
IS 'Journal title. Example: MEDICAL JOURNAL OF AUSTRALIA';
COMMENT ON COLUMN wos_publications.source_type
IS ' Example: Journal';
COMMENT ON COLUMN wos_publications.volume
IS ' Example: 202';

------------------------------------------------------------------------------------------------------

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

------------------------------------------------------------------------------------------------------

CREATE TABLE wos_references (
  wos_reference_id   SERIAL      NOT NULL,
  source_id          VARCHAR(30) NOT NULL,
  cited_source_uid   VARCHAR(30) NOT NULL,
  cited_title        VARCHAR(80000),
  cited_work         TEXT,
  cited_author       VARCHAR(3000),
  cited_year         VARCHAR(40),
  cited_page         VARCHAR(400),
  created_date       DATE,
  last_modified_date DATE,
  source_filename    VARCHAR(200),
  last_updated_time  TIMESTAMP DEFAULT now(),
  CONSTRAINT wos_references_pk PRIMARY KEY (source_id, cited_source_uid) USING INDEX TABLESPACE index_tbs
) TABLESPACE wos_references;
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

------------------------------------------------------------------------------------------------------

CREATE TABLE wos_titles (
  id                SERIAL        NOT NULL,
  source_id         VARCHAR(30)   NOT NULL,
  title             VARCHAR(2000) NOT NULL,
  type              VARCHAR(100)  NOT NULL,
  source_filename   VARCHAR(200),
  last_updated_time TIMESTAMP DEFAULT now(),
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

------------------------------------------------------------------------------------------------------
