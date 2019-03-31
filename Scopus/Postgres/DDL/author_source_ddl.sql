\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- scopus_authors
DROP TABLE IF EXISTS scopus_authors CASCADE;

CREATE TABLE scopus_authors (
  scp BIGINT CONSTRAINT sauth_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  author_seq SMALLINT,
  auid BIGINT,
  author_indexed_name TEXT,
  author_surname TEXT,
  author_given_name TEXT,
  author_initials TEXT,
  author_e_address TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_authors_pk PRIMARY KEY (scp, author_seq) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_authors
IS 'Scopus authors information of publications';

COMMENT ON COLUMN scopus_authors.scp
IS 'Scopus id. Example: 36849140316';

COMMENT ON COLUMN scopus_authors.author_seq
IS 'The order of the authors in the document. Example: 1';

COMMENT ON COLUMN scopus_authors.auid
IS 'Author id: unique author identifier';

COMMENT ON COLUMN scopus_authors.author_indexed_name
IS 'Author surname and initials';

COMMENT ON COLUMN scopus_authors.author_surname
IS 'Example: Weller';

COMMENT ON COLUMN scopus_authors.author_given_name
IS 'Example: Sol';

COMMENT ON COLUMN scopus_authors.author_initials
IS 'Example: S.';

COMMENT ON COLUMN scopus_authors.author_e_address
IS 'biyant@psych.stanford.edu';

-- scopus_affiliations
DROP TABLE IF EXISTS scopus_affiliations CASCADE;

CREATE TABLE scopus_affiliations (
  scp BIGINT CONSTRAINT saff_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  affiliation_no SMALLINT,
  afid BIGINT,
  dptid BIGINT,
  organization TEXT,
  city_group TEXT,
  state TEXT,
  postal_code TEXT,
  country_code TEXT,
  country TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_affiliations_pk PRIMARY KEY (scp, affiliation_no) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_affiliations
IS 'Scopus affiliation information of authors';

COMMENT ON COLUMN scopus_affiliations.scp
IS 'Scopus id. Example: 50349119549';

COMMENT ON COLUMN scopus_affiliations.affiliation_no
IS 'Affiliation sequence in the document. Example: 1';

COMMENT ON COLUMN scopus_affiliations.afid
IS 'Affiliation id. Example: 106106336';

COMMENT ON COLUMN scopus_affiliations.dptid
IS 'Department id. Example: 104172073';

COMMENT ON COLUMN scopus_affiliations.organization
IS 'Author organization. Example: Portsmouth and Isle,Wight Area Pathological Service';

COMMENT ON COLUMN scopus_affiliations.city_group
IS 'Example: Portsmouth';

COMMENT ON COLUMN scopus_affiliations.state
IS 'Example: LA';

COMMENT ON COLUMN scopus_affiliations.postal_code
IS 'Example: 70118';

COMMENT ON COLUMN scopus_affiliations.country_code
IS 'iso-code. Example: gbr';

COMMENT ON COLUMN scopus_affiliations.country
IS 'Country name. Example: United Kingdom';

-- scopus_author_affiliations
DROP TABLE IF EXISTS scopus_author_affiliations CASCADE;

CREATE TABLE scopus_author_affiliations (
  scp BIGINT CONSTRAINT saff_mapping_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  author_seq SMALLINT,
  affiliation_no SMALLINT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_author_affiliations_pk PRIMARY KEY (scp, author_seq, affiliation_no) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

ALTER TABLE scopus_author_affiliations
  ADD CONSTRAINT scopus_scp_author_seq_fk FOREIGN KEY (scp, author_seq) REFERENCES scopus_authors (scp, author_seq) ON DELETE CASCADE;

ALTER TABLE scopus_author_affiliations
  ADD CONSTRAINT scopus_scp_affiliation_no_fk FOREIGN KEY (scp, affiliation_no) REFERENCES scopus_affiliations (scp, affiliation_no) ON DELETE CASCADE;

COMMENT ON TABLE scopus_author_affiliations
IS 'Mapping table for scopus_authors and scopus_affiliations';

COMMENT ON COLUMN scopus_author_affiliations.scp
IS 'Scopus id. Example: 50349119549';

COMMENT ON COLUMN scopus_author_affiliations.author_seq
IS 'The order of the authors in the document. Example: 1';

COMMENT ON COLUMN scopus_author_affiliations.affiliation_no
IS 'Affiliation sequence in the document. Example: 1';

-- scopus_sources
DROP TABLE IF EXISTS scopus_sources CASCADE;

CREATE TABLE scopus_sources (
  scp BIGINT CONSTRAINT s_sources_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  source_id BIGINT,
  source_type TEXT,
  source_title TEXT,
  issn_print TEXT,
  issn_electronic TEXT,
  coden_code TEXT,
  issue TEXT,
  volume TEXT,
  first_page TEXT,
  last_page TEXT,
  publication_year SMALLINT,
  publication_date DATE,
  website TEXT,
  publisher_name TEXT,
  publisher_e_address TEXT,
  indexed_terms TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_sources_pk PRIMARY KEY (scp) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_sources
IS 'Journal source information table';

COMMENT ON COLUMN scopus_sources.scp
IS 'Scopus id. Example: 50349106526';

COMMENT ON COLUMN scopus_sources.source_id
IS 'Journal source id. Example: 22414';

COMMENT ON COLUMN scopus_sources.source_type
IS 'Source type. Example: j for journal';

COMMENT ON COLUMN scopus_sources.source_title
IS 'Journal name. Example: American Heart Journal';

COMMENT ON COLUMN scopus_sources.issn_print
IS 'The ISSN of a serial publication (print). Example: 00028703';

COMMENT ON COLUMN scopus_sources.issn_electronic
IS 'The ISSN of a serial publication (electronic). Example: 10976744';

COMMENT ON COLUMN scopus_sources.coden_code
IS 'The CODEN code that uniquely identifies the source. Example: AHJOA';

COMMENT ON COLUMN scopus_sources.issue
IS 'Example: 5';

COMMENT ON COLUMN scopus_sources.volume
IS 'Example: 40';

COMMENT ON COLUMN scopus_sources.first_page
IS 'Page range. Example: 706';

COMMENT ON COLUMN scopus_sources.last_page
IS 'Page range. Example: 730';

COMMENT ON COLUMN scopus_sources.publication_year
IS 'Example: 1950';

COMMENT ON COLUMN scopus_sources.publication_date
IS 'Example: 1950-05-20';

COMMENT ON COLUMN scopus_sources.website
IS 'Example: http://dl.acm.org/citation.cfm?id=111048';

COMMENT ON COLUMN scopus_sources.publisher_name
IS 'Example: Oxford University Press';

COMMENT ON COLUMN scopus_sources.publisher_e_address
IS 'Example: acmhelp@acm.org';

COMMENT ON COLUMN scopus_sources.indexed_terms
IS 'Subject index terms';

-- scopus_source_isbns
DROP TABLE IF EXISTS scopus_source_isbns CASCADE;

CREATE TABLE scopus_source_isbns (
  scp BIGINT CONSTRAINT ssi_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  isbn TEXT,
  isbn_length SMALLINT,
  isbn_level TEXT,
  isbn_type TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_source_isbns_pk PRIMARY KEY (scp,isbn) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_source_isbns
IS 'Scopus publications isbn information';

COMMENT ON COLUMN scopus_source_isbns.isbn
IS 'ISBN number. Example: 0080407749';

COMMENT ON COLUMN scopus_source_isbns.isbn_length
IS 'ISBN length. Example: 10 or 13';

COMMENT ON COLUMN scopus_source_isbns.isbn_level
IS 'Example: set or volume';

COMMENT ON COLUMN scopus_source_isbns.isbn_type
IS 'Example: hardcover, paperback, cloth';

-- scopus_subjects
DROP TABLE IF EXISTS scopus_subjects CASCADE;

CREATE TABLE scopus_subjects (
  scp BIGINT CONSTRAINT ssubj_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  subj_abbr TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_subjects_pk PRIMARY KEY (scp, subj_abbr) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_subjects
IS 'Journal subject abbreviations table';

COMMENT ON COLUMN scopus_subjects.scp
IS 'Scopus id. Example: 37049154082';

COMMENT ON COLUMN scopus_subjects.subj_abbr
IS 'Example: CHEM';

-- scopus_subject_keywords
DROP TABLE IF EXISTS scopus_subject_keywords CASCADE;

CREATE TABLE scopus_subject_keywords (
  scp BIGINT CONSTRAINT ssubj_keywords_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  subject TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_subject_keywords_pk PRIMARY KEY (scp, subject) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_subject_keywords
IS 'Journal subject detailed keywords table';

COMMENT ON COLUMN scopus_subject_keywords.scp
IS 'Scopus id. Example: 37049154082';

COMMENT ON COLUMN scopus_subject_keywords.subject
IS 'Example: Health';

-- scopus_classes
DROP TABLE IF EXISTS scopus_classes CASCADE;

CREATE TABLE scopus_classes (
  scp BIGINT CONSTRAINT sclass_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  class_type TEXT,
  class_code TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_classes_pk PRIMARY KEY (scp,class_code) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_classes
IS 'All type of classification code of publications';

COMMENT ON COLUMN scopus_classes.scp
IS 'Scopus id. Example: 37049154082';

COMMENT ON COLUMN scopus_classes.class_type
IS 'Example: EMCLASS';

COMMENT ON COLUMN scopus_classes.class_code
IS 'Example: 23.2.2';

--scopus_classification_lookup
DROP TABLE IF EXISTS scopus_classification_lookup CASCADE;

CREATE TABLE scopus_classification_lookup (
  class_type TEXT,
  class_code TEXT,
  description TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_classification_lookup_pk PRIMARY KEY (class_type,class_code) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_classification_lookup
IS 'Classification lookup table';

COMMENT ON COLUMN scopus_classification_lookup.class_type
IS 'Classification type. Example: EMCLASS';

COMMENT ON COLUMN scopus_classification_lookup.class_code
IS 'Example: 17';

COMMENT ON COLUMN scopus_classification_lookup.description
IS 'Example: Public Health, Social Medicine and Epidemiology';

-- scopus_conferences
DROP TABLE IF EXISTS scopus_conferences CASCADE;

CREATE TABLE scopus_conferences (
  scp BIGINT CONSTRAINT sconf_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  conf_code BIGINT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_conferences_pk PRIMARY KEY (scp,conf_code) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_conferences
IS 'Conference event information of publications';

COMMENT ON COLUMN scopus_conferences.scp
IS 'Scopus id. Example: 25767560';

COMMENT ON COLUMN scopus_conferences.conf_code
IS 'Conference code, assigned by Elsevier DB';

-- scopus_conference_events
DROP TABLE IF EXISTS scopus_conference_events CASCADE;

CREATE TABLE scopus_conference_events (
  conf_code BIGINT,
  conf_name TEXT,
  conf_address TEXT,
  conf_city TEXT,
  conf_postal_code TEXT,
  conf_start_date DATE,
  conf_end_date DATE,
  conf_number TEXT,
  conf_catalog_number TEXT,
  conf_sponsor TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_conference_events_pk PRIMARY KEY (conf_code) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_conference_events
IS 'Conference events information';

COMMENT ON COLUMN scopus_conference_events.conf_code
IS 'Conference code, assigned by Elsevier DB';

COMMENT ON COLUMN scopus_conference_events.conf_name
IS 'Conference name';

COMMENT ON COLUMN scopus_conference_events.conf_address
IS 'Conference address';

COMMENT ON COLUMN scopus_conference_events.conf_city
IS 'City of conference event';

COMMENT ON COLUMN scopus_conference_events.conf_postal_code
IS 'Postal code of conference event';

COMMENT ON COLUMN scopus_conference_events.conf_start_date
IS 'Conference start date';

COMMENT ON COLUMN scopus_conference_events.conf_end_date
IS 'Conference end date';

COMMENT ON COLUMN scopus_conference_events.conf_number
IS 'Sequencenumber of the conference';

COMMENT ON COLUMN scopus_conference_events.conf_catalog_number
IS 'Conference catalogue number';

COMMENT ON COLUMN scopus_conference_events.conf_sponsor
IS 'Conference sponser names';

--scopus_conf_publications
DROP TABLE IF EXISTS scopus_conf_publications CASCADE;

CREATE TABLE scopus_conf_publications (
  conf_code BIGINT,
  proc_part_no TEXT,
  proc_page_range TEXT,
  proc_page_count SMALLINT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_conf_publications_pk PRIMARY KEY (conf_code) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_conf_publications
IS 'Conference publications information';

COMMENT ON COLUMN scopus_conf_publications.conf_code
IS 'Conference code, assigned by Elsevier DB';

COMMENT ON COLUMN scopus_conf_publications.proc_part_no
IS 'Part number of the conference proceeding';

COMMENT ON COLUMN scopus_conf_publications.proc_page_range
IS 'Start and end page of a conference proceeding';

COMMENT ON COLUMN scopus_conf_publications.proc_page_count
IS 'Number of pages in a conference proceeding';

-- scopus_conf_editors
DROP TABLE IF EXISTS scopus_conf_editors CASCADE;

CREATE TABLE scopus_conf_editors (
  conf_code BIGINT CONSTRAINT sconf_editor_conf_code_fk REFERENCES scopus_conference_events ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  indexed_name TEXT,
  role_type TEXT,
  initials TEXT,
  surname TEXT,
  given_name TEXT,
  degree TEXT,
  suffix TEXT,
  address TEXT,
  organization TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_conf_editors_pk PRIMARY KEY (conf_code, indexed_name) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_conf_editors
IS 'Conference editors information';

COMMENT ON COLUMN scopus_conf_editors.conf_code
IS 'Conference publications information';

COMMENT ON COLUMN scopus_conf_editors.indexed_name
IS 'A sortable variant of the editor surname and initials';

COMMENT ON COLUMN scopus_conf_editors.role_type
IS 'Special role such as "chief editor" or institution as "inst"';

COMMENT ON COLUMN scopus_conf_editors.initials
IS 'Initials of the editor';

COMMENT ON COLUMN scopus_conf_editors.surname
IS 'Surname of the editor';

COMMENT ON COLUMN scopus_conf_editors.given_name
IS 'Given name of the editor';

COMMENT ON COLUMN scopus_conf_editors.degree
IS 'Degress of the editor';

COMMENT ON COLUMN scopus_conf_editors.suffix
IS 'Suffix of the editor';

COMMENT ON COLUMN scopus_conf_editors.address
IS 'The address of the editors';

COMMENT ON COLUMN scopus_conf_editors.organization
IS 'The organization of the editors';
