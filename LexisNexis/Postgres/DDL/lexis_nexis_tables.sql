\set ON_ERROR_STOP on
\set ECHO all

\if :{?schema}
SET search_path = :schema;
\endif

-- JetBrains IDEs: start execution from here
SET TIMEZONE = 'US/Eastern';

-- region lexis_nexis_patent_families

-- DROP TABLE IF EXISTS lexis_nexis_patent_families;
CREATE TYPE FAMILY_TYPE AS ENUM ('domestic', 'main', 'complete', 'extended');
CREATE TABLE lexis_nexis_patent_families (
  earliest_date DATE,
  family_id INT,
  family_type FAMILY_TYPE,
  CONSTRAINT lexis_nexis_patent_families_pk
    PRIMARY KEY (family_id) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_patent_families IS 'Patent Family which contains four family types';
COMMENT ON COLUMN lexis_nexis_patent_families.earliest_date IS 'Earliest date';
COMMENT ON COLUMN lexis_nexis_patent_families.family_id IS 'ID for each family type';
COMMENT ON COLUMN lexis_nexis_patent_families.family_type IS 'Type to indicate family type';

-- endregion

-- region lexis_nexis_patents

-- DROP TABLE IF EXISTS lexis_nexis_patents CASCADE;
CREATE TABLE lexis_nexis_patents (
  country_code TEXT NOT NULL,
  doc_number TEXT NOT NULL,
  kind_code TEXT NOT NULL,
  language_of_filing TEXT,
  language_of_publication TEXT,
  date_of_public_availability_unexamined_printed_wo_grant DATE,
  date_of_public_availability_printed_w_grant DATE,
  main_ipc_classification_text TEXT,
  main_ipc_classification_edition TEXT,
  main_ipc_classification_section TEXT,
  main_ipc_classification_class TEXT,
  main_ipc_classification_subclass TEXT,
  main_ipc_classification_main_group TEXT,
  main_ipc_classification_subgroup TEXT,
  main_ipc_classification_qualifying_character TEXT,
  main_national_classification_country TEXT,
  main_national_classification_text TEXT,
  main_national_classification_class TEXT,
  main_national_classification_subclass TEXT,
  number_of_claims INT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patents_pk
    PRIMARY KEY (country_code, doc_number, kind_code) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_patents IS 'Main table for Lexis Nexis patents';
COMMENT ON COLUMN lexis_nexis_patents.country_code IS --
  'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patents.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patents.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patents.language_of_filing IS --
  'Filing language, ISO639 language code, e.g, en,de,ja, etc.';
COMMENT ON COLUMN lexis_nexis_patents.language_of_publication IS --
  'Publication language, ISO639 language code, e.g, en,de,ja, etc.';
COMMENT ON COLUMN lexis_nexis_patents.date_of_public_availability_unexamined_printed_wo_grant IS --
  'Date of public availability of patent - un-examined printed without grant, e.g., 1980-06-25';
COMMENT ON COLUMN lexis_nexis_patents.date_of_public_availability_printed_w_grant IS --
  'Date of public availability of patent - printed with grant, e.g., 2003-08-06';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_text IS 'Classification IPC - main text';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_edition IS 'Classification IPC - main edition';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_section IS 'Classification IPC - main section';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_class IS 'Classification IPC - main class';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_subclass IS 'Classification IPC - main sub-class';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_main_group IS 'Classification IPC - main group';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_subgroup IS 'Classification IPC - main subgroup';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_qualifying_character IS 'Classification IPC - main qualifying character';
COMMENT ON COLUMN lexis_nexis_patents.main_national_classification_country IS 'Classification national - main country';
COMMENT ON COLUMN lexis_nexis_patents.main_national_classification_text IS 'Classification national - main text';
COMMENT ON COLUMN lexis_nexis_patents.main_national_classification_class IS 'Classification national - main class';
COMMENT ON COLUMN lexis_nexis_patents.main_national_classification_subclass IS 'Classification national - main subclass';
COMMENT ON COLUMN lexis_nexis_patents.number_of_claims IS 'Number of claims';
COMMENT ON COLUMN lexis_nexis_patents.last_updated_time IS 'Timestamp of particular record last updated';

-- endregion

-- DROP TABLE IF EXISTS lexis_nexis_patents_family_link;
CREATE TABLE lexis_nexis_patents_family_link (
  family_id INT,
  country_code TEXT NOT NULL,
  doc_number TEXT NOT NULL,
  kind_code TEXT NOT NULL,
  CONSTRAINT lexis_nexis_patents_family_link_pk
    PRIMARY KEY (family_id, country_code, doc_number, kind_code) USING INDEX TABLESPACE index_tbs,
  CONSTRAINT lnpfl_family_id_fk
    FOREIGN KEY (family_id)
      REFERENCES lexis_nexis_patent_families ON DELETE CASCADE,
  CONSTRAINT lnpfl_country_code_doc_number_kind_code_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
      REFERENCES lexis_nexis_patents ON DELETE CASCADE
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_patents_family_link IS 'Table linking patent family to patent table and family type table';
COMMENT ON COLUMN lexis_nexis_patents_family_link.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patents_family_link.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patents_family_link.country_code IS --
  'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patents_family_link.family_id IS 'ID for each family type';

-- endregion

-- region lexis_nexis_patent_titles
-- DROP TABLE IF EXISTS lexis_nexis_patent_titles;
CREATE TABLE lexis_nexis_patent_titles (
  country_code TEXT NOT NULL,
  doc_number TEXT NOT NULL,
  kind_code TEXT NOT NULL,
  invention_title TEXT NOT NULL,
  language TEXT NOT NULL,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_titles_pk
    PRIMARY KEY (country_code, doc_number, kind_code, language) USING INDEX TABLESPACE index_tbs,
  CONSTRAINT lexis_nexis_patent_titles_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
      REFERENCES lexis_nexis_patents ON DELETE CASCADE
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_patent_titles IS 'Patent titles';
COMMENT ON COLUMN lexis_nexis_patent_titles.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_titles.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_titles.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_titles.invention_title IS 'Preferably two to seven words when in English or translated into English and precise';
COMMENT ON COLUMN lexis_nexis_patent_titles.language IS 'Title text language';
COMMENT ON COLUMN lexis_nexis_patent_titles.last_updated_time IS 'Timestamp of particular record last updated';
-- endregion

-- region lexis_nexis_patent_citations
-- DROP TABLE IF EXISTS lexis_nexis_patent_citations;
CREATE TABLE lexis_nexis_patent_citations (
  country_code TEXT NOT NULL,
  doc_number TEXT NOT NULL,
  kind_code TEXT NOT NULL,
  seq_num INT NOT NULL,
  cited_doc_number TEXT NOT NULL,
  cited_country TEXT,
  cited_kind TEXT,
  cited_authors TEXT,
  cited_create_date DATE,
  cited_published_date DATE,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_citations_pk
    PRIMARY KEY (country_code, doc_number, kind_code, seq_num) USING INDEX TABLESPACE index_tbs,
  CONSTRAINT lexis_nexis_patent_citations_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
      REFERENCES lexis_nexis_patents ON DELETE CASCADE
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_patent_citations IS 'Citations for Lexis Nexis patents';
COMMENT ON COLUMN lexis_nexis_patent_citations.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_citations.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_citations.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_citations.seq_num IS 'Sequence number of patent in references';
COMMENT ON COLUMN lexis_nexis_patent_citations.cited_doc_number IS 'Document number of referenced patent';
COMMENT ON COLUMN lexis_nexis_patent_citations.cited_country IS 'Country code of patent';
COMMENT ON COLUMN lexis_nexis_patent_citations.cited_kind IS 'patent kind';
COMMENT ON COLUMN lexis_nexis_patent_citations.cited_authors IS 'patent authors';
COMMENT ON COLUMN lexis_nexis_patent_citations.cited_create_date IS 'Date patent was filed';
COMMENT ON COLUMN lexis_nexis_patent_citations.cited_published_date IS 'Date patent was published';
COMMENT ON COLUMN lexis_nexis_patent_citations.last_updated_time IS 'Timestamp of particular record last updated';

-- endregion

-- region lexis_nexis_nonpatent_literature_citations
-- DROP TABLE IF EXISTS lexis_nexis_nonpatent_literature_citations;
CREATE TABLE lexis_nexis_nonpatent_literature_citations (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  citation_number TEXT,
  citation_text TEXT,
  scopus_url VARCHAR(100),
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_nonpatent_literature_citations_pk
    PRIMARY KEY (country_code, doc_number, kind_code, citation_number) USING INDEX TABLESPACE index_tbs,
  CONSTRAINT lexis_nexis_nonpatent_literature_citations_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
      REFERENCES lexis_nexis_patents ON DELETE CASCADE
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_nonpatent_literature_citations IS 'Citations of non-patent publications';
COMMENT ON COLUMN lexis_nexis_nonpatent_literature_citations.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_nonpatent_literature_citations.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_nonpatent_literature_citations.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_nonpatent_literature_citations.citation_number IS 'Citation number';
COMMENT ON COLUMN lexis_nexis_nonpatent_literature_citations.citation_text IS 'Citation text';
COMMENT ON COLUMN lexis_nexis_nonpatent_literature_citations.scopus_url IS 'Scopus URL';
COMMENT ON COLUMN lexis_nexis_nonpatent_literature_citations.last_updated_time IS 'Timestamp of particular record last updated';

CREATE INDEX IF NOT EXISTS lnnlc_fun_scp_i ON --
  lexis_nexis_nonpatent_literature_citations(CAST(substring(scopus_url FROM 'eid=2-s2.0-(\d+)') AS BIGINT)) --
  TABLESPACE index_tbs;
-- endregion

-- region lexis_nexis_patent_priority_claims
-- DROP TABLE IF EXISTS lexis_nexis_patent_priority_claims;
CREATE TABLE lexis_nexis_patent_priority_claims (
  doc_number TEXT NOT NULL,
  country_code TEXT NOT NULL,
  kind_code TEXT NOT NULL,
  sequence_id INT NOT NULL,
  priority_claim_data_format TEXT,
  priority_claim_date DATE,
  priority_claim_country TEXT,
  priority_claim_doc_number TEXT,
  priority_claim_kind TEXT,
  priority_active_indicator TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_priority_claims_pk
    PRIMARY KEY (country_code, doc_number, kind_code, sequence_id,
                 priority_claim_data_format) USING INDEX TABLESPACE index_tbs,
  CONSTRAINT lexis_nexis_patent_priority_claims_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
      REFERENCES lexis_nexis_patents ON DELETE CASCADE
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_patent_priority_claims IS 'Priority claim information for a patent';
COMMENT ON COLUMN lexis_nexis_patent_priority_claims.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_priority_claims.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_priority_claims.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_priority_claims.sequence_id IS 'Priority claim sequence id in list';
COMMENT ON COLUMN lexis_nexis_patent_priority_claims.priority_claim_data_format IS 'Priority claim data format';
COMMENT ON COLUMN lexis_nexis_patent_priority_claims.priority_claim_date IS 'Priority claim date';
COMMENT ON COLUMN lexis_nexis_patent_priority_claims.priority_claim_country IS 'Priority claim country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_priority_claims.priority_claim_doc_number IS 'Priority claim document number';
COMMENT ON COLUMN lexis_nexis_patent_priority_claims.priority_claim_kind IS 'Priority claim document kind';
COMMENT ON COLUMN lexis_nexis_patent_priority_claims.priority_active_indicator IS 'Priority active indicator';
COMMENT ON COLUMN lexis_nexis_patent_priority_claims.last_updated_time IS 'Timestamp of particular record last updated';
-- endregion

/*-- region lexis_nexis_patent_priority_claim_ib_info
-- DROP TABLE IF EXISTS lexis_nexis_patent_priority_claim_ib_info;
CREATE TABLE lexis_nexis_patent_priority_claim_ib_info (
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_priority_claim_ib_info_pk PRIMARY KEY (country_code,doc_number,kind_code,language) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_patent_priority_claim_ib_info IS 'Additional priority claim information by IB';
COMMENT ON COLUMN lexis_nexis_patent_priority_claim_ib_info.last_updated_time IS '';
-- endregion*/

-- region lexis_nexis_patent_related_documents: tables can be modified based on parsing results
-- region lexis_nexis_patent_related_document_additions
-- DROP TABLE IF EXISTS lexis_nexis_patent_related_document_additions;
CREATE TABLE lexis_nexis_patent_related_document_additions (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  parent_doc_country TEXT,
  parent_doc_number TEXT,
  parent_doc_kind TEXT,
  parent_doc_name TEXT,
  parent_doc_date TEXT,
  parent_status TEXT,
  parent_grant_document_country TEXT,
  parent_grant_document_number TEXT,
  parent_grant_document_kind TEXT,
  parent_grant_document_name TEXT,
  parent_grant_document_date TEXT,
  parent_pct_document_country TEXT,
  parent_pct_document_number TEXT,
  parent_pct_document_kind TEXT,
  parent_pct_document_name TEXT,
  parent_pct_document_date TEXT,
  child_doc_country TEXT,
  child_doc_number TEXT,
  child_doc_kind TEXT,
  child_doc_name TEXT,
  child_doc_date TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_related_document_additions_pk --
    PRIMARY KEY (country_code, doc_number, kind_code, parent_doc_number) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

-- All columns in this table are extracted from .../addition elements
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_doc_country IS 'Country for parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_doc_number IS 'Parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_doc_kind IS 'Parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_doc_name IS 'Parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_doc_date IS 'Date for parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_status IS 'Parent document status';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_grant_document_country IS 'Country for granted parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_grant_document_number IS 'Granted parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_grant_document_kind IS 'Granted parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_grant_document_name IS 'Granted parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_grant_document_date IS 'Date for granted parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_pct_document_country IS 'Country for Parent Patent Cooperation Treaty (PCT) document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_pct_document_number IS 'Parent Patent Cooperation Treaty (PCT) document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_pct_document_kind IS 'Parent Patent Cooperation Treaty (PCT) document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_pct_document_name IS 'Parent Patent Cooperation Treaty (PCT) document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.parent_pct_document_date IS 'Date for Parent Patent Cooperation Treaty (PCT) document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.child_doc_country IS 'Country for child document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.child_doc_number IS 'Child document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.child_doc_kind IS 'Child document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.child_doc_name IS 'Child document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.child_doc_date IS 'Date for child document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_additions.last_updated_time IS 'Timestamp of particular record last updated';

-- Add foreign key
ALTER TABLE lexis_nexis_patent_related_document_additions
ADD CONSTRAINT lexis_nexis_patent_related_document_additions_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
    REFERENCES lexis_nexis_patents ON DELETE CASCADE;

-- end region

-- region lexis_nexis_patent_related_document_divisions
-- DROP TABLE IF EXISTS lexis_nexis_patent_related_document_divisions;
CREATE TABLE lexis_nexis_patent_related_document_divisions (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  parent_doc_country TEXT,
  parent_doc_number TEXT,
  parent_doc_kind TEXT,
  parent_doc_name TEXT,
  parent_doc_date TEXT,
  parent_status TEXT,
  parent_grant_document_country TEXT,
  parent_grant_document_number TEXT,
  parent_grant_document_kind TEXT,
  parent_grant_document_name TEXT,
  parent_grant_document_date TEXT,
  parent_pct_document_country TEXT,
  parent_pct_document_number TEXT,
  parent_pct_document_kind TEXT,
  parent_pct_document_name TEXT,
  parent_pct_document_date TEXT,
  child_doc_country TEXT,
  child_doc_number TEXT,
  child_doc_kind TEXT,
  child_doc_name TEXT,
  child_doc_date TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_related_document_divisions_pk --
    PRIMARY KEY (country_code, doc_number, kind_code, parent_doc_number) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

-- All columns in this table are extracted from .../division elements
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_doc_country IS 'Country for parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_doc_number IS 'Parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_doc_kind IS 'Parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_doc_name IS 'Parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_doc_date IS 'Date for parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_status IS 'Parent document status';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_grant_document_country IS 'Country for granted parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_grant_document_number IS 'Granted parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_grant_document_kind IS 'Granted parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_grant_document_name IS 'Granted parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_grant_document_date IS 'Date for granted parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_pct_document_country IS 'Country for Parent Patent Cooperation Treaty (PCT) document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_pct_document_number IS 'Parent Patent Cooperation Treaty (PCT) document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_pct_document_kind IS 'Parent Patent Cooperation Treaty (PCT) document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_pct_document_name IS 'Parent Patent Cooperation Treaty (PCT) document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.parent_pct_document_date IS 'Date for Parent Patent Cooperation Treaty (PCT) document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.child_doc_country IS 'Country for child document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.child_doc_number IS 'Child document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.child_doc_kind IS 'Child document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.child_doc_name IS 'Child document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.child_doc_date IS 'Date for child document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisions.last_updated_time IS 'Timestamp of particular record last updated';

-- Add foreign key
ALTER TABLE lexis_nexis_patent_related_document_divisions
ADD CONSTRAINT lexis_nexis_patent_related_document_divisions_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
    REFERENCES lexis_nexis_patents ON DELETE CASCADE;


-- end region


-- region lexis_nexis_patent_related_document_continuations
-- DROP TABLE IF EXISTS lexis_nexis_patent_related_document_continuations;
CREATE TABLE lexis_nexis_patent_related_document_continuations (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  parent_doc_country TEXT,
  parent_doc_number TEXT,
  parent_doc_kind TEXT,
  parent_doc_name TEXT,
  parent_doc_date TEXT,
  parent_status TEXT,
  parent_grant_document_country TEXT,
  parent_grant_document_number TEXT,
  parent_grant_document_kind TEXT,
  parent_grant_document_name TEXT,
  parent_grant_document_date TEXT,
  parent_pct_document_country TEXT,
  parent_pct_document_number TEXT,
  parent_pct_document_kind TEXT,
  parent_pct_document_name TEXT,
  parent_pct_document_date TEXT,
  child_doc_country TEXT,
  child_doc_number TEXT,
  child_doc_kind TEXT,
  child_doc_name TEXT,
  child_doc_date TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_related_document_continuations_pk
    PRIMARY KEY (country_code, doc_number, kind_code, parent_doc_number) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

-- All columns in this table are extracted from .../continuation elements
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_doc_country IS 'Country for parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_doc_number IS 'Parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_doc_kind IS 'Parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_doc_name IS 'Parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_doc_date IS 'Date for parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_status IS 'Parent document status';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_grant_document_country IS 'Country for granted parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_grant_document_number IS 'Granted parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_grant_document_kind IS 'Granted parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_grant_document_name IS 'Granted parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_grant_document_date IS 'Date for granted parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_pct_document_country IS 'Country for Parent Patent Cooperation Treaty (PCT) document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_pct_document_number IS 'Parent Patent Cooperation Treaty (PCT) document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_pct_document_kind IS 'Parent Patent Cooperation Treaty (PCT) document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_pct_document_name IS 'Parent Patent Cooperation Treaty (PCT) document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.parent_pct_document_date IS 'Date for Parent Patent Cooperation Treaty (PCT) document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.child_doc_country IS 'Country for child document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.child_doc_number IS 'Child document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.child_doc_kind IS 'Child document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.child_doc_name IS 'Child document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.child_doc_date IS 'Date for child document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuations.last_updated_time IS 'Timestamp of particular record last updated';

-- Add foreign key
ALTER TABLE lexis_nexis_patent_related_document_continuations
ADD CONSTRAINT lexis_nexis_patent_related_document_continuations_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
    REFERENCES lexis_nexis_patents ON DELETE CASCADE;


-- end region

-- region lexis_nexis_patent_related_document_continuation_in_parts
-- DROP TABLE IF EXISTS lexis_nexis_patent_related_document_continuation_in_parts;
CREATE TABLE lexis_nexis_patent_related_document_continuation_in_parts (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  parent_doc_country TEXT,
  parent_doc_number TEXT,
  parent_doc_kind TEXT,
  parent_doc_name TEXT,
  parent_doc_date TEXT,
  parent_status TEXT,
  parent_grant_document_country TEXT,
  parent_grant_document_number TEXT,
  parent_grant_document_kind TEXT,
  parent_grant_document_name TEXT,
  parent_grant_document_date TEXT,
  parent_pct_document_country TEXT,
  parent_pct_document_number TEXT,
  parent_pct_document_kind TEXT,
  parent_pct_document_name TEXT,
  parent_pct_document_date TEXT,
  child_doc_country TEXT,
  child_doc_number TEXT,
  child_doc_kind TEXT,
  child_doc_name TEXT,
  child_doc_date TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_related_document_continuation_in_parts_pk --
    PRIMARY KEY (country_code, doc_number, kind_code, parent_doc_number) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

-- All columns in this table are extracted from .../continuation-in-part elements
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_doc_country IS 'Country for parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_doc_number IS 'Parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_doc_kind IS 'Parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_doc_name IS 'Parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_doc_date IS 'Date for parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_status IS 'Parent document status';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_grant_document_country IS 'Country for granted parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_grant_document_number IS 'Granted parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_grant_document_kind IS 'Granted parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_grant_document_name IS 'Granted parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_grant_document_date IS 'Date for granted parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_pct_document_country IS 'Country for Parent Patent Cooperation Treaty (PCT) document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_pct_document_number IS 'Parent Patent Cooperation Treaty (PCT) document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_pct_document_kind IS 'Parent Patent Cooperation Treaty (PCT) document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_pct_document_name IS 'Parent Patent Cooperation Treaty (PCT) document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.parent_pct_document_date IS 'Date for Parent Patent Cooperation Treaty (PCT) document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.child_doc_country IS 'Country for child document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.child_doc_number IS 'Child document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.child_doc_kind IS 'Child document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.child_doc_name IS 'Child document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.child_doc_date IS 'Date for child document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuation_in_parts.last_updated_time IS 'Timestamp of particular record last updated';

-- Add foreign key
ALTER TABLE lexis_nexis_patent_related_document_continuation_in_parts
ADD CONSTRAINT lexis_nexis_patent_related_document_continuation_in_parts_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
    REFERENCES lexis_nexis_patents ON DELETE CASCADE;


-- end region

-- region lexis_nexis_patent_related_document_continuing_reissues
-- DROP TABLE IF EXISTS lexis_nexis_patent_related_document_continuing_reissues;
CREATE TABLE lexis_nexis_patent_related_document_continuing_reissues (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  parent_doc_country TEXT,
  parent_doc_number TEXT,
  parent_doc_kind TEXT,
  parent_doc_name TEXT,
  parent_doc_date TEXT,
  parent_status TEXT,
  parent_grant_document_country TEXT,
  parent_grant_document_number TEXT,
  parent_grant_document_kind TEXT,
  parent_grant_document_name TEXT,
  parent_grant_document_date TEXT,
  parent_pct_document_country TEXT,
  parent_pct_document_number TEXT,
  parent_pct_document_kind TEXT,
  parent_pct_document_name TEXT,
  parent_pct_document_date TEXT,
  child_doc_country TEXT,
  child_doc_number TEXT,
  child_doc_kind TEXT,
  child_doc_name TEXT,
  child_doc_date TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_related_document_continuing_reissues_pk --
    PRIMARY KEY (country_code, doc_number, kind_code, parent_doc_number) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

-- All columns in this table are extracted from .../continuing-reissue elements
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_doc_country IS 'Country for parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_doc_number IS 'Parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_doc_kind IS 'Parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_doc_name IS 'Parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_doc_date IS 'Date for parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_status IS 'Parent document status';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_grant_document_country IS 'Country for granted parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_grant_document_number IS 'Granted parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_grant_document_kind IS 'Granted parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_grant_document_name IS 'Granted parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_grant_document_date IS 'Date for granted parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_pct_document_country IS 'Country for Parent Patent Cooperation Treaty (PCT) document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_pct_document_number IS 'Parent Patent Cooperation Treaty (PCT) document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_pct_document_kind IS 'Parent Patent Cooperation Treaty (PCT) document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_pct_document_name IS 'Parent Patent Cooperation Treaty (PCT) document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.parent_pct_document_date IS 'Date for Parent Patent Cooperation Treaty (PCT) document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.child_doc_country IS 'Country for child document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.child_doc_number IS 'Child document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.child_doc_kind IS 'Child document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.child_doc_name IS 'Child document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.child_doc_date IS 'Date for child document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_continuing_reissues.last_updated_time IS 'Timestamp of particular record last updated';

-- Add foreign key
ALTER TABLE lexis_nexis_patent_related_document_continuing_reissues
ADD CONSTRAINT lexis_nexis_patent_related_document_continuing_reissues_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
    REFERENCES lexis_nexis_patents ON DELETE CASCADE;


-- end region

-- region lexis_nexis_patent_related_document_reissues
-- DROP TABLE IF EXISTS lexis_nexis_patent_related_document_reissues;
CREATE TABLE lexis_nexis_patent_related_document_reissues (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  parent_doc_country TEXT,
  parent_doc_number TEXT,
  parent_doc_kind TEXT,
  parent_doc_name TEXT,
  parent_doc_date TEXT,
  parent_status TEXT,
  parent_grant_document_country TEXT,
  parent_grant_document_number TEXT,
  parent_grant_document_kind TEXT,
  parent_grant_document_name TEXT,
  parent_grant_document_date TEXT,
  parent_pct_document_country TEXT,
  parent_pct_document_number TEXT,
  parent_pct_document_kind TEXT,
  parent_pct_document_name TEXT,
  parent_pct_document_date TEXT,
  child_doc_country TEXT,
  child_doc_number TEXT,
  child_doc_kind TEXT,
  child_doc_name TEXT,
  child_doc_date TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_related_document_reissues_pk --
    PRIMARY KEY (country_code, doc_number, kind_code, parent_doc_number) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

-- All columns in this table are extracted from .../reissue elements
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_doc_country IS 'Country for parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_doc_number IS 'Parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_doc_kind IS 'Parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_doc_name IS 'Parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_doc_date IS 'Date for parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_status IS 'Parent document status';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_grant_document_country IS 'Country for granted parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_grant_document_number IS 'Granted parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_grant_document_kind IS 'Granted parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_grant_document_name IS 'Granted parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_grant_document_date IS 'Date for granted parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_pct_document_country IS 'Country for Parent Patent Cooperation Treaty (PCT) document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_pct_document_number IS 'Parent Patent Cooperation Treaty (PCT) document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_pct_document_kind IS 'Parent Patent Cooperation Treaty (PCT) document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_pct_document_name IS 'Parent Patent Cooperation Treaty (PCT) document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.parent_pct_document_date IS 'Date for Parent Patent Cooperation Treaty (PCT) document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.child_doc_country IS 'Country for child document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.child_doc_number IS 'Child document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.child_doc_kind IS 'Child document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.child_doc_name IS 'Child document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.child_doc_date IS 'Date for child document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reissues.last_updated_time IS 'Timestamp of particular record last updated';

-- Add foreign key
ALTER TABLE lexis_nexis_patent_related_document_reissues
ADD CONSTRAINT lexis_nexis_patent_related_document_reissues_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
    REFERENCES lexis_nexis_patents ON DELETE CASCADE;


-- end region

-- region lexis_nexis_patent_related_document_divisional_reissues
-- DROP TABLE IF EXISTS lexis_nexis_patent_related_document_divisional_reissues;
CREATE TABLE lexis_nexis_patent_related_document_divisional_reissues (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  parent_doc_country TEXT,
  parent_doc_number TEXT,
  parent_doc_kind TEXT,
  parent_doc_name TEXT,
  parent_doc_date TEXT,
  parent_status TEXT,
  parent_grant_document_country TEXT,
  parent_grant_document_number TEXT,
  parent_grant_document_kind TEXT,
  parent_grant_document_name TEXT,
  parent_grant_document_date TEXT,
  parent_pct_document_country TEXT,
  parent_pct_document_number TEXT,
  parent_pct_document_kind TEXT,
  parent_pct_document_name TEXT,
  parent_pct_document_date TEXT,
  child_doc_country TEXT,
  child_doc_number TEXT,
  child_doc_kind TEXT,
  child_doc_name TEXT,
  child_doc_date TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_related_document_divisional_reissues_pk --
    PRIMARY KEY (country_code, doc_number, kind_code, parent_doc_number) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

-- All columns in this table are extracted from .../divisional-reissue elements
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_doc_country IS 'Country for parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_doc_number IS 'Parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_doc_kind IS 'Parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_doc_name IS 'Parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_doc_date IS 'Date for parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_status IS 'Parent document status';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_grant_document_country IS 'Country for granted parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_grant_document_number IS 'Granted parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_grant_document_kind IS 'Granted parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_grant_document_name IS 'Granted parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_grant_document_date IS 'Date for granted parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_pct_document_country IS 'Country for Parent Patent Cooperation Treaty (PCT) document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_pct_document_number IS 'Parent Patent Cooperation Treaty (PCT) document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_pct_document_kind IS 'Parent Patent Cooperation Treaty (PCT) document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_pct_document_name IS 'Parent Patent Cooperation Treaty (PCT) document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.parent_pct_document_date IS 'Date for Parent Patent Cooperation Treaty (PCT) document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.child_doc_country IS 'Country for child document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.child_doc_number IS 'Child document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.child_doc_kind IS 'Child document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.child_doc_name IS 'Child document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.child_doc_date IS 'Date for child document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_divisional_reissues.last_updated_time IS 'Timestamp of particular record last updated';

-- Add foreign key
ALTER TABLE lexis_nexis_patent_related_document_divisional_reissues
ADD CONSTRAINT lexis_nexis_patent_related_document_divisional_reissues_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
    REFERENCES lexis_nexis_patents ON DELETE CASCADE;


-- end region

-- region lexis_nexis_patent_related_document_reexaminations
-- DROP TABLE IF EXISTS lexis_nexis_patent_related_document_reexaminations;
CREATE TABLE lexis_nexis_patent_related_document_reexaminations (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  parent_doc_country TEXT,
  parent_doc_number TEXT,
  parent_doc_kind TEXT,
  parent_doc_name TEXT,
  parent_doc_date TEXT,
  parent_status TEXT,
  parent_grant_document_country TEXT,
  parent_grant_document_number TEXT,
  parent_grant_document_kind TEXT,
  parent_grant_document_name TEXT,
  parent_grant_document_date TEXT,
  parent_pct_document_country TEXT,
  parent_pct_document_number TEXT,
  parent_pct_document_kind TEXT,
  parent_pct_document_name TEXT,
  parent_pct_document_date TEXT,
  child_doc_country TEXT,
  child_doc_number TEXT,
  child_doc_kind TEXT,
  child_doc_name TEXT,
  child_doc_date TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_related_document_reexaminations_pk --
    PRIMARY KEY (country_code, doc_number, kind_code, parent_doc_number) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

-- All columns in this table are extracted from .../reexamination elements
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_doc_country IS 'Country for parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_doc_number IS 'Parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_doc_kind IS 'Parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_doc_name IS 'Parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_doc_date IS 'Date for parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_status IS 'Parent document status';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_grant_document_country IS 'Country for granted parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_grant_document_number IS 'Granted parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_grant_document_kind IS 'Granted parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_grant_document_name IS 'Granted parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_grant_document_date IS 'Date for granted parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_pct_document_country IS 'Country for Parent Patent Cooperation Treaty (PCT) document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_pct_document_number IS 'Parent Patent Cooperation Treaty (PCT) document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_pct_document_kind IS 'Parent Patent Cooperation Treaty (PCT) document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_pct_document_name IS 'Parent Patent Cooperation Treaty (PCT) document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.parent_pct_document_date IS 'Date for Parent Patent Cooperation Treaty (PCT) document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.child_doc_country IS 'Country for child document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.child_doc_number IS 'Child document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.child_doc_kind IS 'Child document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.child_doc_name IS 'Child document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.child_doc_date IS 'Date for child document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexaminations.last_updated_time IS 'Timestamp of particular record last updated';

-- Add foreign key
ALTER TABLE lexis_nexis_patent_related_document_reexaminations
ADD CONSTRAINT lexis_nexis_patent_related_document_reexaminations_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
    REFERENCES lexis_nexis_patents ON DELETE CASCADE;

-- region lexis_nexis_patent_related_document_reexamination_reissue_mergers
-- DROP TABLE IF EXISTS lexis_nexis_patent_related_document_reexamination_reissue_mergers;
CREATE TABLE lexis_nexis_patent_related_document_reexamination_reissue (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  parent_doc_country TEXT,
  parent_doc_number TEXT,
  parent_doc_kind TEXT,
  parent_doc_name TEXT,
  parent_doc_date TEXT,
  parent_status TEXT,
  parent_grant_document_country TEXT,
  parent_grant_document_number TEXT,
  parent_grant_document_kind TEXT,
  parent_grant_document_name TEXT,
  parent_grant_document_date TEXT,
  parent_pct_document_country TEXT,
  parent_pct_document_number TEXT,
  parent_pct_document_kind TEXT,
  parent_pct_document_name TEXT,
  parent_pct_document_date TEXT,
  child_doc_country TEXT,
  child_doc_number TEXT,
  child_doc_kind TEXT,
  child_doc_name TEXT,
  child_doc_date TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_related_document_reexamination_reissue_pk PRIMARY KEY (country_code,doc_number,kind_code,parent_doc_number) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

-- All columns in this table are extracted from .../reexamination-reissue-merge elements
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_doc_country IS 'Country for merge doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_doc_number IS 'Merge document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_doc_kind IS 'Merge document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_doc_name IS 'Merge document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_doc_date IS 'Date for Merge document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_status IS 'Merge document status';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_grant_document_country IS 'Country for granted parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_grant_document_number IS 'Granted parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_grant_document_kind IS 'Granted parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_grant_document_name IS 'Granted parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_grant_document_date IS 'Date for granted parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_pct_document_country IS 'Country for Parent Patent Cooperation Treaty (PCT) document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_pct_document_number IS 'Parent Patent Cooperation Treaty (PCT) document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_pct_document_kind IS 'Parent Patent Cooperation Treaty (PCT) document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_pct_document_name IS 'Parent Patent Cooperation Treaty (PCT) document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.parent_pct_document_date IS 'Date for Parent Patent Cooperation Treaty (PCT) document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.child_doc_country IS 'Country for child document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.child_doc_number IS 'Child document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.child_doc_kind IS 'Child document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.child_doc_name IS 'Child document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.child_doc_date IS 'Date for child document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_reexamination_reissue.last_updated_time IS 'Timestamp of particular record last updated';

-- Add foreign key
ALTER TABLE lexis_nexis_patent_related_document_reexamination_reissue
  ADD CONSTRAINT lexis_nexis_patent_related_document_reexamination_reissue_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
      REFERENCES lexis_nexis_patents ON DELETE CASCADE;

-- end region

-- region lexis_nexis_patent_related_document_substitutions
-- DROP TABLE IF EXISTS lexis_nexis_patent_related_document_substitutions;
CREATE TABLE lexis_nexis_patent_related_document_substitutions (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  parent_doc_country TEXT,
  parent_doc_number TEXT,
  parent_doc_kind TEXT,
  parent_doc_name TEXT,
  parent_doc_date TEXT,
  parent_status TEXT,
  parent_grant_document_country TEXT,
  parent_grant_document_number TEXT,
  parent_grant_document_kind TEXT,
  parent_grant_document_name TEXT,
  parent_grant_document_date TEXT,
  parent_pct_document_country TEXT,
  parent_pct_document_number TEXT,
  parent_pct_document_kind TEXT,
  parent_pct_document_name TEXT,
  parent_pct_document_date TEXT,
  child_doc_country TEXT,
  child_doc_number TEXT,
  child_doc_kind TEXT,
  child_doc_name TEXT,
  child_doc_date TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_related_document_substitutions_pk --
    PRIMARY KEY (country_code, doc_number, kind_code, parent_doc_number) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

-- All columns in this table are extracted from .../substitution elements
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_doc_country IS 'Country for parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_doc_number IS 'Parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_doc_kind IS 'Parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_doc_name IS 'Parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_doc_date IS 'Date for parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_status IS 'Parent document status';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_grant_document_country IS 'Country for granted parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_grant_document_number IS 'Granted parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_grant_document_kind IS 'Granted parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_grant_document_name IS 'Granted parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_grant_document_date IS 'Date for granted parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_pct_document_country IS 'Country for Parent Patent Cooperation Treaty (PCT) document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_pct_document_number IS 'Parent Patent Cooperation Treaty (PCT) document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_pct_document_kind IS 'Parent Patent Cooperation Treaty (PCT) document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_pct_document_name IS 'Parent Patent Cooperation Treaty (PCT) document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.parent_pct_document_date IS 'Date for Parent Patent Cooperation Treaty (PCT) document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.child_doc_country IS 'Country for child document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.child_doc_number IS 'Child document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.child_doc_kind IS 'Child document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.child_doc_name IS 'Child document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.child_doc_date IS 'Date for child document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_substitutions.last_updated_time IS 'Timestamp of particular record last updated';

-- Add foreign key
ALTER TABLE lexis_nexis_patent_related_document_substitutions
ADD CONSTRAINT lexis_nexis_patent_related_document_substitutions_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
    REFERENCES lexis_nexis_patents ON DELETE CASCADE;


-- end region

-- region lexis_nexis_patent_related_document_provisional_applications
-- DROP TABLE IF EXISTS lexis_nexis_patent_related_document_provisional_applications;
CREATE TABLE lexis_nexis_patent_related_document_provisional_applications (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  related_doc_country TEXT,
  related_doc_number TEXT,
  related_doc_kind TEXT,
  related_doc_name TEXT,
  related_doc_date TEXT,
  provisional_application_status TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_related_document_provisional_applications_pk --
    PRIMARY KEY (country_code, doc_number, kind_code, related_doc_number) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

-- All columns in this table are extracted from .../provisional-application elements
COMMENT ON COLUMN lexis_nexis_patent_related_document_provisional_applications.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_provisional_applications.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_provisional_applications.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_provisional_applications.related_doc_country IS 'Country for related document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_provisional_applications.related_doc_number IS 'Related document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_provisional_applications.related_doc_kind IS 'Related document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_provisional_applications.related_doc_name IS 'Related document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_provisional_applications.related_doc_date IS 'Date for related document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_provisional_applications.provisional_application_status IS 'Status for provisional application';
COMMENT ON COLUMN lexis_nexis_patent_related_document_provisional_applications.last_updated_time IS 'Timestamp of particular record last updated';

-- Add foreign key
ALTER TABLE lexis_nexis_patent_related_document_provisional_applications
ADD CONSTRAINT lexis_nexis_patent_related_document_provisional_applications_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
    REFERENCES lexis_nexis_patents ON DELETE CASCADE;


-- end region

-- region lexis_nexis_patent_related_document_utility_model_basis
-- DROP TABLE IF EXISTS lexis_nexis_patent_related_document_utility_model_basis;
CREATE TABLE lexis_nexis_patent_related_document_utility_model_basis (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  parent_doc_country TEXT,
  parent_doc_number TEXT,
  parent_doc_kind TEXT,
  parent_doc_name TEXT,
  parent_doc_date TEXT,
  parent_status TEXT,
  parent_grant_document_country TEXT,
  parent_grant_document_number TEXT,
  parent_grant_document_kind TEXT,
  parent_grant_document_name TEXT,
  parent_grant_document_date TEXT,
  parent_pct_document_country TEXT,
  parent_pct_document_number TEXT,
  parent_pct_document_kind TEXT,
  parent_pct_document_name TEXT,
  parent_pct_document_date TEXT,
  child_doc_country TEXT,
  child_doc_number TEXT,
  child_doc_kind TEXT,
  child_doc_name TEXT,
  child_doc_date TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_related_document_utility_model_basis_pk
    PRIMARY KEY (country_code, doc_number, kind_code, parent_doc_number) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

-- All columns in this table are extracted from .../utility-model-basis elements
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_doc_country IS 'Country for parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_doc_number IS 'Parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_doc_kind IS 'Parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_doc_name IS 'Parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_doc_date IS 'Date for parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_status IS 'Parent document status';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_grant_document_country IS 'Country for granted parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_grant_document_number IS 'Granted parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_grant_document_kind IS 'Granted parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_grant_document_name IS 'Granted parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_grant_document_date IS 'Date for granted parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_pct_document_country IS 'Country for Parent Patent Cooperation Treaty (PCT) document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_pct_document_number IS 'Parent Patent Cooperation Treaty (PCT) document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_pct_document_kind IS 'Parent Patent Cooperation Treaty (PCT) document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_pct_document_name IS 'Parent Patent Cooperation Treaty (PCT) document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.parent_pct_document_date IS 'Date for Parent Patent Cooperation Treaty (PCT) document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.child_doc_country IS 'Country for child document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.child_doc_number IS 'Child document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.child_doc_kind IS 'Child document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.child_doc_name IS 'Child document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.child_doc_date IS 'Date for child document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_utility_model_basis.last_updated_time IS 'Timestamp of particular record last updated';

-- Add foreign key
ALTER TABLE lexis_nexis_patent_related_document_utility_model_basis
ADD CONSTRAINT lexis_nexis_patent_related_document_utility_model_basis_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
    REFERENCES lexis_nexis_patents ON DELETE CASCADE;


-- end region

--  *** haven't found any sample data yet so remove this empty table temporarily ***
-- region lexis_nexis_patent_related_corrections
-- DROP TABLE IF EXISTS lexis_nexis_patent_related_corrections;
-- CREATE TABLE lexis_nexis_patent_related_corrections (
--   country_code TEXT,
--   doc_number TEXT,
--   kind_code TEXT,
--   corrected_doc_country TEXT,
--   corrected_doc_number TEXT,
--   corrected_doc_kind TEXT,
--   corrected_doc_name TEXT,
--   corrected_doc_date TEXT,
--   correction_type TEXT,
--   gazette_num TEXT,
--   gazette_reference_date TEXT,
--   gazette_text TEXT,
--   last_updated_time TIMESTAMP DEFAULT now(),
--   CONSTRAINT lexis_nexis_patent_related_corrections_pk
--     PRIMARY KEY (country_code, doc_number, kind_code, corrected_doc_number) USING INDEX TABLESPACE index_tbs
-- )
-- TABLESPACE lexis_nexis_tbs;
--
-- -- Add foreign key
-- ALTER TABLE lexis_nexis_patent_related_corrections
-- ADD CONSTRAINT lexis_nexis_patent_related_corrections_fk
--     FOREIGN KEY (country_code, doc_number, kind_code)
--     REFERENCES lexis_nexis_patents ON DELETE CASCADE;


-- end region

-- region lexis_nexis_patent_related_publications
-- DROP TABLE IF EXISTS lexis_nexis_patent_related_publications;
CREATE TABLE lexis_nexis_patent_related_publications (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  related_pub_country TEXT,
  related_pub_number TEXT,
  related_pub_kind TEXT,
  related_pub_name TEXT,
  related_pub_date TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_related_publications_pk --
    PRIMARY KEY (country_code, doc_number, kind_code, related_pub_number) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

-- All columns in this table are extracted from .../related-publication elements
COMMENT ON COLUMN lexis_nexis_patent_related_publications.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_publications.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_related_publications.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_publications.related_pub_country IS 'Country for related document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_publications.related_pub_number IS 'Related document number';
COMMENT ON COLUMN lexis_nexis_patent_related_publications.related_pub_kind IS 'Related document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_publications.related_pub_name IS 'Related document name';
COMMENT ON COLUMN lexis_nexis_patent_related_publications.related_pub_date IS 'Date for related document';
COMMENT ON COLUMN lexis_nexis_patent_related_publications.last_updated_time IS 'Timestamp of particular record last updated';

-- Add foreign key
ALTER TABLE lexis_nexis_patent_related_publications
ADD CONSTRAINT lexis_nexis_patent_related_publications_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
    REFERENCES lexis_nexis_patents ON DELETE CASCADE;


-- end region

-- region lexis_nexis_patent_related_document_371_international
-- DROP TABLE IF EXISTS lexis_nexis_patent_related_document_371_international;
CREATE TABLE lexis_nexis_patent_related_document_371_international (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  parent_doc_country TEXT,
  parent_doc_number TEXT,
  parent_doc_kind TEXT,
  parent_doc_name TEXT,
  parent_doc_date TEXT,
  parent_status TEXT,
  parent_grant_document_country TEXT,
  parent_grant_document_number TEXT,
  parent_grant_document_kind TEXT,
  parent_grant_document_name TEXT,
  parent_grant_document_date TEXT,
  parent_pct_document_country TEXT,
  parent_pct_document_number TEXT,
  parent_pct_document_kind TEXT,
  parent_pct_document_name TEXT,
  parent_pct_document_date TEXT,
  child_doc_country TEXT,
  child_doc_number TEXT,
  child_doc_kind TEXT,
  child_doc_name TEXT,
  child_doc_date TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_related_document_371_international_pk
    PRIMARY KEY (country_code, doc_number, kind_code, parent_doc_number) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

-- All columns in this table are extracted from .../a-371-of-international elements
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_doc_country IS 'Country for parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_doc_number IS 'Parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_doc_kind IS 'Parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_doc_name IS 'Parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_doc_date IS 'Date for parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_status IS 'Parent document status';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_grant_document_country IS 'Country for granted parent doc: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_grant_document_number IS 'Granted parent document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_grant_document_kind IS 'Granted parent document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_grant_document_name IS 'Granted parent document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_grant_document_date IS 'Date for granted parent document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_pct_document_country IS 'Country for Parent Patent Cooperation Treaty (PCT) document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_pct_document_number IS 'Parent Patent Cooperation Treaty (PCT) document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_pct_document_kind IS 'Parent Patent Cooperation Treaty (PCT) document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_pct_document_name IS 'Parent Patent Cooperation Treaty (PCT) document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.parent_pct_document_date IS 'Date for Parent Patent Cooperation Treaty (PCT) document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.child_doc_country IS 'Country for child document: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.child_doc_number IS 'Child document number';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.child_doc_kind IS 'Child document kind';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.child_doc_name IS 'Child document name';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.child_doc_date IS 'Date for child document';
COMMENT ON COLUMN lexis_nexis_patent_related_document_371_international.last_updated_time IS 'Timestamp of particular record last updated';
-- Add foreign key
ALTER TABLE lexis_nexis_patent_related_document_371_international
ADD CONSTRAINT lexis_nexis_patent_related_document_371_international_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
    REFERENCES lexis_nexis_patents ON DELETE CASCADE;

--COMMENT ON TABLE lexis_nexis_patent_related_documents IS 'Various relationships between the patent in hand and other patent grants or applications. Contains either an additional application, a divisional application, continuations, reissues, divisional reissues, reexamination, merged reissues reexamination, substitute, or provisional application';
--COMMENT ON COLUMN lexis_nexis_patent_related_documents.last_updated_time IS '';
-- endregion

-- region lexis_nexis_patent_application_references
-- DROP TABLE IF EXISTS lexis_nexis_patent_application_references;
CREATE TABLE lexis_nexis_patent_application_references (
  country_code TEXT NOT NULL,
  doc_number TEXT NOT NULL,
  kind_code TEXT NOT NULL,
  appl_ref_type TEXT,
  appl_ref_doc_number TEXT NOT NULL,
  appl_ref_country TEXT,
  appl_ref_date DATE,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_application_references_pk
    PRIMARY KEY (country_code, doc_number, kind_code,
                 appl_ref_country,
                 appl_ref_doc_number) USING INDEX TABLESPACE index_tbs,
  CONSTRAINT lexis_nexis_patent_application_references_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
      REFERENCES lexis_nexis_patents ON DELETE CASCADE
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_patent_application_references IS 'Application reference information: application number, country';
COMMENT ON COLUMN lexis_nexis_patent_application_references.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_application_references.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_application_references.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_application_references.appl_ref_type IS 'Document number of Application reference';
COMMENT ON COLUMN lexis_nexis_patent_application_references.appl_ref_country IS 'Country of Application reference';
COMMENT ON COLUMN lexis_nexis_patent_application_references.appl_ref_date IS 'Date of Application reference';
COMMENT ON COLUMN lexis_nexis_patent_application_references.last_updated_time IS 'Timestamp of particular record last updated';

-- endregion

-- region lexis_nexis_applicants
CREATE TABLE lexis_nexis_applicants (
  country_code TEXT NOT NULL,
  doc_number TEXT NOT NULL,
  kind_code TEXT NOT NULL,
  sequence SMALLINT NOT NULL,
  language TEXT,
  designation TEXT,
  organization_name TEXT,
  organization_type TEXT,
  organization_country TEXT,
  organization_state TEXT,
  organization_city TEXT,
  organization_address TEXT,
  registered_number TEXT,
  issuing_office TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_applicants_pk
    PRIMARY KEY (country_code, doc_number, kind_code, sequence) USING INDEX TABLESPACE index_tbs,
  CONSTRAINT lexis_nexis_applicants_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
      REFERENCES lexis_nexis_patents ON DELETE CASCADE
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_applicants IS 'Table for applicants information';
COMMENT ON COLUMN lexis_nexis_applicants.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_applicants.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_applicants.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_applicants.sequence IS 'Sequence number of applicant';
COMMENT ON COLUMN lexis_nexis_applicants.language IS 'Language Ex: eng';
COMMENT ON COLUMN lexis_nexis_applicants.designation IS 'Designation of applicant Ex: us-only';
COMMENT ON COLUMN lexis_nexis_applicants.organization_name IS 'Organization name Ex: Caterpillar Inc';
COMMENT ON COLUMN lexis_nexis_applicants.organization_type IS 'Organization type Ex: corporate';
COMMENT ON COLUMN lexis_nexis_applicants.organization_country IS 'Organization country';
COMMENT ON COLUMN lexis_nexis_applicants.organization_state IS 'Organization state';
COMMENT ON COLUMN lexis_nexis_applicants.organization_city IS 'Organization city';
COMMENT ON COLUMN lexis_nexis_applicants.organization_address IS 'Address of the Organization ';
COMMENT ON COLUMN lexis_nexis_applicants.registered_number IS 'Registered number of the organization';
COMMENT ON COLUMN lexis_nexis_applicants.issuing_office IS 'Office issuing registered number Ex: European Patent Office';
COMMENT ON COLUMN lexis_nexis_applicants.last_updated_time IS 'Timestamp of particular record last updated';
-- endregion

-- region lexis_nexis_inventors
-- DROP TABLE IF EXISTS lexis_nexis_inventors;
CREATE TABLE lexis_nexis_inventors (
  country_code TEXT NOT NULL,
  doc_number TEXT NOT NULL,
  kind_code TEXT NOT NULL,
  inventor_sequence INT NOT NULL,
  language TEXT,
  name TEXT,
  address_1 TEXT,
  address_2 TEXT,
  address_3 TEXT,
  address_4 TEXT,
  address_5 TEXT,
  mailcode TEXT,
  pobox TEXT,
  room TEXT,
  address_floor TEXT,
  building TEXT,
  street TEXT,
  city TEXT,
  county TEXT,
  postcode TEXT,
  country TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_inventors_pk
    PRIMARY KEY (country_code, doc_number, kind_code, inventor_sequence) USING INDEX TABLESPACE index_tbs,
  CONSTRAINT lexis_nexis_inventors_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
      REFERENCES lexis_nexis_patents ON DELETE CASCADE
)
TABLESPACE lexis_nexis_tbs;

CREATE INDEX lni_name_i ON lexis_nexis_inventors(name) TABLESPACE index_tbs;

COMMENT ON TABLE lexis_nexis_inventors IS 'Inventors information';
COMMENT ON COLUMN lexis_nexis_inventors.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_inventors.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_inventors.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_inventors.inventor_sequence IS 'Element in the list of inventors';
COMMENT ON COLUMN lexis_nexis_inventors.language IS 'Document language';
COMMENT ON COLUMN lexis_nexis_inventors.name IS 'The name of the inventor';
COMMENT ON COLUMN lexis_nexis_inventors.city IS 'The city of the inventor';
COMMENT ON COLUMN lexis_nexis_inventors.country IS 'The country of the inventor';
COMMENT ON COLUMN lexis_nexis_inventors.last_updated_time IS 'Timestamp of particular record last updated';
-- endregion

-- region lexis_nexis_us_agents
-- DROP TABLE IF EXISTS lexis_nexis_us_agents;
CREATE TABLE lexis_nexis_us_agents (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  sequence SMALLINT,
  agent_type TEXT,
  language TEXT,
  agent_name TEXT,
  last_name TEXT,
  first_name TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_us_agents_pk
    PRIMARY KEY (country_code, doc_number, kind_code, sequence) USING INDEX TABLESPACE index_tbs,
  CONSTRAINT lexis_nexis_us_agents_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
      REFERENCES lexis_nexis_patents ON DELETE CASCADE
)
TABLESPACE lexis_nexis_tbs;
COMMENT ON TABLE lexis_nexis_us_agents IS 'Information regarding Agents or common representatives for US patents';
COMMENT ON COLUMN lexis_nexis_us_agents.country_code IS --
  'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_us_agents.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_us_agents.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_us_agents.language IS 'Document language';
COMMENT ON COLUMN lexis_nexis_us_agents.sequence IS 'Element in the list of agents';
COMMENT ON COLUMN lexis_nexis_us_agents.agent_name IS 'The name of the agent';
COMMENT ON COLUMN lexis_nexis_us_agents.agent_type IS 'The kind of representative';
COMMENT ON COLUMN lexis_nexis_us_agents.last_name IS 'Last name of the agent';
COMMENT ON COLUMN lexis_nexis_us_agents.first_name IS 'First name of the agent';
COMMENT ON COLUMN lexis_nexis_us_agents.last_updated_time IS 'Timestamp of particular record last updated';

-- region lexis_nexis_ep_agents
-- DROP TABLE IF EXISTS lexis_nexis_ep_agents;
CREATE TABLE lexis_nexis_ep_agents (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  sequence SMALLINT,
  agent_type TEXT,
  language TEXT,
  agent_name TEXT,
  agent_registration_num TEXT,
  issuing_office TEXT,
  agent_address TEXT,
  agent_city TEXT,
  agent_country TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_ep_agents_pk
    PRIMARY KEY (country_code, doc_number, kind_code, sequence) USING INDEX TABLESPACE index_tbs,
  CONSTRAINT lexis_nexis_ep_agents_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
      REFERENCES lexis_nexis_patents ON DELETE CASCADE
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_ep_agents IS 'Information regarding Agents or common representatives for EP patents';
COMMENT ON COLUMN lexis_nexis_ep_agents.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_ep_agents.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_ep_agents.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_ep_agents.language IS 'Document language';
COMMENT ON COLUMN lexis_nexis_ep_agents.sequence IS 'Element in the list of agents';
COMMENT ON COLUMN lexis_nexis_ep_agents.agent_name IS 'The name of the agent';
COMMENT ON COLUMN lexis_nexis_ep_agents.agent_type IS 'The kind of representative';
COMMENT ON COLUMN lexis_nexis_ep_agents.agent_registration_num IS 'The registration number of the representative';
COMMENT ON COLUMN lexis_nexis_ep_agents.issuing_office IS 'The issuing office that gave the number to the representative';
COMMENT ON COLUMN lexis_nexis_ep_agents.agent_address IS 'The address of the representative';
COMMENT ON COLUMN lexis_nexis_ep_agents.agent_city IS 'The city of the representative';
COMMENT ON COLUMN lexis_nexis_ep_agents.agent_country IS 'The country of the representative';
COMMENT ON COLUMN lexis_nexis_ep_agents.last_updated_time IS 'Timestamp of particular record last updated';
-- endregion

-- region lexis_nexis_examiners
-- DROP TABLE IF EXISTS lexis_nexis_examiners;
CREATE TABLE lexis_nexis_examiners (
  country_code TEXT,
  doc_number TEXT,
  kind_code TEXT,
  primary_last_name TEXT,
  primary_first_name TEXT,
  primary_department TEXT,
  assistant_last_name TEXT,
  assistant_first_name TEXT,
  assistant_department TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_examiners_pk
    PRIMARY KEY (country_code, doc_number, kind_code) USING INDEX TABLESPACE index_tbs,
  CONSTRAINT lexis_nexis_patent_examiners_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
      REFERENCES lexis_nexis_patents ON DELETE CASCADE
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_examiners IS 'Persons acting on the document';
COMMENT ON COLUMN lexis_nexis_examiners.last_updated_time IS 'Timestamp of particular record last updated';
-- endregion

-- region lexis_nexis_patent_legal_data
-- DROP TABLE IF EXISTS lexis_nexis_patent_legal_data;
CREATE TABLE lexis_nexis_patent_legal_data (
  country_code TEXT NOT NULL,
  doc_number TEXT NOT NULL,
  kind_code TEXT NOT NULL,
  sequence_id INT NOT NULL,
  publication_date DATE,
  event_code_1 TEXT,
  event_code_2 TEXT,
  effect TEXT,
  legal_description TEXT,
  status_identifier TEXT,
  docdb_publication_number TEXT,
  docdb_application_id TEXT,
  designated_state_authority TEXT,
  designated_state_event_code TEXT,
  designated_state_description TEXT,
  corresponding_publication_number TEXT,
  corresponding_authority TEXT,
  corresponding_publication_date TEXT,
  corresponding_kind TEXT,
  legal_designated_states TEXT,
  extension_state_authority TEXT,
  new_owner TEXT,
  free_text_description TEXT,
  spc_number TEXT,
  filing_date TEXT,
  expiry_date TEXT,
  inventor_name TEXT,
  ipc TEXT,
  representative_name TEXT,
  payment_date TEXT,
  opponent_name TEXT,
  fee_payment_year TEXT,
  requester_name TEXT,
  countries_concerned TEXT,
  effective_date TEXT,
  withdrawn_date TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_legal_data_pk
    PRIMARY KEY (country_code, doc_number, kind_code, sequence_id) USING INDEX TABLESPACE index_tbs,
  CONSTRAINT lexis_nexis_patent_legal_data_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
      REFERENCES lexis_nexis_patents ON DELETE CASCADE
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_patent_legal_data IS 'Legal status data information table';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.sequence_id IS 'ID within legal event sequence list';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.publication_date IS 'Legal publication date';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.event_code_1 IS 'Legal event code #1';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.event_code_2 IS 'Legal event code #2';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.effect IS 'Legal effect, i.e. + or -';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.legal_description IS 'Legal description';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.status_identifier IS 'Legal status identifier';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.docdb_publication_number IS 'Legal DocDb publication number';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.docdb_application_id IS 'Legal DocDb application unique identifier';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.designated_state_authority IS 'Legal designated state authority';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.designated_state_event_code IS 'Legal designated state event code';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.designated_state_description IS 'Legal designated state description';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.corresponding_publication_number IS 'Legal corresponding publication number';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.corresponding_authority IS 'Legal corresponding authority';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.corresponding_publication_date IS 'Legal corresponding publication date';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.corresponding_kind IS 'Legal corresponding kind';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.legal_designated_states IS 'Legal designated states';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.extension_state_authority IS 'Legal extension state authority';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.new_owner IS 'Legal new owner';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.free_text_description IS 'Legal free text description';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.spc_number IS 'Legal spc number';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.filing_date IS 'Legal filing date';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.expiry_date IS 'Legal expiration date';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.inventor_name IS 'Legal inventor name';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.ipc IS 'Legal ipc';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.representative_name IS 'Legal representative name';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.payment_date IS 'Legal payment date';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.opponent_name IS 'Legal opponent name';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.fee_payment_year IS 'Legal fee payment year';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.requester_name IS 'Legal requester name';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.countries_concerned IS 'Legal countries concerned';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.effective_date IS 'Legal effective date';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.withdrawn_date IS 'Legal withdrawn date';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.last_updated_time IS 'Timestamp of particular record last updated';
-- endregion

-- region lexis_nexis_patent_abstracts

-- DROP TABLE IF EXISTS lexis_nexis_patent_abstracts;
CREATE TABLE lexis_nexis_patent_abstracts (
  country_code TEXT NOT NULL,
  doc_number TEXT NOT NULL,
  kind_code TEXT NOT NULL,
  abstract_language TEXT,
  abstract_date_changed TEXT,
  abstract_text TEXT NOT NULL,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_abstracts_pk
    PRIMARY KEY (country_code, doc_number, kind_code, abstract_language) USING INDEX TABLESPACE index_tbs,
  CONSTRAINT lexis_nexis_patent_abstracts_fk
    FOREIGN KEY (country_code, doc_number, kind_code)
      REFERENCES lexis_nexis_patents ON DELETE CASCADE
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_patent_abstracts IS 'Patent abstract information table';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.abstract_language IS 'Language used in the abstract';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.abstract_date_changed IS 'Date the abstract was last changed at the source data end';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.abstract_text IS 'Abstract text';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.last_updated_time IS 'Timestamp of particular record last updated';

-- endregion

