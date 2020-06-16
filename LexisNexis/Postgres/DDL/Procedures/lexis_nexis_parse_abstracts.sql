/*
  Author: VJ Davey
  This script is part of a set that defines several procedures for XMLTABLE based parsing of LexisNexis XML patent files.
  This section covers abstracts data.
*/

\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';


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
     XMLTABLE('//abstract' PASSING input_xml
              COLUMNS
                --below come from higher level nodes
                country_code TEXT PATH '//bibliographic-data/publication-reference/document-id/country' NOT NULL,
                doc_number TEXT PATH '//bibliographic-data/publication-reference/document-id/doc-number' NOT NULL,
                kind_code TEXT PATH '//bibliographic-data/publication-reference/document-id/kind' NOT NULL,

                --below are attributes
                abstract_language TEXT PATH '@lang',
                abstract_date_changed DATE PATH '@date-changed',
                --Below are sub elements
                abstract_text TEXT PATH 'normalize-space(.)' NOT NULL
              )
    ON CONFLICT (country_code,doc_number,kind_code,abstract_language)
    DO UPDATE SET abstract_text=excluded.abstract_text,abstract_date_changed=excluded.abstract_date_changed,
     last_updated_time=now();
  END;
$$
LANGUAGE plpgsql;
