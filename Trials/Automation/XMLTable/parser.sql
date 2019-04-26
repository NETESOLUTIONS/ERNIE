/*
  parser.sql
*/


\set ON_ERROR_STOP ON

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

SET script.xml_file = :'xml_file';

-- TODO ON CONFLICT DO NOTHING need to be replaced by updates


/*
  Code block to call various functions that will populate the several CT tables
*/

DO $block$
  DECLARE
    -- scopus_doc TEXT;
    scopus_doc_xml XML;
  BEGIN
    SELECT xmlparse(DOCUMENT convert_from(pg_read_binary_file(current_setting('script.xml_file')), 'UTF8'))
      INTO scopus_doc_xml;

    CALL scopus_parse_publication(scopus_doc_xml);
    CALL update_scopus_source_classifications(scopus_doc_xml);
    CALL update_scopus_author_affiliations(scopus_doc_xml);
    -- scopus_references
    CALL update_references(scopus_doc_xml);
    CALL update_scopus_chemical_groups(scopus_doc_xml);
    CALL update_scopus_abstracts_title(scopus_doc_xml);
    CALL update_scopus_keywords(scopus_doc_xml);
    CALL update_scopus_publication_identifiers(scopus_doc_xml);
  EXCEPTION
    WHEN OTHERS THEN --
      RAISE NOTICE E'Processing of % FAILED', current_setting('script.xml_file');
      --  RAISE NOTICE E'ERROR during processing of:\n-----\n%\n-----', scopus_doc_xml;
      RAISE;
  END $block$;
