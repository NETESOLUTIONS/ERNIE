\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
SET search_path TO public;

--Parse non-patent literature citations
CREATE OR REPLACE PROCEDURE lexis_nexis_parse_nonpatent_citations(input_xml XML) AS
$$
  BEGIN
    INSERT INTO lexis_nexis_nonpatent_literature_citations(country_code,doc_number,kind_code,citation_number,citation_text,scopus_url)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.citation_number,
          xmltable.citation_text,
          xmltable.scopus_url
     FROM
     XMLTABLE('//bibliographic-data/references-cited/citation/nplcit' PASSING input_xml COLUMNS --
                country_code TEXT PATH '../../../publication-reference/document-id/country' NOT NULL,
                doc_number TEXT PATH '../../../publication-reference/document-id/doc-number' NOT NULL,
                kind_code TEXT PATH '../../../publication-reference/document-id/kind' NOT NULL,
                citation_number TEXT PATH '@num',
                citation_text TEXT PATH 'text',
                scopus_url TEXT PATH 'scopus-url'
                )
    ON CONFLICT (country_code, doc_number, kind_code, citation_number)
    DO UPDATE SET citation_text=excluded.citation_text,scopus_url=excluded.scopus_url,last_updated_time=now();
  END;
$$
LANGUAGE plpgsql;
