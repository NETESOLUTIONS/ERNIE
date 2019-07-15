-- author: Sitaram Devarakonda 06/12/2019
-- parses patent citation data

\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
SET search_path TO public;

CREATE OR REPLACE PROCEDURE lexis_nexis_patent_citations_data(input_xml XML) AS
$$
BEGIN
    INSERT INTO lexis_nexis_patent_citations(country_code,doc_number,kind_code,seq_num, cited_doc_number, cited_country, cited_kind,
                                             cited_authors, cited_create_date, cited_published_date)
    SELECT DISTINCT xmltable.country_code,
           xmltable.doc_number,
           xmltable.kind_code,
           xmltable.seq_num,
           xmltable.cited_doc_number,
           xmltable.cited_country,
           xmltable.cited_kind,
           xmltable.cited_authors,
           to_date(xmltable.cited_create_date,'YYYYMMDD'),
           to_date(xmltable.cited_published_date,'YYYYMMDD')
    FROM xmltable('//bibliographic-data/references-cited/citation/patcit/document-id/doc-number' PASSING input_xml
                  COLUMNS
                      country_code TEXT PATH '../../../../../publication-reference/document-id/country',
                      doc_number TEXT PATH '../../../../../publication-reference/document-id/doc-number',
                      kind_code TEXT PATH '../../../../../publication-reference/document-id/kind',
                      seq_num INTEGER PATH '../../@num',
                      cited_doc_number TEXT PATH '.',
                      cited_country TEXT PATH '../country',
                      cited_kind TEXT PATH '../kind',
                      cited_authors TEXT PATH '../name',
                      cited_create_date TEXT PATH '../../application-date/date',
                      cited_published_date TEXT PATH '../date')
    ON CONFLICT (country_code, doc_number, kind_code, seq_num)
    DO UPDATE SET cited_country=excluded.cited_country, cited_doc_number=excluded.cited_doc_number, cited_kind=excluded.cited_kind,
    cited_authors=excluded.cited_authors, cited_create_date=excluded.cited_create_date, cited_published_date=excluded.cited_published_date,
    last_updated_time=now();
END;
$$ LANGUAGE plpgsql;
