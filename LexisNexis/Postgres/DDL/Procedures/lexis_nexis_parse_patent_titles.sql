/*
  Author: VJ Davey
  This script is part of a set that defines several procedures for XMLTABLE based parsing of LexisNexis XML patent files.
  This section covers base patent data and patent title data.
*/

\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';


-- Parse base patent title data
CREATE OR REPLACE PROCEDURE lexis_nexis_parse_patent_titles(input_xml XML) AS
$$
  BEGIN
    INSERT INTO lexis_nexis_patent_titles(country_code,doc_number,kind_code,invention_title,language)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.invention_title,
          xmltable.title_language
     FROM
     XMLTABLE('//bibliographic-data/invention-title' PASSING input_xml
              COLUMNS
                --below are attributes
                language TEXT PATH '@lang',

                --Below are sub elements
                country_code TEXT PATH '//bibliographic-data/publication-reference/document-id/country' NOT NULL,
                doc_number TEXT PATH '//bibliographic-data/publication-reference/document-id/doc-number' NOT NULL,
                kind_code TEXT PATH '//bibliographic-data/publication-reference/document-id/kind' NOT NULL,
                invention_title TEXT PATH 'normalize-space(.)' NOT NULL,
                title_language TEXT PATH '@lang' NOT NULL
                )
    ON CONFLICT (country_code,doc_number,kind_code,language)
    DO UPDATE SET invention_title=excluded.invention_title, last_updated_time=now();
  END;
$$
LANGUAGE plpgsql;
