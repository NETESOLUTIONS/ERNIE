\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
SET search_path TO public;

--Parse us agents
CREATE PROCEDURE lexis_nexis_parse_patents_family_link(input_xml xml)
  LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO lexis_nexis_patents_family_link(family_id, country_code, doc_number, kind_code)
    SELECT
          xmltable.family_id,
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code

     FROM
     xmltable('//patent-family/*[substring(name(), string-length(name()) - 6) = "-family"]' PASSING input_xml
              COLUMNS
                family_id INT PATH '@family-id',
                country_code TEXT PATH '//bibliographic-data/publication-reference/document-id/country' NOT NULL,
                doc_number TEXT PATH '//bibliographic-data/publication-reference/document-id/doc-number' NOT NULL,
                kind_code TEXT PATH '//bibliographic-data/publication-reference/document-id/kind' NOT NULL

                )
    ON CONFLICT DO NOTHING ;
  END;
$$ LANGUAGE plpgsql;
