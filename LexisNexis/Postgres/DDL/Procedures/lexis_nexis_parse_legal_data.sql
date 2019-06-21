/*
  Author: VJ Davey
  This script is part of a set that defines several procedures for XMLTABLE based parsing of LexisNexis XML patent files.
  This section covers legal data.
*/

\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
SET search_path TO public;

-- Legal Data parsing
CREATE OR REPLACE PROCEDURE lexis_nexis_parse_legal_data(input_xml XML) AS
$$
  BEGIN
    INSERT INTO lexis_nexis_patent_legal_data (country_code,doc_number,kind_code,sequence_id,
                publication_date,event_code_1,event_code_2,effect,legal_description,status_identifier,
                docdb_publication_number,docdb_application_id,designated_state_authority,
                designated_state_event_code,designated_state_description,corresponding_publication_number,
                corresponding_authority,corresponding_publication_date,corresponding_kind,legal_designated_states,
                extension_state_authority,new_owner,free_text_description,spc_number,filing_date,expiry_date,
                inventor_name,ipc,representative_name,payment_date,opponent_name,fee_payment_year,requester_name,
                countries_concerned,effective_date,withdrawn_date)
    SELECT
        xmltable.country_code,
        xmltable.doc_number,
        xmltable.kind_code,
        xmltable.sequence_id,
        xmltable.publication_date,
        xmltable.event_code_1,
        xmltable.event_code_2,
        xmltable.effect,
        xmltable.legal_description,
        xmltable.status_identifier,
        xmltable.docdb_publication_number,
        xmltable.docdb_application_id,
        xmltable.designated_state_authority,
        xmltable.designated_state_event_code,
        xmltable.designated_state_description,
        xmltable.corresponding_publication_number,
        xmltable.corresponding_authority,
        xmltable.corresponding_publication_date,
        xmltable.corresponding_kind,
        xmltable.legal_designated_states,
        xmltable.extension_state_authority,
        xmltable.new_owner,
        xmltable.free_text_description,
        xmltable.spc_number,
        xmltable.filing_date,
        xmltable.expiry_date,
        xmltable.inventor_name,
        xmltable.ipc,
        xmltable.representative_name,
        xmltable.payment_date,
        xmltable.opponent_name,
        xmltable.fee_payment_year,
        xmltable.requester_name,
        xmltable.countries_concerned,
        xmltable.effective_date,
        xmltable.withdrawn_date
     FROM
     XMLTABLE('//legal-data/legal-event' PASSING input_xml
              COLUMNS

                --below come from higher level nodes
                country_code TEXT PATH '//bibliographic-data/publication-reference/document-id/country' NOT NULL,
                doc_number TEXT PATH '//bibliographic-data/publication-reference/document-id/doc-number' NOT NULL,
                kind_code TEXT PATH '//bibliographic-data/publication-reference/document-id/kind' NOT NULL,

                --below are attributes
                sequence_id INT PATH '@sequence',

                --below are sub elements, many with minOccurs=0 per the XML schema.
                publication_date DATE PATH 'publication-date/date' NOT NULL,
                event_code_1 TEXT PATH 'event-code-1' NOT NULL,
                event_code_2 TEXT PATH 'event-code-2',
                effect TEXT PATH 'effect',
                legal_description TEXT PATH 'legal-description',
                status_identifier TEXT PATH 'status-identifier' NOT NULL,
                docdb_publication_number TEXT PATH 'docdb-publication-number',
                docdb_application_id TEXT PATH 'docdb-application-id',
                designated_state_authority TEXT PATH 'designated-state-authority',
                designated_state_event_code TEXT PATH 'designated-state-event-code',
                designated_state_description TEXT PATH 'designated-state-description',
                corresponding_publication_number TEXT PATH 'corresponding-publication-number',
                corresponding_authority TEXT PATH 'corresponding-authority',
                corresponding_publication_date TEXT PATH 'corresponding-publication-date',
                corresponding_kind TEXT PATH 'corresponding-kind',
                legal_designated_states TEXT PATH 'legal-designated-states',
                extension_state_authority TEXT PATH 'extension-state-authority',
                new_owner TEXT PATH 'new-owner',
                free_text_description TEXT PATH 'free-text-description',
                spc_number TEXT PATH 'spc-number',
                filing_date TEXT PATH 'filing-date',
                expiry_date TEXT PATH 'expiry-date',
                inventor_name TEXT PATH 'inventor-name',
                ipc TEXT PATH 'ipc',
                representative_name TEXT PATH 'representative-name',
                payment_date TEXT PATH 'payment-date',
                opponent_name TEXT PATH 'opponent-name',
                fee_payment_year TEXT PATH 'fee-payment-year',
                requester_name TEXT PATH 'requester-name',
                countries_concerned TEXT PATH 'countries-concerned',
                effective_date TEXT PATH 'effective-date',
                withdrawn_date TEXT PATH 'withdrawn-date'
              )
    ON CONFLICT (country_code,doc_number,kind_code,sequence_id)
    DO UPDATE SET country_code=excluded.country_code,doc_number=excluded.doc_number,kind_code=excluded.kind_code,sequence_id=excluded.sequence_id,
    publication_date=excluded.publication_date,event_code_1=excluded.event_code_1,event_code_2=excluded.event_code_2,effect=excluded.effect,
    legal_description=excluded.legal_description,status_identifier=excluded.status_identifier,docdb_publication_number=excluded.docdb_publication_number,
    docdb_application_id=excluded.docdb_application_id,designated_state_authority=excluded.designated_state_authority,
    designated_state_event_code=excluded.designated_state_event_code,designated_state_description=excluded.designated_state_description,
    corresponding_publication_number=excluded.corresponding_publication_number,corresponding_authority=excluded.corresponding_authority,
    corresponding_publication_date=excluded.corresponding_publication_date,corresponding_kind=excluded.corresponding_kind,
    legal_designated_states=excluded.legal_designated_states,extension_state_authority=excluded.extension_state_authority,new_owner=excluded.new_owner,
    free_text_description=excluded.free_text_description,spc_number=excluded.spc_number,filing_date=excluded.filing_date,expiry_date=excluded.expiry_date,
    inventor_name=excluded.inventor_name,ipc=excluded.ipc,representative_name=excluded.representative_name,payment_date=excluded.payment_date,
    opponent_name=excluded.opponent_name,fee_payment_year=excluded.fee_payment_year,requester_name=excluded.requester_name,
    countries_concerned=excluded.countries_concerned,effective_date=excluded.effective_date,withdrawn_date=excluded.withdrawn_date,last_updated_time=now();
  END;
$$
LANGUAGE plpgsql;
