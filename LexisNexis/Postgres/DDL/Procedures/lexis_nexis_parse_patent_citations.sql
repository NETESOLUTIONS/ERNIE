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
    INSERT INTO lexis_nexis_patent_citations(doc_number, seq_num, cited_doc_number, cited_country, cited_kind,
                                             cited_authors, cited_create_date, cited_published_date)
    SELECT xmltable.doc_number,
           xmltable.seq_num,
           xmltable.cited_doc_number,
           xmltable.cited_country,
           xmltable.cited_kind,
           xmltable.cited_authors,
           xmltable.cited_create_date,
           xmltable.cited_published_date
    FROM xmltable('//bibliographic-data/references-cited/citation/patcit/document-id/doc-number' PASSING input_xml
                  COLUMNS
                      doc_number bigint PATH '../../../../../publication-reference/document-id/doc-number',
                      seq_num integer PATH '../../@num',
                      cited_doc_number bigint PATH '.',
                      cited_country TEXT PATH '../country',
                      cited_kind TEXT PATH '../kind',
                      cited_authors TEXT PATH '../name',
                      cited_create_date DATE PATH '../../application-date/date',
                      cited_published_date DATE PATH '../date')
    ON CONFLICT DO NOTHING;
END;
$$ LANGUAGE plpgsql;
