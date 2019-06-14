/*
 Author: Djamil Lakhdar-Hamina

 lexis-nexis priority_claim parser.

 */

\timing

 ---- region lexis_nexis_patent_priority_claims_parser

CREATE OR REPLACE PROCEDURE lexis_nexis_patent_priority_claims_parser (input_xml XML)
AS
$$
  BEGIN
      INSERT INTO lexis_nexis_patent_priority_claims(doc_number, country_code, kind_code,
                                                     publication_language, sequence, priority_claim_doc_number, date, last_updated_time)
    SELECT
      xmltable.doc_number,
      xmltable.country_code,
      xmltable.kind_code,
      xmltable.sequence,
      xmltable.publication_language,
      xmltable.priority_claim_doc_number,
      to_date(xmltable.date, 'YYYYMMDD')
    FROM xmltable('//priority-claim' PASSING priority_claim COLUMNS
 -- The highest-level of the xml tree-structure
    doc_number TEXT PATH '//publication-reference/document-id/doc-number',
    country_code TEXT PATH '//publication-reference/document-id/country',
    kind_code TEXT PATH '//publication-reference/document-id/kind',
    publication_language TEXT PATH '//publication-reference/document-id/kind',
    -- Access the attributes
    sequence TEXT PATH '@sequence',
    priority_doc_number TEXT PATH 'doc-number',
    priority_date TEXT PATH 'date')
    ON CONFLICT DO NOTHING;
end;
$$
LANGUAGE plpsql;
