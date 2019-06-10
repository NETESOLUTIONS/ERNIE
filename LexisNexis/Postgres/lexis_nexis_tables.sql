\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
SET search_path TO public;

-- region lexis_nexis_patents
DROP TABLE IF EXISTS lexis_nexis_patents;
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
  CONSTRAINT lexis_nexis_patents_pk PRIMARY KEY (country_code,doc_number,kind_code) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_patents IS 'Main table for Lexis Nexis patents';
COMMENT ON COLUMN lexis_nexis_patents.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patents.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patents.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patents.language_of_filing IS 'Filing language, ISO639 language code, e.g, en,de,ja, etc.';
COMMENT ON COLUMN lexis_nexis_patents.language_of_publication IS 'Publication language, ISO639 language code, e.g, en,de,ja, etc.';
COMMENT ON COLUMN lexis_nexis_patents.date_of_public_availability_unexamined_printed_wo_grant IS '';
COMMENT ON COLUMN lexis_nexis_patents.date_of_public_availability_printed_w_grant IS '';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_text IS '';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_edition IS '';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_section IS '';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_class IS '';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_subclass IS '';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_main_group IS '';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_subgroup IS '';
COMMENT ON COLUMN lexis_nexis_patents.main_ipc_classification_qualifying_character IS '';
COMMENT ON COLUMN lexis_nexis_patents.main_national_classification_country IS '';
COMMENT ON COLUMN lexis_nexis_patents.main_national_classification_text IS '';
COMMENT ON COLUMN lexis_nexis_patents.main_national_classification_class IS '';
COMMENT ON COLUMN lexis_nexis_patents.main_national_classification_subclass IS '';
COMMENT ON COLUMN lexis_nexis_patents.number_of_claims IS 'Number of claims';
COMMENT ON COLUMN lexis_nexis_patents.last_updated_time IS '';
-- endregion

-- region lexis_nexis_patent_titles
DROP TABLE IF EXISTS lexis_nexis_patent_titles;
CREATE TABLE lexis_nexis_patent_titles (
  country_code TEXT NOT NULL,
  doc_number TEXT NOT NULL,
  kind_code TEXT NOT NULL,
  invention_title TEXT NOT NULL,
  language TEXT NOT NULL,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_titles_pk PRIMARY KEY (country_code,doc_number,kind_code,language) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_patents IS 'Patent titles';
COMMENT ON COLUMN lexis_nexis_patents_titles.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patents_titles.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_titles.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_titles.invention_title IS 'Preferably two to seven words when in English or translated into English and precise';
COMMENT ON COLUMN lexis_nexis_patent_titles.language IS 'Title text language';
COMMENT ON COLUMN lexis_nexis_patent_titles.last_updated_time IS '';
-- endregion

-- region lexis_nexis_patent_citations
DROP TABLE IF EXISTS lexis_nexis_patent_citations;
CREATE TABLE lexis_nexis_patent_citations (
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_citations_pk PRIMARY KEY (country_code,doc_number,kind_code,language) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_citations IS 'Patent-patent citations';
COMMENT ON COLUMN lexis_nexis_nonpatent_literature_citations.last_updated_time IS '';
-- endregion

-- region lexis_nexis_nonpatent_literature_citations
DROP TABLE IF EXISTS lexis_nexis_nonpatent_literature_citations;
CREATE TABLE lexis_nexis_nonpatent_literature_citations (
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_nonpatent_literature_citations_pk PRIMARY KEY (country_code,doc_number,kind_code,language) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_nonpatent_literature_citations IS 'Patent-NPL citations';
COMMENT ON COLUMN lexis_nexis_nonpatent_literature_citations.last_updated_time IS '';
-- endregion

-- region lexis_nexis_patent_priority_claims
DROP TABLE IF EXISTS lexis_nexis_patent_priority_claims;
CREATE TABLE lexis_nexis_patent_priority_claims (
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_priority_claims_pk PRIMARY KEY (country_code,doc_number,kind_code,language) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_patent_priority_claims IS 'Priority claim information for a patent';
COMMENT ON COLUMN lexis_nexis_patent_priority_claims.last_updated_time IS '';
-- endregion

-- region lexis_nexis_patent_priority_claim_ib_info
DROP TABLE IF EXISTS lexis_nexis_patent_priority_claim_ib_info;
CREATE TABLE lexis_nexis_patent_priority_claim_ib_info (
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_priority_claim_ib_info_pk PRIMARY KEY (country_code,doc_number,kind_code,language) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_patent_priority_claim_ib_info IS 'Additional priority claim information by IB';
COMMENT ON COLUMN lexis_nexis_patent_priority_claim_ib_info.last_updated_time IS '';
-- endregion

-- region lexis_nexis_patent_related_documents
DROP TABLE IF EXISTS lexis_nexis_patent_related_documents;
CREATE TABLE lexis_nexis_patent_related_documents (
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_related_documents_pk PRIMARY KEY (country_code,doc_number,kind_code,language) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_patent_related_documents IS 'Various relationships between the patent in hand and other patent grants or applications. Contains either an additional application, a divisional application, continuations, reissues, divisional reissues, reexamination, merged reissues reexamination, substitute, or provisional application';
COMMENT ON COLUMN lexis_nexis_patent_related_documents.last_updated_time IS '';
-- endregion

-- region lexis_nexis_patent_application_references
DROP TABLE IF EXISTS lexis_nexis_patent_application_references;
CREATE TABLE lexis_nexis_patent_application_references (
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_application_references_pk PRIMARY KEY (country_code,doc_number,kind_code,language) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_patent_application_references IS 'Application reference information: application number, country';
COMMENT ON COLUMN lexis_nexis_patent_application_references.last_updated_time IS '';
-- endregion

-- region lexis_nexis_patent_application_references
DROP TABLE IF EXISTS lexis_nexis_patent_application_references;
CREATE TABLE lexis_nexis_patent_application_references (
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_application_references_pk PRIMARY KEY (country_code,doc_number,kind_code,language) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_patent_application_references IS 'Application reference information: application number, country';
COMMENT ON COLUMN lexis_nexis_patent_application_references.last_updated_time IS '';
-- endregion

-- region lexis_nexis_applicants
DROP TABLE IF EXISTS lexis_nexis_applicants;
CREATE TABLE lexis_nexis_applicants (
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_applicants_pk PRIMARY KEY (country_code,doc_number,kind_code,language) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_applicants IS 'Applicants information';
COMMENT ON COLUMN lexis_nexis_applicants.last_updated_time IS '';
-- endregion

-- region lexis_nexis_inventors
DROP TABLE IF EXISTS lexis_nexis_inventors;
CREATE TABLE lexis_nexis_inventors (
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_inventors_pk PRIMARY KEY (country_code,doc_number,kind_code,language) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_inventors IS 'Inventors information';
COMMENT ON COLUMN lexis_nexis_inventors.last_updated_time IS '';
-- endregion

-- region lexis_nexis_agents
DROP TABLE IF EXISTS lexis_nexis_agents;
CREATE TABLE lexis_nexis_agents (
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_agents_pk PRIMARY KEY (country_code,doc_number,kind_code,language) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_agents IS 'Information regarding Agents or common representatives';
COMMENT ON COLUMN lexis_nexis_agents.last_updated_time IS '';
-- endregion





-- region lexis_nexis_examiners
DROP TABLE IF EXISTS lexis_nexis_examiners;
CREATE TABLE lexis_nexis_examiners (
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_examiners_pk PRIMARY KEY (country_code,doc_number,kind_code,language) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_examiners IS 'Persons acting on the document';
COMMENT ON COLUMN lexis_nexis_examiners.last_updated_time IS '';
-- endregion




-- region lexis_nexis_patent_legal_data
DROP TABLE IF EXISTS lexis_nexis_patent_legal_data;
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
  CONSTRAINT lexis_nexis_patent_legal_data_pk PRIMARY KEY (country_code,doc_number,kind_code,sequence_id) USING INDEX TABLESPACE index_tbs
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
COMMENT ON COLUMN lexis_nexis_patent_legal_data.legal_designated_states IS '';
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
COMMENT ON COLUMN lexis_nexis_patent_legal_data.last_updated_time IS '';
-- endregion

-- region lexis_nexis_patent_abstracts
DROP TABLE IF EXISTS lexis_nexis_patent_abstracts;
CREATE TABLE lexis_nexis_patent_abstracts (
  country_code TEXT NOT NULL,
  doc_number TEXT NOT NULL,
  kind_code TEXT NOT NULL,
  abstract_language TEXT,
  abstract_date_changed TEXT,
  abstract_text TEXT NOT NULL,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_abstracts_pk PRIMARY KEY (country_code,doc_number,kind_code,abstract_language) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

COMMENT ON TABLE lexis_nexis_patent_abstracts IS 'Patent abstract information table';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.country_code IS 'Country: use ST.3 country code, e.g. DE, FR, GB, NL, etc. Also includes EP, WO, etc.';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.doc_number IS 'Document number';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.kind_code IS 'Document kind';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.abstract_language IS 'Language used in the abstract';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.abstract_date_changed IS 'Date the abstract was last changed at the source data end';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.abstract_text IS 'Abstract text';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.last_updated_time IS '';
-- endregion
