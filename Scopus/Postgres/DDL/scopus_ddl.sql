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
  -- There are some outliers with absent titles
  citation_title TEXT,
  citation_title_lang_code CHAR(3),
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


-- Added by Sitaram Devarakonda 03/22/2019
-- DDL for scopus_publication_identifiers, scopus_abstracts, scopus_titles, scopus_keywords and scopus_chemicalgroups

DROP TABLE if EXISTS scopus_publication_identifiers CASCADE;

CREATE TABLE IF NOT EXISTS scopus_publication_identifiers (
  scp_id         BIGINT  CONSTRAINT spi_source_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  document_id       TEXT NOT NULL,
  document_id_type  TEXT  NOT NULL,
  CONSTRAINT scopus_publiaction_identifiers_pk PRIMARY KEY (scp_id,document_id_type,document_id) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_publication_identifiers
IS 'ELSEVIER: Scopus document identifiers of documents such as doi';

COMMENT ON COLUMN scopus_publication_identifiers.scp_id
IS 'Scopus id that uniquely identifies document Ex: 85046115382';

COMMENT ON COLUMN scopus_publication_identifiers.document_id
IS 'Document id Ex: S1322769617302901';

COMMENT ON COLUMN scopus_publication_identifiers.document_id_type
IS 'Document id type Ex: PUI,SNEMB,DOI,PII etc';


DROP TABLE IF EXISTS scopus_abstracts CASCADE;

CREATE TABLE IF NOT EXISTS scopus_abstracts (
  scp_id                 BIGINT CONSTRAINT sa_source_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  abstract_text             TEXT NOT NULL,
  abstract_language         TEXT NOT NULL,
  abstract_source           TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_abstracts_pk PRIMARY KEY (scp_id,abstract_language) USING INDEX TABLESPACE index_tbs
)TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_abstracts
IS 'ELSEVIER: Scopus abstracts of publications';

COMMENT ON COLUMN scopus_abstracts.scp_id
IS 'Scopus id that uniquely identifies document Ex: 85046115382';

COMMENT ON COLUMN scopus_abstracts.abstract_text
IS 'Contains an abstract of the document';

COMMENT ON COLUMN scopus_abstracts.abstract_language
IS 'Contains the language of the abstract';

COMMENT ON COLUMN scopus_abstracts.abstract_source
IS 'Contains the value indicating from which part abstract originates ex: introduction,preface';


DROP TABLE IF EXISTS scopus_titles CASCADE;

CREATE TABLE IF NOT EXISTS scopus_titles (
  scp_id       BIGINT CONSTRAINT st_source_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  title           TEXT NOT NULL,
  type            TEXT NOT NULL,
  language        TEXT NOT NULL,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_titles_pk PRIMARY KEY (scp_id,language) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_titles
IS 'ELSEVIER: Scopus title of publications';

COMMENT ON COLUMN scopus_titles.scp_id
IS 'Scopus id that uniquely identifies document Ex: 85046115382';

COMMENT ON COLUMN scopus_titles.title
IS 'Contains the original or translated title of the document. Ex: The genus Tragus';

COMMENT ON COLUMN scopus_titles.type
IS 'Contains the item type of original document Ex: ar,le';

COMMENT ON COLUMN scopus_titles.language
IS 'Language of the title Ex: eng,esp';


DROP TABLE IF EXISTS scopus_keywords CASCADE;

CREATE TABLE if NOT EXISTS scopus_keywords (
  scp_id         BIGINT CONSTRAINT sk_source_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  keyword           TEXT NOT NULL,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_keywords_pk PRIMARY KEY (scp_id,keyword) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_keywords
IS 'ELSEVIER: Keyword information table';

COMMENT ON COLUMN scopus_keywords.scp_id
IS 'Scopus id that uniquely identifies document Ex: 85046115382';

COMMENT ON COLUMN scopus_keywords.keyword
IS 'Keywords assigned to document by authors Ex: headache, high blood pressure';


DROP TABLE if EXISTS scopus_chemicalgroups CASCADE;

CREATE TABLE IF NOT EXISTS scopus_chemicalgroups (
  scp_id BIGINT CONSTRAINT sc_source_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  chemicals_source TEXT NOT NULL,
  chemical_name TEXT NOT NULL,
  cas_registry_number TEXT NOT NULL DEFAULT ' ',
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_chemicals_pk PRIMARY KEY (scp_id,chemical_name,cas_registry_number) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_chemicalgroups
IS 'ELSEVIER: Chemical names that occur in the document';

COMMENT ON COLUMN scopus_chemicalgroups.scp_id
IS 'Scopus id that uniquely identifies document Ex: 85046115382';

COMMENT ON COLUMN scopus_chemicalgroups.chemicals_source
IS 'Source of the chemical elements Ex: mln,esbd';

COMMENT ON COLUMN scopus_chemicalgroups.chemical_name
IS 'Name of the chemical substance Ex: iodine';

COMMENT ON COLUMN scopus_chemicalgroups.cas_registry_number
IS 'CAS registry number associated with chemical name Ex: 15715-08-9';