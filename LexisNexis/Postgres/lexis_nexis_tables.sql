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

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_patents IS 'Main table for Lexis Nexis patents';
COMMENT ON COLUMN lexis_nexis_patents.country_code IS '';
COMMENT ON COLUMN lexis_nexis_patents.doc_number IS '';
COMMENT ON COLUMN lexis_nexis_patents.kind_code IS '';
COMMENT ON COLUMN lexis_nexis_patents.language_of_filing IS '';
COMMENT ON COLUMN lexis_nexis_patents.language_of_publication IS '';
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
COMMENT ON COLUMN lexis_nexis_patents.number_of_claims IS '';
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

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_patents IS 'Main table for Lexis Nexis patents';
COMMENT ON COLUMN lexis_nexis_patents_titles.country_code IS '';
COMMENT ON COLUMN lexis_nexis_patents_titles.doc_number IS '';
COMMENT ON COLUMN lexis_nexis_patent_titles.kind_code IS '';
COMMENT ON COLUMN lexis_nexis_patent_titles.invention_title IS '';
COMMENT ON COLUMN lexis_nexis_patent_titles.language IS '';
COMMENT ON COLUMN lexis_nexis_patent_titles.last_updated_time IS '';
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
  corresponding_publication_date DATE,
  corresponding_kind TEXT,
  legal_designated_states TEXT,
  extension_state_authority TEXT,
  new_owner TEXT,
  free_text_description TEXT,
  spc_number TEXT,
  filing_date DATE,
  expiry_date DATE,
  inventor_name TEXT,
  ipc TEXT,
  representative_name TEXT,
  payment_date DATE,
  opponent_name TEXT,
  fee_payment_year TEXT,
  requester_name TEXT,
  countries_concerned TEXT,
  effective_date DATE,
  withdrawn_date DATE,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT lexis_nexis_patent_legal_data_pk PRIMARY KEY (country_code,doc_number,kind_code,sequence_id) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_patent_legal_data IS 'Legal status data information table';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.country_code IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.doc_number IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.kind_code IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.sequence_id IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.publication_date IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.event_code_1 IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.event_code_2 IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.effect IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.legal_description IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.status_identifier IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.docdb_publication_number IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.docdb_application_id IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.designated_state_authority IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.designated_state_event_code IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.designated_state_description IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.corresponding_publication_number IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.corresponding_authority IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.corresponding_publication_date IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.corresponding_kind IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.legal_designated_states IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.extension_state_authority IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.new_owner IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.free_text_description IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.spc_number IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.filing_date IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.expiry_date IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.inventor_name IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.ipc IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.representative_name IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.payment_date IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.opponent_name IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.fee_payment_year IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.requester_name IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.countries_concerned IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.effective_date IS '';
COMMENT ON COLUMN lexis_nexis_patent_legal_data.withdrawn_date IS '';
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
  CONSTRAINT lexis_nexis_patent_abstracts_pk PRIMARY KEY (country_code,doc_number,kind_code) USING INDEX TABLESPACE index_tbs
)
TABLESPACE lexis_nexis_tbs;

--TODO: flesh out comments
COMMENT ON TABLE lexis_nexis_patent_abstracts IS 'Patent abstract information table';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.country_code IS '';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.doc_number IS '';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.kind_code IS '';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.abstract_language IS '';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.abstract_date_changed IS '';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.abstract_text IS '';
COMMENT ON COLUMN lexis_nexis_patent_abstracts.last_updated_time IS '';
-- endregion
