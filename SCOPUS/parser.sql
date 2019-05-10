\set ON_ERROR_STOP on
-- Reduce verbosity
-- \set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

SET script.xml_file = :'xml_file';
SET script.sp_name = :'sp_name';

-- TODO ON CONFLICT DO NOTHING need to be replaced by updates

DO $block$
  DECLARE
    -- scopus_doc TEXT;
    scopus_doc_xml XML;
  BEGIN
    SELECT xmlparse(DOCUMENT convert_from(pg_read_binary_file(current_setting('script.xml_file')), 'UTF8'))
      INTO scopus_doc_xml;

    IF current_setting('script.sp_name') IS NULL THEN -- Execute all parsing SPs
      CALL scopus_parse_publication_and_group(scopus_doc_xml);
      CALL scopus_parse_source_and_conferences(scopus_doc_xml);
      CALL scopus_parse_pub_details_subjects_and_classes(scopus_doc_xml);
      CALL scopus_parse_authors_and_affiliations(scopus_doc_xml);
      CALL scopus_parse_chemical_groups(scopus_doc_xml);
      CALL scopus_parse_abstracts_and_titles(scopus_doc_xml);
      CALL scopus_parse_keywords(scopus_doc_xml);
      CALL scopus_parse_publication_identifiers(scopus_doc_xml);
      CALL scopus_parse_grants(scopus_doc_xml);
      CALL scopus_parse_references(scopus_doc_xml);
    ELSE -- Execute only the selected SP
      -- Make sure that parent records are present
      CALL scopus_parse_publication_and_group(scopus_doc_xml);

      EXECUTE format('CALL %I($1)',current_setting('script.sp_name')) using scopus_doc_xml;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN --
      RAISE NOTICE E'Processing of % FAILED', current_setting('script.xml_file');
      --  RAISE NOTICE E'ERROR during processing of:\n-----\n%\n-----', scopus_doc_xml;
      RAISE;
  END $block$;
