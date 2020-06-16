\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';


--Parse examiners
CREATE OR REPLACE PROCEDURE lexis_nexis_parse_related_documents(input_xml XML) AS
$$
  BEGIN
    -- lexis_nexis_patent_related_document_additions
    INSERT INTO lexis_nexis_patent_related_document_additions(country_code,doc_number,kind_code,parent_doc_country,parent_doc_number,parent_doc_kind,
                                                              parent_doc_name,parent_doc_date,parent_status,parent_grant_document_country,parent_grant_document_number,
                                                              parent_grant_document_kind,parent_grant_document_name,parent_grant_document_date,
                                                              parent_pct_document_country,parent_pct_document_number,parent_pct_document_kind,parent_pct_document_name,
                                                              parent_pct_document_date,child_doc_country,child_doc_number,child_doc_kind,child_doc_name,child_doc_date)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.parent_doc_country,
          xmltable.parent_doc_number,
          xmltable.parent_doc_kind,
          xmltable.parent_doc_name,
          xmltable.parent_doc_date,
          xmltable.parent_status,
          xmltable.parent_grant_document_country,
          xmltable.parent_grant_document_number,
          xmltable.parent_grant_document_kind,
          xmltable.parent_grant_document_name,
          xmltable.parent_grant_document_date,
          xmltable.parent_pct_document_country,
          xmltable.parent_pct_document_number,
          xmltable.parent_pct_document_kind,
          xmltable.parent_pct_document_name,
          xmltable.parent_pct_document_date,
          xmltable.child_doc_country,
          xmltable.child_doc_number,
          xmltable.child_doc_kind,
          xmltable.child_doc_name,
          xmltable.child_doc_date
     FROM
     XMLTABLE('//bibliographic-data/related-documents/addition' PASSING input_xml COLUMNS --
                country_code TEXT PATH '../../publication-reference/document-id[not(@*)]/country' NOT NULL,
                doc_number TEXT PATH '../../publication-reference/document-id[not(@*)]/doc-number' NOT NULL,
                kind_code TEXT PATH '../../publication-reference/document-id[not(@*)]/kind' NOT NULL,
                parent_doc_country TEXT PATH 'relation/parent-doc/document-id[not(@*)]/country',
                parent_doc_number TEXT PATH 'relation/parent-doc/document-id[not(@*)]/doc-number',
                parent_doc_kind TEXT PATH 'relation/parent-doc/document-id[not(@*)]/kind',
                parent_doc_name TEXT PATH 'relation/parent-doc/document-id[not(@*)]/name',
                parent_doc_date TEXT PATH 'relation/parent-doc/document-id[not(@*)]/date',
                parent_status TEXT PATH 'relation/parent-doc/parent-status',
                parent_grant_document_country TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/country',
                parent_grant_document_number TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/doc-number',
                parent_grant_document_kind TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/kind',
                parent_grant_document_name TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/name',
                parent_grant_document_date TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/date',
                parent_pct_document_country TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/country',
                parent_pct_document_number TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/doc-number',
                parent_pct_document_kind TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/kind',
                parent_pct_document_name TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/name',
                parent_pct_document_date TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/date',
                child_doc_country TEXT PATH 'relation/child-doc/document-id[not(@*)]/country',
                child_doc_number TEXT PATH 'relation/child-doc/document-id[not(@*)]/doc-number',
                child_doc_kind TEXT PATH 'relation/child-doc/document-id[not(@*)]/kind',
                child_doc_name TEXT PATH 'relation/child-doc/document-id[not(@*)]/name',
                child_doc_date TEXT PATH 'relation/child-doc/document-id[not(@*)]/date'                
                )
    ON CONFLICT DO NOTHING;

    -- related_document_divisions
    INSERT INTO lexis_nexis_patent_related_document_divisions(country_code,doc_number,kind_code,parent_doc_country,parent_doc_number,parent_doc_kind,
                                                              parent_doc_name,parent_doc_date,parent_status,parent_grant_document_country,parent_grant_document_number,
                                                              parent_grant_document_kind,parent_grant_document_name,parent_grant_document_date,
                                                              parent_pct_document_country,parent_pct_document_number,parent_pct_document_kind,parent_pct_document_name,
                                                              parent_pct_document_date,child_doc_country,child_doc_number,child_doc_kind,child_doc_name,child_doc_date)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.parent_doc_country,
          xmltable.parent_doc_number,
          xmltable.parent_doc_kind,
          xmltable.parent_doc_name,
          xmltable.parent_doc_date,
          xmltable.parent_status,
          xmltable.parent_grant_document_country,
          xmltable.parent_grant_document_number,
          xmltable.parent_grant_document_kind,
          xmltable.parent_grant_document_name,
          xmltable.parent_grant_document_date,
          xmltable.parent_pct_document_country,
          xmltable.parent_pct_document_number,
          xmltable.parent_pct_document_kind,
          xmltable.parent_pct_document_name,
          xmltable.parent_pct_document_date,
          xmltable.child_doc_country,
          xmltable.child_doc_number,
          xmltable.child_doc_kind,
          xmltable.child_doc_name,
          xmltable.child_doc_date
     FROM
     XMLTABLE('//bibliographic-data/related-documents/division' PASSING input_xml COLUMNS --
                country_code TEXT PATH '../../publication-reference/document-id[not(@*)]/country' NOT NULL,
                doc_number TEXT PATH '../../publication-reference/document-id[not(@*)]/doc-number' NOT NULL,
                kind_code TEXT PATH '../../publication-reference/document-id[not(@*)]/kind' NOT NULL,
                parent_doc_country TEXT PATH 'relation/parent-doc/document-id[not(@*)]/country',
                parent_doc_number TEXT PATH 'relation/parent-doc/document-id[not(@*)]/doc-number',
                parent_doc_kind TEXT PATH 'relation/parent-doc/document-id[not(@*)]/kind',
                parent_doc_name TEXT PATH 'relation/parent-doc/document-id[not(@*)]/name',
                parent_doc_date TEXT PATH 'relation/parent-doc/document-id[not(@*)]/date',
                parent_status TEXT PATH 'relation/parent-doc/parent-status',
                parent_grant_document_country TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/country',
                parent_grant_document_number TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/doc-number',
                parent_grant_document_kind TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/kind',
                parent_grant_document_name TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/name',
                parent_grant_document_date TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/date',
                parent_pct_document_country TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/country',
                parent_pct_document_number TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/doc-number',
                parent_pct_document_kind TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/kind',
                parent_pct_document_name TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/name',
                parent_pct_document_date TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/date',
                child_doc_country TEXT PATH 'relation/child-doc/document-id[not(@*)]/country',
                child_doc_number TEXT PATH 'relation/child-doc/document-id[not(@*)]/doc-number',
                child_doc_kind TEXT PATH 'relation/child-doc/document-id[not(@*)]/kind',
                child_doc_name TEXT PATH 'relation/child-doc/document-id[not(@*)]/name',
                child_doc_date TEXT PATH 'relation/child-doc/document-id[not(@*)]/date'                
                )
    ON CONFLICT DO NOTHING;

    -- lexis_nexis_patent_related_document_continuations
    INSERT INTO lexis_nexis_patent_related_document_continuations(country_code,doc_number,kind_code,parent_doc_country,parent_doc_number,parent_doc_kind,
                                                              parent_doc_name,parent_doc_date,parent_status,parent_grant_document_country,parent_grant_document_number,
                                                              parent_grant_document_kind,parent_grant_document_name,parent_grant_document_date,
                                                              parent_pct_document_country,parent_pct_document_number,parent_pct_document_kind,parent_pct_document_name,
                                                              parent_pct_document_date,child_doc_country,child_doc_number,child_doc_kind,child_doc_name,child_doc_date)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.parent_doc_country,
          xmltable.parent_doc_number,
          xmltable.parent_doc_kind,
          xmltable.parent_doc_name,
          xmltable.parent_doc_date,
          xmltable.parent_status,
          xmltable.parent_grant_document_country,
          xmltable.parent_grant_document_number,
          xmltable.parent_grant_document_kind,
          xmltable.parent_grant_document_name,
          xmltable.parent_grant_document_date,
          xmltable.parent_pct_document_country,
          xmltable.parent_pct_document_number,
          xmltable.parent_pct_document_kind,
          xmltable.parent_pct_document_name,
          xmltable.parent_pct_document_date,
          xmltable.child_doc_country,
          xmltable.child_doc_number,
          xmltable.child_doc_kind,
          xmltable.child_doc_name,
          xmltable.child_doc_date
     FROM
     XMLTABLE('//bibliographic-data/related-documents/continuation' PASSING input_xml COLUMNS --
                country_code TEXT PATH '../../publication-reference/document-id[not(@*)]/country' NOT NULL,
                doc_number TEXT PATH '../../publication-reference/document-id[not(@*)]/doc-number' NOT NULL,
                kind_code TEXT PATH '../../publication-reference/document-id[not(@*)]/kind' NOT NULL,
                parent_doc_country TEXT PATH 'relation/parent-doc/document-id[not(@*)]/country',
                parent_doc_number TEXT PATH 'relation/parent-doc/document-id[not(@*)]/doc-number',
                parent_doc_kind TEXT PATH 'relation/parent-doc/document-id[not(@*)]/kind',
                parent_doc_name TEXT PATH 'relation/parent-doc/document-id[not(@*)]/name',
                parent_doc_date TEXT PATH 'relation/parent-doc/document-id[not(@*)]/date',
                parent_status TEXT PATH 'relation/parent-doc/parent-status',
                parent_grant_document_country TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/country',
                parent_grant_document_number TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/doc-number',
                parent_grant_document_kind TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/kind',
                parent_grant_document_name TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/name',
                parent_grant_document_date TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/date',
                parent_pct_document_country TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/country',
                parent_pct_document_number TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/doc-number',
                parent_pct_document_kind TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/kind',
                parent_pct_document_name TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/name',
                parent_pct_document_date TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/date',
                child_doc_country TEXT PATH 'relation/child-doc/document-id[not(@*)]/country',
                child_doc_number TEXT PATH 'relation/child-doc/document-id[not(@*)]/doc-number',
                child_doc_kind TEXT PATH 'relation/child-doc/document-id[not(@*)]/kind',
                child_doc_name TEXT PATH 'relation/child-doc/document-id[not(@*)]/name',
                child_doc_date TEXT PATH 'relation/child-doc/document-id[not(@*)]/date'                
                )
    ON CONFLICT DO NOTHING;

    -- lexis_nexis_patent_related_document_continuation_in_parts
    INSERT INTO lexis_nexis_patent_related_document_continuation_in_parts(country_code,doc_number,kind_code,parent_doc_country,parent_doc_number,parent_doc_kind,
                                                              parent_doc_name,parent_doc_date,parent_status,parent_grant_document_country,parent_grant_document_number,
                                                              parent_grant_document_kind,parent_grant_document_name,parent_grant_document_date,
                                                              parent_pct_document_country,parent_pct_document_number,parent_pct_document_kind,parent_pct_document_name,
                                                              parent_pct_document_date,child_doc_country,child_doc_number,child_doc_kind,child_doc_name,child_doc_date)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.parent_doc_country,
          xmltable.parent_doc_number,
          xmltable.parent_doc_kind,
          xmltable.parent_doc_name,
          xmltable.parent_doc_date,
          xmltable.parent_status,
          xmltable.parent_grant_document_country,
          xmltable.parent_grant_document_number,
          xmltable.parent_grant_document_kind,
          xmltable.parent_grant_document_name,
          xmltable.parent_grant_document_date,
          xmltable.parent_pct_document_country,
          xmltable.parent_pct_document_number,
          xmltable.parent_pct_document_kind,
          xmltable.parent_pct_document_name,
          xmltable.parent_pct_document_date,
          xmltable.child_doc_country,
          xmltable.child_doc_number,
          xmltable.child_doc_kind,
          xmltable.child_doc_name,
          xmltable.child_doc_date
     FROM
     XMLTABLE('//bibliographic-data/related-documents/continuation-in-part' PASSING input_xml COLUMNS --
                country_code TEXT PATH '../../publication-reference/document-id[not(@*)]/country' NOT NULL,
                doc_number TEXT PATH '../../publication-reference/document-id[not(@*)]/doc-number' NOT NULL,
                kind_code TEXT PATH '../../publication-reference/document-id[not(@*)]/kind' NOT NULL,
                parent_doc_country TEXT PATH 'relation/parent-doc/document-id[not(@*)]/country',
                parent_doc_number TEXT PATH 'relation/parent-doc/document-id[not(@*)]/doc-number',
                parent_doc_kind TEXT PATH 'relation/parent-doc/document-id[not(@*)]/kind',
                parent_doc_name TEXT PATH 'relation/parent-doc/document-id[not(@*)]/name',
                parent_doc_date TEXT PATH 'relation/parent-doc/document-id[not(@*)]/date',
                parent_status TEXT PATH 'relation/parent-doc/parent-status',
                parent_grant_document_country TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/country',
                parent_grant_document_number TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/doc-number',
                parent_grant_document_kind TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/kind',
                parent_grant_document_name TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/name',
                parent_grant_document_date TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/date',
                parent_pct_document_country TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/country',
                parent_pct_document_number TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/doc-number',
                parent_pct_document_kind TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/kind',
                parent_pct_document_name TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/name',
                parent_pct_document_date TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/date',
                child_doc_country TEXT PATH 'relation/child-doc/document-id[not(@*)]/country',
                child_doc_number TEXT PATH 'relation/child-doc/document-id[not(@*)]/doc-number',
                child_doc_kind TEXT PATH 'relation/child-doc/document-id[not(@*)]/kind',
                child_doc_name TEXT PATH 'relation/child-doc/document-id[not(@*)]/name',
                child_doc_date TEXT PATH 'relation/child-doc/document-id[not(@*)]/date'                
                )
    ON CONFLICT DO NOTHING;

    -- lexis_nexis_patent_related_document_continuing_reissues
    INSERT INTO lexis_nexis_patent_related_document_continuing_reissues(country_code,doc_number,kind_code,parent_doc_country,parent_doc_number,parent_doc_kind,
                                                              parent_doc_name,parent_doc_date,parent_status,parent_grant_document_country,parent_grant_document_number,
                                                              parent_grant_document_kind,parent_grant_document_name,parent_grant_document_date,
                                                              parent_pct_document_country,parent_pct_document_number,parent_pct_document_kind,parent_pct_document_name,
                                                              parent_pct_document_date,child_doc_country,child_doc_number,child_doc_kind,child_doc_name,child_doc_date)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.parent_doc_country,
          xmltable.parent_doc_number,
          xmltable.parent_doc_kind,
          xmltable.parent_doc_name,
          xmltable.parent_doc_date,
          xmltable.parent_status,
          xmltable.parent_grant_document_country,
          xmltable.parent_grant_document_number,
          xmltable.parent_grant_document_kind,
          xmltable.parent_grant_document_name,
          xmltable.parent_grant_document_date,
          xmltable.parent_pct_document_country,
          xmltable.parent_pct_document_number,
          xmltable.parent_pct_document_kind,
          xmltable.parent_pct_document_name,
          xmltable.parent_pct_document_date,
          xmltable.child_doc_country,
          xmltable.child_doc_number,
          xmltable.child_doc_kind,
          xmltable.child_doc_name,
          xmltable.child_doc_date
     FROM
     XMLTABLE('//bibliographic-data/related-documents/continuing-reissue' PASSING input_xml COLUMNS --
                country_code TEXT PATH '../../publication-reference/document-id[not(@*)]/country' NOT NULL,
                doc_number TEXT PATH '../../publication-reference/document-id[not(@*)]/doc-number' NOT NULL,
                kind_code TEXT PATH '../../publication-reference/document-id[not(@*)]/kind' NOT NULL,
                parent_doc_country TEXT PATH 'relation/parent-doc/document-id[not(@*)]/country',
                parent_doc_number TEXT PATH 'relation/parent-doc/document-id[not(@*)]/doc-number',
                parent_doc_kind TEXT PATH 'relation/parent-doc/document-id[not(@*)]/kind',
                parent_doc_name TEXT PATH 'relation/parent-doc/document-id[not(@*)]/name',
                parent_doc_date TEXT PATH 'relation/parent-doc/document-id[not(@*)]/date',
                parent_status TEXT PATH 'relation/parent-doc/parent-status',
                parent_grant_document_country TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/country',
                parent_grant_document_number TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/doc-number',
                parent_grant_document_kind TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/kind',
                parent_grant_document_name TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/name',
                parent_grant_document_date TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/date',
                parent_pct_document_country TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/country',
                parent_pct_document_number TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/doc-number',
                parent_pct_document_kind TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/kind',
                parent_pct_document_name TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/name',
                parent_pct_document_date TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/date',
                child_doc_country TEXT PATH 'relation/child-doc/document-id[not(@*)]/country',
                child_doc_number TEXT PATH 'relation/child-doc/document-id[not(@*)]/doc-number',
                child_doc_kind TEXT PATH 'relation/child-doc/document-id[not(@*)]/kind',
                child_doc_name TEXT PATH 'relation/child-doc/document-id[not(@*)]/name',
                child_doc_date TEXT PATH 'relation/child-doc/document-id[not(@*)]/date'                
                )
    ON CONFLICT DO NOTHING;

    -- lexis_nexis_patent_related_document_reissues
    INSERT INTO lexis_nexis_patent_related_document_reissues(country_code,doc_number,kind_code,parent_doc_country,parent_doc_number,parent_doc_kind,
                                                              parent_doc_name,parent_doc_date,parent_status,parent_grant_document_country,parent_grant_document_number,
                                                              parent_grant_document_kind,parent_grant_document_name,parent_grant_document_date,
                                                              parent_pct_document_country,parent_pct_document_number,parent_pct_document_kind,parent_pct_document_name,
                                                              parent_pct_document_date,child_doc_country,child_doc_number,child_doc_kind,child_doc_name,child_doc_date)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.parent_doc_country,
          xmltable.parent_doc_number,
          xmltable.parent_doc_kind,
          xmltable.parent_doc_name,
          xmltable.parent_doc_date,
          xmltable.parent_status,
          xmltable.parent_grant_document_country,
          xmltable.parent_grant_document_number,
          xmltable.parent_grant_document_kind,
          xmltable.parent_grant_document_name,
          xmltable.parent_grant_document_date,
          xmltable.parent_pct_document_country,
          xmltable.parent_pct_document_number,
          xmltable.parent_pct_document_kind,
          xmltable.parent_pct_document_name,
          xmltable.parent_pct_document_date,
          xmltable.child_doc_country,
          xmltable.child_doc_number,
          xmltable.child_doc_kind,
          xmltable.child_doc_name,
          xmltable.child_doc_date
     FROM
     XMLTABLE('//bibliographic-data/related-documents/reissue' PASSING input_xml COLUMNS --
                country_code TEXT PATH '../../publication-reference/document-id[not(@*)]/country' NOT NULL,
                doc_number TEXT PATH '../../publication-reference/document-id[not(@*)]/doc-number' NOT NULL,
                kind_code TEXT PATH '../../publication-reference/document-id[not(@*)]/kind' NOT NULL,
                parent_doc_country TEXT PATH 'relation/parent-doc/document-id[not(@*)]/country',
                parent_doc_number TEXT PATH 'relation/parent-doc/document-id[not(@*)]/doc-number',
                parent_doc_kind TEXT PATH 'relation/parent-doc/document-id[not(@*)]/kind',
                parent_doc_name TEXT PATH 'relation/parent-doc/document-id[not(@*)]/name',
                parent_doc_date TEXT PATH 'relation/parent-doc/document-id[not(@*)]/date',
                parent_status TEXT PATH 'relation/parent-doc/parent-status',
                parent_grant_document_country TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/country',
                parent_grant_document_number TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/doc-number',
                parent_grant_document_kind TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/kind',
                parent_grant_document_name TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/name',
                parent_grant_document_date TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/date',
                parent_pct_document_country TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/country',
                parent_pct_document_number TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/doc-number',
                parent_pct_document_kind TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/kind',
                parent_pct_document_name TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/name',
                parent_pct_document_date TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/date',
                child_doc_country TEXT PATH 'relation/child-doc/document-id[not(@*)]/country',
                child_doc_number TEXT PATH 'relation/child-doc/document-id[not(@*)]/doc-number',
                child_doc_kind TEXT PATH 'relation/child-doc/document-id[not(@*)]/kind',
                child_doc_name TEXT PATH 'relation/child-doc/document-id[not(@*)]/name',
                child_doc_date TEXT PATH 'relation/child-doc/document-id[not(@*)]/date'                
                )
    ON CONFLICT DO NOTHING;

    -- lexis_nexis_patent_related_document_divisional_reissues
    INSERT INTO lexis_nexis_patent_related_document_divisional_reissues(country_code,doc_number,kind_code,parent_doc_country,parent_doc_number,parent_doc_kind,
                                                              parent_doc_name,parent_doc_date,parent_status,parent_grant_document_country,parent_grant_document_number,
                                                              parent_grant_document_kind,parent_grant_document_name,parent_grant_document_date,
                                                              parent_pct_document_country,parent_pct_document_number,parent_pct_document_kind,parent_pct_document_name,
                                                              parent_pct_document_date,child_doc_country,child_doc_number,child_doc_kind,child_doc_name,child_doc_date)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.parent_doc_country,
          xmltable.parent_doc_number,
          xmltable.parent_doc_kind,
          xmltable.parent_doc_name,
          xmltable.parent_doc_date,
          xmltable.parent_status,
          xmltable.parent_grant_document_country,
          xmltable.parent_grant_document_number,
          xmltable.parent_grant_document_kind,
          xmltable.parent_grant_document_name,
          xmltable.parent_grant_document_date,
          xmltable.parent_pct_document_country,
          xmltable.parent_pct_document_number,
          xmltable.parent_pct_document_kind,
          xmltable.parent_pct_document_name,
          xmltable.parent_pct_document_date,
          xmltable.child_doc_country,
          xmltable.child_doc_number,
          xmltable.child_doc_kind,
          xmltable.child_doc_name,
          xmltable.child_doc_date
     FROM
     XMLTABLE('//bibliographic-data/related-documents/divisional-reissue' PASSING input_xml COLUMNS --
                country_code TEXT PATH '../../publication-reference/document-id[not(@*)]/country' NOT NULL,
                doc_number TEXT PATH '../../publication-reference/document-id[not(@*)]/doc-number' NOT NULL,
                kind_code TEXT PATH '../../publication-reference/document-id[not(@*)]/kind' NOT NULL,
                parent_doc_country TEXT PATH 'relation/parent-doc/document-id[not(@*)]/country',
                parent_doc_number TEXT PATH 'relation/parent-doc/document-id[not(@*)]/doc-number',
                parent_doc_kind TEXT PATH 'relation/parent-doc/document-id[not(@*)]/kind',
                parent_doc_name TEXT PATH 'relation/parent-doc/document-id[not(@*)]/name',
                parent_doc_date TEXT PATH 'relation/parent-doc/document-id[not(@*)]/date',
                parent_status TEXT PATH 'relation/parent-doc/parent-status',
                parent_grant_document_country TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/country',
                parent_grant_document_number TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/doc-number',
                parent_grant_document_kind TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/kind',
                parent_grant_document_name TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/name',
                parent_grant_document_date TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/date',
                parent_pct_document_country TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/country',
                parent_pct_document_number TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/doc-number',
                parent_pct_document_kind TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/kind',
                parent_pct_document_name TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/name',
                parent_pct_document_date TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/date',
                child_doc_country TEXT PATH 'relation/child-doc/document-id[not(@*)]/country',
                child_doc_number TEXT PATH 'relation/child-doc/document-id[not(@*)]/doc-number',
                child_doc_kind TEXT PATH 'relation/child-doc/document-id[not(@*)]/kind',
                child_doc_name TEXT PATH 'relation/child-doc/document-id[not(@*)]/name',
                child_doc_date TEXT PATH 'relation/child-doc/document-id[not(@*)]/date'                
                )
    ON CONFLICT DO NOTHING;

    -- lexis_nexis_patent_related_document_reexaminations
    INSERT INTO lexis_nexis_patent_related_document_reexaminations(country_code,doc_number,kind_code,parent_doc_country,parent_doc_number,parent_doc_kind,
                                                              parent_doc_name,parent_doc_date,parent_status,parent_grant_document_country,parent_grant_document_number,
                                                              parent_grant_document_kind,parent_grant_document_name,parent_grant_document_date,
                                                              parent_pct_document_country,parent_pct_document_number,parent_pct_document_kind,parent_pct_document_name,
                                                              parent_pct_document_date,child_doc_country,child_doc_number,child_doc_kind,child_doc_name,child_doc_date)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.parent_doc_country,
          xmltable.parent_doc_number,
          xmltable.parent_doc_kind,
          xmltable.parent_doc_name,
          xmltable.parent_doc_date,
          xmltable.parent_status,
          xmltable.parent_grant_document_country,
          xmltable.parent_grant_document_number,
          xmltable.parent_grant_document_kind,
          xmltable.parent_grant_document_name,
          xmltable.parent_grant_document_date,
          xmltable.parent_pct_document_country,
          xmltable.parent_pct_document_number,
          xmltable.parent_pct_document_kind,
          xmltable.parent_pct_document_name,
          xmltable.parent_pct_document_date,
          xmltable.child_doc_country,
          xmltable.child_doc_number,
          xmltable.child_doc_kind,
          xmltable.child_doc_name,
          xmltable.child_doc_date
     FROM
     XMLTABLE('//bibliographic-data/related-documents/reexamination' PASSING input_xml COLUMNS --
                country_code TEXT PATH '../../publication-reference/document-id[not(@*)]/country' NOT NULL,
                doc_number TEXT PATH '../../publication-reference/document-id[not(@*)]/doc-number' NOT NULL,
                kind_code TEXT PATH '../../publication-reference/document-id[not(@*)]/kind' NOT NULL,
                parent_doc_country TEXT PATH 'relation/parent-doc/document-id[not(@*)]/country',
                parent_doc_number TEXT PATH 'relation/parent-doc/document-id[not(@*)]/doc-number',
                parent_doc_kind TEXT PATH 'relation/parent-doc/document-id[not(@*)]/kind',
                parent_doc_name TEXT PATH 'relation/parent-doc/document-id[not(@*)]/name',
                parent_doc_date TEXT PATH 'relation/parent-doc/document-id[not(@*)]/date',
                parent_status TEXT PATH 'relation/parent-doc/parent-status',
                parent_grant_document_country TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/country',
                parent_grant_document_number TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/doc-number',
                parent_grant_document_kind TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/kind',
                parent_grant_document_name TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/name',
                parent_grant_document_date TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/date',
                parent_pct_document_country TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/country',
                parent_pct_document_number TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/doc-number',
                parent_pct_document_kind TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/kind',
                parent_pct_document_name TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/name',
                parent_pct_document_date TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/date',
                child_doc_country TEXT PATH 'relation/child-doc/document-id[not(@*)]/country',
                child_doc_number TEXT PATH 'relation/child-doc/document-id[not(@*)]/doc-number',
                child_doc_kind TEXT PATH 'relation/child-doc/document-id[not(@*)]/kind',
                child_doc_name TEXT PATH 'relation/child-doc/document-id[not(@*)]/name',
                child_doc_date TEXT PATH 'relation/child-doc/document-id[not(@*)]/date'                
                )
    ON CONFLICT DO NOTHING;

    -- lexis_nexis_patent_related_document_reexamination_reissue_mergers
    INSERT INTO lexis_nexis_patent_related_document_reexamination_reissue_mergers(country_code,doc_number,kind_code,parent_doc_country,parent_doc_number,parent_doc_kind,
                                                              parent_doc_name,parent_doc_date,parent_status,parent_grant_document_country,parent_grant_document_number,
                                                              parent_grant_document_kind,parent_grant_document_name,parent_grant_document_date,
                                                              parent_pct_document_country,parent_pct_document_number,parent_pct_document_kind,parent_pct_document_name,
                                                              parent_pct_document_date,child_doc_country,child_doc_number,child_doc_kind,child_doc_name,child_doc_date)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.parent_doc_country,
          xmltable.parent_doc_number,
          xmltable.parent_doc_kind,
          xmltable.parent_doc_name,
          xmltable.parent_doc_date,
          xmltable.parent_status,
          xmltable.parent_grant_document_country,
          xmltable.parent_grant_document_number,
          xmltable.parent_grant_document_kind,
          xmltable.parent_grant_document_name,
          xmltable.parent_grant_document_date,
          xmltable.parent_pct_document_country,
          xmltable.parent_pct_document_number,
          xmltable.parent_pct_document_kind,
          xmltable.parent_pct_document_name,
          xmltable.parent_pct_document_date,
          xmltable.child_doc_country,
          xmltable.child_doc_number,
          xmltable.child_doc_kind,
          xmltable.child_doc_name,
          xmltable.child_doc_date
     FROM
     XMLTABLE('//bibliographic-data/related-documents/reexamination-reissue-merger' PASSING input_xml COLUMNS --
                country_code TEXT PATH '../../publication-reference/document-id[not(@*)]/country' NOT NULL,
                doc_number TEXT PATH '../../publication-reference/document-id[not(@*)]/doc-number' NOT NULL,
                kind_code TEXT PATH '../../publication-reference/document-id[not(@*)]/kind' NOT NULL,
                parent_doc_country TEXT PATH 'relation/parent-doc/document-id[not(@*)]/country',
                parent_doc_number TEXT PATH 'relation/parent-doc/document-id[not(@*)]/doc-number',
                parent_doc_kind TEXT PATH 'relation/parent-doc/document-id[not(@*)]/kind',
                parent_doc_name TEXT PATH 'relation/parent-doc/document-id[not(@*)]/name',
                parent_doc_date TEXT PATH 'relation/parent-doc/document-id[not(@*)]/date',
                parent_status TEXT PATH 'relation/parent-doc/parent-status',
                parent_grant_document_country TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/country',
                parent_grant_document_number TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/doc-number',
                parent_grant_document_kind TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/kind',
                parent_grant_document_name TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/name',
                parent_grant_document_date TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/date',
                parent_pct_document_country TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/country',
                parent_pct_document_number TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/doc-number',
                parent_pct_document_kind TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/kind',
                parent_pct_document_name TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/name',
                parent_pct_document_date TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/date',
                child_doc_country TEXT PATH 'relation/child-doc/document-id[not(@*)]/country',
                child_doc_number TEXT PATH 'relation/child-doc/document-id[not(@*)]/doc-number',
                child_doc_kind TEXT PATH 'relation/child-doc/document-id[not(@*)]/kind',
                child_doc_name TEXT PATH 'relation/child-doc/document-id[not(@*)]/name',
                child_doc_date TEXT PATH 'relation/child-doc/document-id[not(@*)]/date'                
                )
    ON CONFLICT DO NOTHING;

    -- lexis_nexis_patent_related_document_substitutions
    INSERT INTO lexis_nexis_patent_related_document_substitutions(country_code,doc_number,kind_code,parent_doc_country,parent_doc_number,parent_doc_kind,
                                                              parent_doc_name,parent_doc_date,parent_status,parent_grant_document_country,parent_grant_document_number,
                                                              parent_grant_document_kind,parent_grant_document_name,parent_grant_document_date,
                                                              parent_pct_document_country,parent_pct_document_number,parent_pct_document_kind,parent_pct_document_name,
                                                              parent_pct_document_date,child_doc_country,child_doc_number,child_doc_kind,child_doc_name,child_doc_date)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.parent_doc_country,
          xmltable.parent_doc_number,
          xmltable.parent_doc_kind,
          xmltable.parent_doc_name,
          xmltable.parent_doc_date,
          xmltable.parent_status,
          xmltable.parent_grant_document_country,
          xmltable.parent_grant_document_number,
          xmltable.parent_grant_document_kind,
          xmltable.parent_grant_document_name,
          xmltable.parent_grant_document_date,
          xmltable.parent_pct_document_country,
          xmltable.parent_pct_document_number,
          xmltable.parent_pct_document_kind,
          xmltable.parent_pct_document_name,
          xmltable.parent_pct_document_date,
          xmltable.child_doc_country,
          xmltable.child_doc_number,
          xmltable.child_doc_kind,
          xmltable.child_doc_name,
          xmltable.child_doc_date
     FROM
     XMLTABLE('//bibliographic-data/related-documents/substitution' PASSING input_xml COLUMNS --
                country_code TEXT PATH '../../publication-reference/document-id[not(@*)]/country' NOT NULL,
                doc_number TEXT PATH '../../publication-reference/document-id[not(@*)]/doc-number' NOT NULL,
                kind_code TEXT PATH '../../publication-reference/document-id[not(@*)]/kind' NOT NULL,
                parent_doc_country TEXT PATH 'relation/parent-doc/document-id[not(@*)]/country',
                parent_doc_number TEXT PATH 'relation/parent-doc/document-id[not(@*)]/doc-number',
                parent_doc_kind TEXT PATH 'relation/parent-doc/document-id[not(@*)]/kind',
                parent_doc_name TEXT PATH 'relation/parent-doc/document-id[not(@*)]/name',
                parent_doc_date TEXT PATH 'relation/parent-doc/document-id[not(@*)]/date',
                parent_status TEXT PATH 'relation/parent-doc/parent-status',
                parent_grant_document_country TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/country',
                parent_grant_document_number TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/doc-number',
                parent_grant_document_kind TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/kind',
                parent_grant_document_name TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/name',
                parent_grant_document_date TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/date',
                parent_pct_document_country TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/country',
                parent_pct_document_number TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/doc-number',
                parent_pct_document_kind TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/kind',
                parent_pct_document_name TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/name',
                parent_pct_document_date TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/date',
                child_doc_country TEXT PATH 'relation/child-doc/document-id[not(@*)]/country',
                child_doc_number TEXT PATH 'relation/child-doc/document-id[not(@*)]/doc-number',
                child_doc_kind TEXT PATH 'relation/child-doc/document-id[not(@*)]/kind',
                child_doc_name TEXT PATH 'relation/child-doc/document-id[not(@*)]/name',
                child_doc_date TEXT PATH 'relation/child-doc/document-id[not(@*)]/date'                
                )
    ON CONFLICT DO NOTHING;

    -- lexis_nexis_patent_related_document_provisional_applications
    INSERT INTO lexis_nexis_patent_related_document_provisional_applications(country_code,doc_number,kind_code,related_doc_country,
                                                                            related_doc_number,related_doc_kind,related_doc_name,related_doc_date)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.related_doc_country,
          xmltable.related_doc_number,
          xmltable.related_doc_kind,
          xmltable.related_doc_name,
          xmltable.related_doc_date
     FROM
     XMLTABLE('//bibliographic-data/related-documents/provisional-application' PASSING input_xml COLUMNS --
                country_code TEXT PATH '../../publication-reference/document-id[not(@*)]/country' NOT NULL,
                doc_number TEXT PATH '../../publication-reference/document-id[not(@*)]/doc-number' NOT NULL,
                kind_code TEXT PATH '../../publication-reference/document-id[not(@*)]/kind' NOT NULL,
                related_doc_country TEXT PATH 'document-id[not(@*)]/country',
                related_doc_number TEXT PATH 'document-id[not(@*)]/doc-number',
                related_doc_kind TEXT PATH 'document-id[not(@*)]/kind',
                related_doc_name TEXT PATH 'document-id[not(@*)]/name',
                related_doc_date TEXT PATH 'document-id[not(@*)]/date'           
                )
    ON CONFLICT DO NOTHING;

    -- lexis_nexis_patent_related_document_utility_model_basis
    INSERT INTO lexis_nexis_patent_related_document_utility_model_basis(country_code,doc_number,kind_code,parent_doc_country,parent_doc_number,parent_doc_kind,
                                                              parent_doc_name,parent_doc_date,parent_status,parent_grant_document_country,parent_grant_document_number,
                                                              parent_grant_document_kind,parent_grant_document_name,parent_grant_document_date,
                                                              parent_pct_document_country,parent_pct_document_number,parent_pct_document_kind,parent_pct_document_name,
                                                              parent_pct_document_date,child_doc_country,child_doc_number,child_doc_kind,child_doc_name,child_doc_date)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.parent_doc_country,
          xmltable.parent_doc_number,
          xmltable.parent_doc_kind,
          xmltable.parent_doc_name,
          xmltable.parent_doc_date,
          xmltable.parent_status,
          xmltable.parent_grant_document_country,
          xmltable.parent_grant_document_number,
          xmltable.parent_grant_document_kind,
          xmltable.parent_grant_document_name,
          xmltable.parent_grant_document_date,
          xmltable.parent_pct_document_country,
          xmltable.parent_pct_document_number,
          xmltable.parent_pct_document_kind,
          xmltable.parent_pct_document_name,
          xmltable.parent_pct_document_date,
          xmltable.child_doc_country,
          xmltable.child_doc_number,
          xmltable.child_doc_kind,
          xmltable.child_doc_name,
          xmltable.child_doc_date
     FROM
     XMLTABLE('//bibliographic-data/related-documents/utility-model-basis' PASSING input_xml COLUMNS --
                country_code TEXT PATH '../../publication-reference/document-id[not(@*)]/country' NOT NULL,
                doc_number TEXT PATH '../../publication-reference/document-id[not(@*)]/doc-number' NOT NULL,
                kind_code TEXT PATH '../../publication-reference/document-id[not(@*)]/kind' NOT NULL,
                parent_doc_country TEXT PATH 'relation/parent-doc/document-id[not(@*)]/country',
                parent_doc_number TEXT PATH 'relation/parent-doc/document-id[not(@*)]/doc-number',
                parent_doc_kind TEXT PATH 'relation/parent-doc/document-id[not(@*)]/kind',
                parent_doc_name TEXT PATH 'relation/parent-doc/document-id[not(@*)]/name',
                parent_doc_date TEXT PATH 'relation/parent-doc/document-id[not(@*)]/date',
                parent_status TEXT PATH 'relation/parent-doc/parent-status',
                parent_grant_document_country TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/country',
                parent_grant_document_number TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/doc-number',
                parent_grant_document_kind TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/kind',
                parent_grant_document_name TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/name',
                parent_grant_document_date TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/date',
                parent_pct_document_country TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/country',
                parent_pct_document_number TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/doc-number',
                parent_pct_document_kind TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/kind',
                parent_pct_document_name TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/name',
                parent_pct_document_date TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/date',
                child_doc_country TEXT PATH 'relation/child-doc/document-id[not(@*)]/country',
                child_doc_number TEXT PATH 'relation/child-doc/document-id[not(@*)]/doc-number',
                child_doc_kind TEXT PATH 'relation/child-doc/document-id[not(@*)]/kind',
                child_doc_name TEXT PATH 'relation/child-doc/document-id[not(@*)]/name',
                child_doc_date TEXT PATH 'relation/child-doc/document-id[not(@*)]/date'                
                )
    ON CONFLICT DO NOTHING;

    -- lexis_nexis_patent_related_corrections
    -- TODO: haven't found any sample data yet

    -- lexis_nexis_patent_related_publications
    INSERT INTO lexis_nexis_patent_related_publications(country_code,doc_number,kind_code,related_pub_country,
                                                        related_pub_number,related_pub_kind,related_pub_name,related_pub_date)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.related_pub_country,
          xmltable.related_pub_number,
          xmltable.related_pub_kind,
          xmltable.related_pub_name,
          xmltable.related_pub_date
     FROM
     XMLTABLE('//bibliographic-data/related-documents/related-publication' PASSING input_xml COLUMNS --
                country_code TEXT PATH '../../publication-reference/document-id[not(@*)]/country' NOT NULL,
                doc_number TEXT PATH '../../publication-reference/document-id[not(@*)]/doc-number' NOT NULL,
                kind_code TEXT PATH '../../publication-reference/document-id[not(@*)]/kind' NOT NULL,
                related_pub_country TEXT PATH 'document-id[not(@*)]/country',
                related_pub_number TEXT PATH 'document-id[not(@*)]/doc-number',
                related_pub_kind TEXT PATH 'document-id[not(@*)]/kind',
                related_pub_name TEXT PATH 'document-id[not(@*)]/name',
                related_pub_date TEXT PATH 'document-id[not(@*)]/date'           
                )
    ON CONFLICT DO NOTHING;

    -- lexis_nexis_patent_related_document_371_international
    INSERT INTO lexis_nexis_patent_related_document_371_international(country_code,doc_number,kind_code,parent_doc_country,parent_doc_number,parent_doc_kind,
                                                              parent_doc_name,parent_doc_date,parent_status,parent_grant_document_country,parent_grant_document_number,
                                                              parent_grant_document_kind,parent_grant_document_name,parent_grant_document_date,
                                                              parent_pct_document_country,parent_pct_document_number,parent_pct_document_kind,parent_pct_document_name,
                                                              parent_pct_document_date,child_doc_country,child_doc_number,child_doc_kind,child_doc_name,child_doc_date)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.parent_doc_country,
          xmltable.parent_doc_number,
          xmltable.parent_doc_kind,
          xmltable.parent_doc_name,
          xmltable.parent_doc_date,
          xmltable.parent_status,
          xmltable.parent_grant_document_country,
          xmltable.parent_grant_document_number,
          xmltable.parent_grant_document_kind,
          xmltable.parent_grant_document_name,
          xmltable.parent_grant_document_date,
          xmltable.parent_pct_document_country,
          xmltable.parent_pct_document_number,
          xmltable.parent_pct_document_kind,
          xmltable.parent_pct_document_name,
          xmltable.parent_pct_document_date,
          xmltable.child_doc_country,
          xmltable.child_doc_number,
          xmltable.child_doc_kind,
          xmltable.child_doc_name,
          xmltable.child_doc_date
     FROM
     XMLTABLE('//bibliographic-data/related-documents/a-371-of-international' PASSING input_xml COLUMNS --
                country_code TEXT PATH '../../publication-reference/document-id[not(@*)]/country' NOT NULL,
                doc_number TEXT PATH '../../publication-reference/document-id[not(@*)]/doc-number' NOT NULL,
                kind_code TEXT PATH '../../publication-reference/document-id[not(@*)]/kind' NOT NULL,
                parent_doc_country TEXT PATH 'relation/parent-doc/document-id[not(@*)]/country',
                parent_doc_number TEXT PATH 'relation/parent-doc/document-id[not(@*)]/doc-number',
                parent_doc_kind TEXT PATH 'relation/parent-doc/document-id[not(@*)]/kind',
                parent_doc_name TEXT PATH 'relation/parent-doc/document-id[not(@*)]/name',
                parent_doc_date TEXT PATH 'relation/parent-doc/document-id[not(@*)]/date',
                parent_status TEXT PATH 'relation/parent-doc/parent-status',
                parent_grant_document_country TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/country',
                parent_grant_document_number TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/doc-number',
                parent_grant_document_kind TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/kind',
                parent_grant_document_name TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/name',
                parent_grant_document_date TEXT PATH 'relation/parent-doc/parent-grant-document/document-id[not(@*)]/date',
                parent_pct_document_country TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/country',
                parent_pct_document_number TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/doc-number',
                parent_pct_document_kind TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/kind',
                parent_pct_document_name TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/name',
                parent_pct_document_date TEXT PATH 'relation/parent-doc/parent-pct-document/document-id[not(@*)]/date',
                child_doc_country TEXT PATH 'relation/child-doc/document-id[not(@*)]/country',
                child_doc_number TEXT PATH 'relation/child-doc/document-id[not(@*)]/doc-number',
                child_doc_kind TEXT PATH 'relation/child-doc/document-id[not(@*)]/kind',
                child_doc_name TEXT PATH 'relation/child-doc/document-id[not(@*)]/name',
                child_doc_date TEXT PATH 'relation/child-doc/document-id[not(@*)]/date'                
                )
    ON CONFLICT DO NOTHING;

  END;
$$
LANGUAGE plpgsql;