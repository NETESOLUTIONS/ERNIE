
/*
  Author: Djamil Lakhdar-Hamina
  Script defines several procedures for XMLTABLE based parsing of LexisNexis XML patent files.
  This section includes bibliographic, legal, and abstract data.
*/


\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

--1. Bibliographic-data: (change the arguments for procedure, there are many fields in the sample data that I have which were not included in the lexis-nexis patent-data).

CREATE OR REPLACE PROCEDURE lexis_nexis_bibliography_parser(input_xml XML)
AS $$
BEGIN
    INSERT INTO lexis_nexis_patents(country_code,doc_number,kind_code,language_of_filing,language_of_publication,
                      date_of_public_availability_unexamined_printed_wo_grant,date_of_public_availability_printed_w_grant,
                      main_ipc_classification_text,main_ipc_classification_edition,main_ipc_classification_section,
                      main_ipc_classification_class,main_ipc_classification_subclass,main_ipc_classification_main_group,
                      main_ipc_classification_subgroup,main_ipc_classification_qualifying_character, main_ipcr_classification_text,
                      main_ipcr_classification_section, main_ipcr_classification_class, main_ipcr_classification_subclass,
                      main_ipcr_classification_main_group, main_ipcr_classification_subgroup, main_ipcr_classification_status,
                      main_cpc_classification_text, main_cpc_classification_section, main_cpc_classification_class ,
                      main_cpc_classification_subclass, main_cpc_classification_main_group, main_cpc_classification_subgroup,
                      main_cpc_classification_status, main_ecla_classification_text, main_ecla_classification_section, main_ecla_classification_class,
                      main_ecla_classification_subclass, main_ecla_classification_main_group,main_ecla_classification_subgroup, number_of_claims )
SELECT xmltable.doc_number,
       xmltable.country_code,
       xmltable.kind_code,
       xmltable.bibliographic_language,
       xmltable.language_of_filing,
       xmltable.language_of_publication,
       TO_DATE(xmltable.date_of_public_availability_unexamined_printed_wo_grant, 'YYYYMMDD'),
       TO_DATE(xmltable.date_of_public_availability_w_grant, 'YYYYMMDD'),
       xmltable.main_ipc_classification_text,
       xmltable.main_ipc_classification_edition,
       xmltable.main_ipc_classification_section,
       xmltable.main_ipc_classification_class,
       xmltable.main_ipc_classification_subclass,
       xmltable.main_ipc_classification_main_group,
       xmltable.main_ipc_classification_subgroup,
       xmltable.main_ipc_classification_qualifying_character,
       xmltable.main_ipc_classification_qualifying_character,
       xmltable.main_ipcr_classification_text,
       xmltable.main_ipcr_classification_section,
       xmltable.main_ipcr_classification_class,
       xmltable.main_ipcr_classification_subclass,
       xmltable.main_ipcr_classification_main_group,
       xmltable.main_ipcr_classification_subgroup,
       xmltable.main_ipcr_classification_status,
       xmltable.main_cpc_classification_text,
       xmltable.main_cpc_classification_section,
       xmltable.main_cpc_classification_class,
       xmltable.main_cpc_classification_subclass,
       xmltable.main_cpc_classification_main_group,
       xmltable.main_cpc_classification_subgroup,
       xmltable.main_cpc_classification_status,
       xmltable.main_ecla_classification_text,
       xmltable.main_ecla_classification_class,
       xmltable.main_ecla_classification_subclass,
       xmltable.main_ecla_classification_main_group,
       xmltable.main_ecla_classification_subgroup,
       xmltable.number_of_claims
FROM  xmltable('//bibliographic-data' PASSING input_xml COLUMNS
         doc_number TEXT PATH '/document-id/@id' NOT NULL ,
         country_code TEXT PATH '//bibliographic-data/publication-reference/document-id/country' NOT NULL,
         kind_code TEXT PATH '//bibliographic-data/publication-reference/document-id/kind',
         bibliographic_language TEXT PATH '@lang',
         publication_country TEXT PATH '//publication-reference/document-id/country',
         application_id BIGINT PATH '//application-reference/document-id/@id',
         application_country TEXT PATH '//application-reference/document-id/country',
         application_date TEXT PATH '//application-reference/document-id/date',
         language_of_filing TEXT PATH 'language-of-filing',
         language_of_publication TEXT PATH 'language-of-publication',
         date_of_public_availability_unexamined_printed_wo_grant TEXT PATH '/dates-of-public-availability/unexamined-printed-without-grant/date',
         date_of_public_availability_w_grant TEXT PATH '/dates-of-public-availability/printed-without-grant/date',
         main_ipc_classification_text TEXT PATH '/classification-ipc/main-classification/text',
         main_ipc_classification_edition TEXT PATH '/classification-ipc/main-classification/edition',
         main_ipc_classification_section TEXT PATH '/classification-ipc/main-classification/section',
         main_ipc_classification_class TEXT PATH '/classification-ipc/main-classification/class',
         main_ipc_classification_subclass TEXT PATH '/classification-ipc/main-classification/subclass',
         main_ipc_classification_main_group TEXT PATH '/classification-ipc/main-classification/main-group',
         main_ipc_classification_subgroup TEXT PATH '/classification-ipc/main-classification/sub-group',
         main_ipc_classification_qualifying_character TEXT PATH '/classification-ipc/main-classification/qualifying-character',
         main_ipcr_classification_text TEXT PATH '/classifications-ipcr/classification-ipcr/text',
         main_ipcr_classification_section TEXT PATH '/classifications-ipcr/classification-ipcr/section' ,
         main_ipcr_classification_class TEXT PATH '/classifications-ipcr/classification-ipcr/class' ,
         main_ipcr_classification_subclass TEXT PATH '/classifications-ipcr/classification-ipcr/subclass',
         main_ipcr_classification_main_group TEXT PATH '/classifications-ipcr/classification-ipcr/main-group',
         main_ipcr_classification_subgroup TEXT PATH '/classifications-ipcr/classification-ipcr/subgroup',
         main_ipcr_classification_status TEXT PATH '/classifications-ipcr/classification-ipcr/classification-status',
         main_cpc_classification_text TEXT PATH '/classifications-cpc/classification-cpc/text',
         main_cpc_classification_section TEXT PATH '/classifications-cpc/classification-cpc/section',
         main_cpc_classification_class TEXT PATH '/classifications-cpc/classification-cpc/class',
         main_cpc_classification_subclass TEXT PATH '/classifications-cpc/classification-cpc/subclass',
         main_cpc_classification_main_group TEXT PATH '/classifications-cpc/classification-cpc/main-group',
         main_cpc_classification_subgroup TEXT PATH '/classifications-cpc/classification-cpc/subgroup',
         main_cpc_classification_status TEXT PATH '/classifications-cpc/classification-cpc/classification-status',
         main_ecla_classification_text TEXT PATH '/classification-ecla/classification-ecla/text',
         main_ecla_classification_section TEXT PATH '/classification-ecla/classification-ecla/classification-section',
         main_ecla_classification_class TEXT PATH '/classification-ecla/classification-ecla/class',
         main_ecla_classification_subclass TEXT PATH '/classification-ecla/classification-ecla/subclass',
         main_ecla_classification_main_group TEXT PATH '/classification-ecla/classification-ecla/main-group',
         main_ecla_classification_subgroup TEXT PATH '/classification-ecla/classification-ecla/subgroup',
         number_of_claims TEXT PATH 'number-of-claims'
         )
    ON CONFLICT DO NOTHING;
END;
$$
LANGUAGE plpgsql;


--2. Abstract-data:

CREATE OR REPLACE PROCEDURE lexis_nexis_abstract_parser(input_xml XML)
AS $$
BEGIN
    INSERT INTO lexis_nexis_patent_abstracts(country_code, doc_number, abstract_language,
                                             abstract_date_changed, abstract_text)
SELECT
       xmltable.doc_number,
       xmltable.country_code,
       xmltable.kind_code,
       xmltable.abstract_id,
       TO_DATE(xmltable.abstract_date_changed::TEXT, 'YYYYMMDD' ),
       xmltable.abstract_language,
       xmltable.abstract_text
FROM patent_legal_data, xmltable (
    '//abstract' PASSING patent_data COLUMNS
            doc_number TEXT PATH '//bibliographic-data/publication-reference/document-id/doc-number' NOT NULL,
            country_code TEXT PATH '//bibliographic-data/publication-reference/document-id/country' NOT NULL,
            kind_code TEXT PATH '//bibliographic-data/publication-reference/document-id/kind' NOT NULL,
            abstract_id  TEXT PATH '@id',
            abstract_date_changed TEXT PATH '@date-changed',
            abstract_language  TEXT PATH '@lang',
            abstract_text TEXT PATH 'p'
      )
ON CONFLICT DO NOTHING;
END;
$$
LANGUAGE plpgsql;




--3. Legal-data:
CREATE OR REPLACE PROCEDURE lexis_nexis_parser_legal_data(input_xml XML)
AS $$
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
            xmltable.doc_number,
            xmltable.country_code,
            xmltable.kind_code,
            xmltable.sequence_id,
            TO_DATE(xmltable.publication_date, 'YYYYMMDD'),
            xmltable.event_code_1,
            xmltable.event_code_2,
            xmltable.effect,
            xmltable.legal_description,
            xmltable.status_identifier,
            xmltable.docdb_publication_number,
            xmltable.docdb_application_id,
            xmltable.designated_state_authority,
            xmltable.designated_state_code,
            xmltable.designated_state_event_code,
            xmltable.designated_state_description,
            xmltable.corresponding_publication_number,
            xmltable.corresponding_publication_id,
            xmltable.corresponding_authority,
            xmltable.corresponding_kind,
            xmltable.legal_designated_states,
            xmltable.extension_state_authority,
            xmltable.new_owner,
            xmltable.free_text_description,
            xmltable.spc_number,
            xmltable.filing_date,
            xmltable.expiry_date,
            xmltable.inventor_names,
            xmltable.ipc,
            xmltable.payment_date,
            xmltable.fee_payment_year,
            xmltable.requester_name,
            xmltable.countries_concerned,
            TO_DATE(xmltable.effective_date,'YYYYMMDD'),
            TO_DATE(xmltable.withdrawn_date,'YYYYMMDD')
           FROM
             xmltable('//legal-data/legal-event' PASSING input_xml COLUMNS

                doc_number TEXT PATH '//bibliographic-data/publication-reference/document-id/country' NOT NULL,
                country_code TEXT PATH '//bibliographic-data/publication-reference/document-id/doc-number' NOT NULL,
                kind_code TEXT PATH '//bibliographic-data/publication-reference/document-id/kind' NOT NULL,
                sequence_id INT PATH '@sequence',
                publication_date INT PATH 'publication-date/date ' NOT NULL,
                event_code_1 TEXT PATH 'event-code-1',
                event_code_2 TEXT PATH 'event-code-2' ,
                effect TEXT PATH 'effect',
                legal_description TEXT PATH 'legal-description',
                status_identifier TEXT PATH 'status-identifier',
                docdb_publication_number INT PATH 'docdb-publication-number',
                docdb_application_id INT PATH 'doccb-application-id',
                designated_state_authority TEXT PATH 'designated_state_authority',
                designated_state_code INT PATH 'designated-state-code',
                designated_state_event_code TEXT PATH 'designated-state-event-code',
                designated_state_description TEXT PATH 'designated-state-description',
                corresponding_publication_number INT PATH 'corresponding-publication-number',
                corresponding_publication_id INT PATH 'corresponding-publication-id',
                corresponding_authority TEXT PATH 'corresponding-authority',
                corresponding_kind TEXT PATH 'corresponding-kind',
                legal_designated_states TEXT PATH 'legal-designated-states',
                extension_state_authority TEXT PATH 'extension-state-authority',
                new_owner TEXT PATH 'new-owner',
                free_text_description TEXT PATH 'free-text-description',
                spc_number INT PATH 'spc-number',
                filing_date INT PATH 'filing-date',
                expiry_date INT PATH 'expiry-date',
                inventor_names TEXT PATH 'inventor',
                ipc TEXT PATH 'ipc',
                payment_date INT PATH 'payment-date',
                fee_payment_year INT PATH 'opponent-name',
                requester_name TEXT PATH 'requester-name',
                 countries_concerned TEXT PATH 'countries-concerned',
                effective_date INT PATH 'effective-date',
                withdrawn_date INT PATH 'withdrawn-date'
              )
ON CONFLICT DO NOTHING;
END;
$$
LANGUAGE plpgsql;

DROP PROCEDURE lexis_nexis_bibliography_parser(input_xml XML)
