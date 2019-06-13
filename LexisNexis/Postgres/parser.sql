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

-- TODO ON CONFLICT DO NOTHING need to be replaced by updates

DO $block$
  DECLARE
    lexis_nexis_doc_xml XML;
  BEGIN
    SELECT xmlparse(DOCUMENT pg_read_file(current_setting('script.xml_file')))
      INTO lexis_nexis_doc_xml;

    IF current_setting('script.subset_sp')='' THEN -- Execute all parsing SPs
      CALL lexis_nexis_parse_patents(lexis_nexis_doc_xml);
      CALL lexis_nexis_parse_patent_titles(lexis_nexis_doc_xml);
      CALL lexis_nexis_parse_legal_data(lexis_nexis_doc_xml);
      CALL lexis_nexis_parse_abstracts(lexis_nexis_doc_xml);
      CALL lexis_nexis_parse_nonpatent_citations(lexis_nexis_doc_xml);
      CALL lexis_nexis_parse_examiners(lexis_nexis_doc_xml);
      --CALL lexis_nexis_parse_related_documents(lexis_nexis_doc_xml); * ERROR:  syntax error at or near "/" LINE 479: child_doc_name TEXT PATH 'relation/child-doc...
      CALL lexis_nexis_patent_citations_data(lexis_nexis_doc_xml);
      CALL lexis_nexis_patent_application_reference_data(lexis_nexis_doc_xml);

    ELSE -- Execute only the selected SP
      -- Make sure that parent records are present
      CALL lexis_nexis_parse_patents(lexis_nexis_doc_xml);
      EXECUTE format('CALL %I($1)',current_setting('script.subset_sp')) using lexis_nexis_doc_xml;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN --
      RAISE NOTICE E'Processing of % FAILED', current_setting('script.xml_file');
      RAISE;
  END $block$;
