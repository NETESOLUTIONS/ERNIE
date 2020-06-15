/*
 Author: Djamil Lakhdar-Hamina

 lexis-nexis priority_claim parser.

 */

\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
SET search_path TO public;

 ---- region lexis_nexis_patent_priority_claims_parser

CREATE OR REPLACE PROCEDURE lexis_nexis_parse_patent_priority_claims(input_xml XML)
AS
$$
  BEGIN
      INSERT INTO lexis_nexis_patent_priority_claims(doc_number,country_code,kind_code,sequence_id,priority_claim_data_format,
                                                     priority_claim_date,priority_claim_country,priority_claim_doc_number,
                                                     priority_claim_kind,priority_active_indicator)
      SELECT
            xmltable.doc_number,
            xmltable.country_code,
            xmltable.kind_code,
            xmltable.sequence_id,
            COALESCE(xmltable.priority_claim_data_format,''),
            to_date(xmltable.priority_claim_date,'YYYYMMDD'),
            xmltable.priority_claim_country,
            xmltable.priority_claim_doc_number,
            xmltable.priority_claim_kind,
            xmltable.priority_active_indicator
      FROM
      XMLTABLE('//bibliographic-data/priority-claims/priority-claim' PASSING input_xml
               COLUMNS
                -- The highest-level of the xml tree-structure
                country_code TEXT PATH '//bibliographic-data/publication-reference/document-id/country' NOT NULL,
                doc_number TEXT PATH '//bibliographic-data/publication-reference/document-id/doc-number' NOT NULL,
                kind_code TEXT PATH '//bibliographic-data/publication-reference/document-id/kind' NOT NULL,
                -- Collect target attributes
                sequence_id INT PATH '@sequence' NOT NULL,
                priority_claim_data_format TEXT PATH '@data-format',

                -- Collect target subelements
                priority_claim_date TEXT PATH 'date',
                priority_claim_country TEXT PATH 'country',
                priority_claim_doc_number TEXT PATH 'doc-number',
                priority_claim_kind TEXT PATH 'kind',
                priority_active_indicator TEXT PATH 'priority-active-indicator'
                --priority_linkage_type TEXT PATH 'priority-linkage-type', not appearing in data at the moment, will need to examine further for presence
                --Similar issues to line above with office-of-filing data
              )
      ON CONFLICT (country_code, doc_number, kind_code, sequence_id, priority_claim_data_format)
      DO UPDATE SET priority_claim_date=excluded.priority_claim_date,priority_claim_country=excluded.priority_claim_country,
      priority_claim_doc_number=excluded.priority_claim_doc_number,priority_claim_kind=excluded.priority_claim_kind,
      priority_active_indicator=excluded.priority_active_indicator,last_updated_time=now();
END;
$$
LANGUAGE plpgsql;
