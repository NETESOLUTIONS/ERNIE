\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
SET search_path TO shreya;

--Parse us agents
CREATE OR REPLACE PROCEDURE lexis_nexis_parse_patents_family_link(input_xml XML) AS
$$
  BEGIN
    INSERT INTO lexis_nexis_parse_patents_family_link(family_id, country_code, doc_number, kind_code)
    SELECT
          xmltable.family_id,
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code

     FROM
     xmltable('//bibliographic-data/patent-family' PASSING input_xml
              COLUMNS
                family_id INT PATH '//@family-id' NOT NULL,
                country_code TEXT PATH '../publication-reference/document-id/country' NOT NULL,
                doc_number TEXT PATH '../publication-reference/document-id/doc-number' NOT NULL,
                kind_code TEXT PATH '../publication-reference/document-id/kind' NOT NULL

                )
    ON CONFLICT (country_code, doc_number, kind_code)
    DO UPDATE SET family_id=excluded."family_id";
  END;
$$
LANGUAGE plpgsql;
