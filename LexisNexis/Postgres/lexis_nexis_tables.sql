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
  date_of_public_availability_unexamined_printed_wo_grant TEXT,
  date_of_public_availability_printed_w_grant TEXT,
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
  invention_title TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patents_pk PRIMARY KEY (country_code,doc_number,kind_code) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_patent_legal_data IS 'Legal status data information table';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.country_code IS 'The patent country code. Example: US';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.doc_number IS 'The patent doc number. Example: 20070009474';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.kind_code IS 'The patent kind code. Example: A1';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.sequence_id IS 'Sequence id for the legal event. Example: 1';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.publication_date IS 'Date of publication for the legal event. Example: {}';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.event_code IS 'The CODEN code that uniquely identifies the source. Example: AHJOA';
-- endregion




-- region lexis_nexis_patent_legal_data
DROP TABLE IF EXISTS lexis_nexis_patent_legal_data;
CREATE TABLE lexis_nexis_patent_legal_data (
  country_code TEXT NOT NULL,
  doc_number TEXT NOT NULL,
  kind_code TEXT NOT NULL,
  sequence_id INT NOT NULL,
  publication_date TEXT,
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

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_patent_legal_data IS 'Legal status data information table';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.country_code IS 'The patent country code. Example: US';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.doc_number IS 'The patent doc number. Example: 20070009474';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.kind_code IS 'The patent kind code. Example: A1';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.sequence_id IS 'Sequence id for the legal event. Example: 1';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.publication_date IS 'Date of publication for the legal event. Example: {}';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.event_code IS 'The CODEN code that uniquely identifies the source. Example: AHJOA';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.legal_description IS 'Example: http://dl.acm.org/citation.cfm?id=111048';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.docdb_publication_number IS 'Example: Oxford University Press';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.docdb_application_id IS 'Example: acmhelp@acm.org';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.new_owner IS 'Example: acmhelp@acm.org';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.free_text_description IS 'Example: acmhelp@acm.org';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.last_updated_time IS 'Example: acmhelp@acm.org';
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
  CONSTRAINT lexis_nexis_patent_abstracts_pk PRIMARY KEY (country_code,doc_number,kind_code) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_patent_legal_data IS 'Legal status data information table';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.country_code IS 'The patent country code. Example: US';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.doc_number IS 'The patent doc number. Example: 20070009474';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.kind_code IS 'The patent kind code. Example: A1';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.sequence_id IS 'Sequence id for the legal event. Example: 1';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.publication_date IS 'Date of publication for the legal event. Example: {}';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.event_code IS 'The CODEN code that uniquely identifies the source. Example: AHJOA';
-- endregion
