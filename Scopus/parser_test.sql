\set ON_ERROR_STOP on
-- Reduce verbosity
-- \set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

SET script.xml_file = :'xml_file';
\if :{?subset_sp}
  SET script.subset_sp = :'subset_sp';
\else
  SET script.subset_sp = '';
\endif

DO $block$
  DECLARE
    -- scopus_doc TEXT;
    scopus_doc_xml XML;
  BEGIN
    SELECT xmlparse(DOCUMENT convert_from(pg_read_binary_file(current_setting('script.xml_file')), 'UTF8'))
      INTO scopus_doc_xml;

    IF current_setting('script.subset_sp')='' THEN -- Execute all parsing SPs
      CALL jenkins.stg_scopus_parse_publication_and_group();
      CALL jenkins.stg_scopus_parse_source_and_conferences();
      CALL jenkins.stg_scopus_parse_pub_details_subjects_and_classes();
      CALL jenkins.stg_scopus_parse_authors_and_affiliations();
      CALL jenkins.stg_scopus_parse_chemical_groups();
      CALL jenkins.stg_scopus_parse_abstracts_and_titles();
      CALL jenkins.stg_scopus_parse_keywords();
      CALL jenkins.stg_scopus_parse_publication_identifiers();
      CALL jenkins.stg_scopus_parse_grants();
      CALL jenkins.stg_scopus_parse_references();
    ELSE -- Execute only the selected SP
      -- Make sure that parent records are present
      CALL jenkins.stg_scopus_parse_publication_and_group(scopus_doc_xml);

      EXECUTE format('CALL %I($1)',current_setting('script.subset_sp')) using scopus_doc_xml;
    END IF;

  /*
  EXCEPTION handling is not feasible with COMMITing procedures: causes `[2D000] ERROR: invalid transaction termination`

  EXCEPTION
    WHEN OTHERS THEN --
      RAISE NOTICE E'Processing of % FAILED', current_setting('script.xml_file');
      --  RAISE NOTICE E'ERROR during processing of:\n-----\n%\n-----', scopus_doc_xml;
      RAISE;*/
  END $block$;
