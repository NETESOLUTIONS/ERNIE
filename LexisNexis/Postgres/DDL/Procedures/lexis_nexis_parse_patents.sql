/*
  Author: VJ Davey
  This script is part of a set that defines several procedures for XMLTABLE based parsing of LexisNexis XML patent files.
  This section covers base patent data and patent title data.
*/

\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
SET search_path TO public;

--Parse base patent data
CREATE OR REPLACE PROCEDURE lexis_nexis_parse_patents(input_xml XML) AS
$$
  BEGIN
    INSERT INTO lexis_nexis_patents(country_code,doc_number,kind_code,language_of_filing,language_of_publication,
                      date_of_public_availability_unexamined_printed_wo_grant,date_of_public_availability_printed_w_grant,
                      main_ipc_classification_text,main_ipc_classification_edition,main_ipc_classification_section,
                      main_ipc_classification_class,main_ipc_classification_subclass,main_ipc_classification_main_group,
                      main_ipc_classification_subgroup,main_ipc_classification_qualifying_character,main_national_classification_country,
                      main_national_classification_text,main_national_classification_class,main_national_classification_subclass,
                      number_of_claims)
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
          xmltable.number_of_claims
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
                date_of_public_availability_unexamined_printed_wo_grant DATE PATH 'dates-of-public-availability/unexamined-printed-without-grant/date',
                date_of_public_availability_printed_w_grant DATE PATH 'dates-of-public-availability/printed-with-grant/date',
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
                number_of_claims INT PATH 'number-of-claims'
                )
    ON CONFLICT (country_code,doc_number,kind_code)
    DO UPDATE SET country_code=excluded.country_code,doc_number=excluded.doc_number,kind_code=excluded.kind_code,language_of_filing=excluded.language_of_filing,
    language_of_publication=excluded.language_of_publication,date_of_public_availability_unexamined_printed_wo_grant=excluded.date_of_public_availability_unexamined_printed_wo_grant,
    date_of_public_availability_printed_w_grant=excluded.date_of_public_availability_printed_w_grant,main_ipc_classification_text=excluded.main_ipc_classification_text,
    main_ipc_classification_edition=excluded.main_ipc_classification_edition,main_ipc_classification_section=excluded.main_ipc_classification_section,
    main_ipc_classification_class=excluded.main_ipc_classification_class,main_ipc_classification_subclass=excluded.main_ipc_classification_subclass,
    main_ipc_classification_main_group=excluded.main_ipc_classification_main_group,main_ipc_classification_subgroup=excluded.main_ipc_classification_subgroup,
    main_ipc_classification_qualifying_character=excluded.main_ipc_classification_qualifying_character,main_national_classification_country=excluded.main_national_classification_country,
    main_national_classification_text=excluded.main_national_classification_text,main_national_classification_class=excluded.main_national_classification_class,
    main_national_classification_subclass=excluded.main_national_classification_subclass,number_of_claims=excluded.number_of_claims,last_updated_time=now();
  END;
$$
LANGUAGE plpgsql;