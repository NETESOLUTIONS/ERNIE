/*
  Author: VJ Davey
  This script defines several procedures for XMLTABLE based parsing of LexisNexis XML patent files.
  This section includes bibliographic data, legal data, and abstracts
*/

\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

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
                publication_date TEXT PATH 'publication-date/date' NOT NULL,
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
    ON CONFLICT DO NOTHING;
  END;
$$
LANGUAGE plpgsql;

-- Abstract parsing
CREATE OR REPLACE PROCEDURE lexis_nexis_parse_abstracts(input_xml XML) AS
$$
  BEGIN
    INSERT INTO lexis_nexis_patent_abstracts(country_code,doc_number,kind_code,abstract_language,
                                            abstract_date_changed,abstract_text)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.abstract_language,
          xmltable.abstract_date_changed,
          xmltable.abstract_text
     FROM
     XMLTABLE('//bibliographic-data/publication-reference' PASSING input_xml
              COLUMNS
                --below come from higher level nodes
                country_code TEXT PATH '//bibliographic-data/publication-reference/document-id/country' NOT NULL,
                doc_number TEXT PATH '//bibliographic-data/publication-reference/document-id/doc-number' NOT NULL,
                kind_code TEXT PATH '//bibliographic-data/publication-reference/document-id/kind' NOT NULL,

                --below are attributes
                abstract_language TEXT PATH '//abstract/@lang',
                abstract_date_changed DATE PATH '//abstract/@date-changed',
                --Below are sub elements
                abstract_text TEXT PATH 'normalize-space(//abstract)' NOT NULL
              )
    ON CONFLICT DO NOTHING;
  END;
$$
LANGUAGE plpgsql;


--Bibliographic data parsing, splits into several sub tables
CREATE OR REPLACE PROCEDURE lexis_nexis_parse_bibliographic_data(input_xml XML) AS
$$
  BEGIN
    INSERT INTO lexis_nexis_patents(country_code,doc_number,kind_code,language_of_filing,language_of_publication,
                      date_of_public_availability_unexamined_printed_wo_grant,date_of_public_availability_printed_w_grant,
                      main_ipc_classification_text,main_ipc_classification_edition,main_ipc_classification_section,
                      main_ipc_classification_class,main_ipc_classification_subclass,main_ipc_classification_main_group,
                      main_ipc_classification_subgroup,main_ipc_classification_qualifying_character,main_national_classification_country,
                      main_national_classification_text,main_national_classification_class,main_national_classification_subclass,
                      number_of_claims,invention_title)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.language_of_filing,
          xmltable.language_of_publication,
          xmltable.date_of_public_availability_unexamined_printed_wo_grant,
          xmltable.date_of_public_availability_printed_w_grant,
          xmltable.main_ipc_classification_text,
          xmltable.main_ipc_classification_edition,
          xmltable.main_ipc_classification_section,
          xmltable.main_ipc_classification_class,
          xmltable.main_ipc_classification_subclass,
          xmltable.main_ipc_classification_main_group,
          xmltable.main_ipc_classification_subgroup,
          xmltable.main_ipc_classification_qualifying_character,
          xmltable.main_national_classification_country,
          xmltable.main_national_classification_text,
          xmltable.main_national_classification_class,
          xmltable.main_national_classification_subclass,
          xmltable.number_of_claims,
          xmltable.invention_title
     FROM
     XMLTABLE('//bibliographic-data' PASSING input_xml
              COLUMNS
                --below are attributes
                language TEXT PATH '@lang',

                --Below are sub elements
                country_code TEXT PATH 'publication-reference/document-id/country' NOT NULL,
                doc_number TEXT PATH 'publication-reference/document-id/doc-number' NOT NULL,
                kind_code TEXT PATH 'publication-reference/document-id/kind' NOT NULL,
                language_of_filing TEXT PATH 'language-of-filing',
                language_of_publication TEXT PATH 'language-of-publication',
                date_of_public_availability_unexamined_printed_wo_grant TEXT PATH 'dates-of-public-availability/unexamined-printed-without-grant/date',
                date_of_public_availability_printed_w_grant TEXT PATH 'dates-of-public-availability/printed-with-grant/date',
                main_ipc_classification_text TEXT PATH 'classification-ipc/main-classification/text',
                main_ipc_classification_edition TEXT PATH 'classification-ipc/main-classification/edition',
                main_ipc_classification_section TEXT PATH 'classification-ipc/main-classification/section',
                main_ipc_classification_class TEXT PATH 'classification-ipc/main-classification/class',
                main_ipc_classification_subclass TEXT PATH 'classification-ipc/main-classification/subclass',
                main_ipc_classification_main_group TEXT PATH 'classification-ipc/main-classification/main-group',
                main_ipc_classification_subgroup TEXT PATH 'classification-ipc/main-classification/subgroup',
                main_ipc_classification_qualifying_character TEXT PATH 'classification-ipc/main-classification/qualifying-character',
                main_national_classification_country TEXT PATH 'classification-national/country',
                main_national_classification_text TEXT PATH 'classification-national/main-classification/text',
                main_national_classification_class TEXT PATH 'classification-national/main-classification/class',
                main_national_classification_subclass TEXT PATH 'classification-national/main-classification/subclass',
                number_of_claims INT PATH 'number-of-claims',
                invention_title TEXT PATH 'invention-title'
                )
    ON CONFLICT DO NOTHING;

  END;
$$
LANGUAGE plpgsql;
