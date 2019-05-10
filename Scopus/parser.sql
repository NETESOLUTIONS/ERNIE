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

    IF current_setting('script.sp_name') IS NULL THEN
      CALL scopus_parse_publication(scopus_doc_xml);
      CALL update_scopus_source_classifications(scopus_doc_xml);
      CALL update_scopus_author_affiliations(scopus_doc_xml);
      -- scopus_references
      CALL update_references(scopus_doc_xml);
      CALL update_scopus_chemical_groups(scopus_doc_xml);
      CALL update_scopus_abstracts_title(scopus_doc_xml);
      CALL update_scopus_keywords(scopus_doc_xml);
      CALL update_scopus_publication_identifiers(scopus_doc_xml);
    ELSE
      CALL scopus_parse_publication(scopus_doc_xml);
      EXECUTE format('CALL %I($1)',current_setting('script.sp_name')) using scopus_doc_xml;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN --
      RAISE NOTICE E'Processing of % FAILED', current_setting('script.xml_file');
      --  RAISE NOTICE E'ERROR during processing of:\n-----\n%\n-----', scopus_doc_xml;
      RAISE;
  END $block$;

/*
-- scopus_publications: concatenated abstracts
/*
TODO Report. Despite what docs say, the text contents of child elements are *not* concatenated to the result
E.g. abstract TEXT PATH 'head/abstracts/abstract[@xml:lang="eng"]'
*/
SELECT scp, string_agg(abstract, chr(10) || chr(10)) AS abstract
FROM xmltable(--
-- The `xml:` namespace doesn’t need to be specified
  XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
  --@formatter:off
  '//bibrecord/head/abstracts/abstract[@xml:lang="eng"]/ce:para'
'//bibrecord/head/abstracts/abstract[@original="y"]/ce:para'
  PASSING :scopus_doc --
  COLUMNS --

  scp BIGINT PATH '../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
  abstract TEXT PATH 'normalize-space()'
--@formatter:on
  )
GROUP BY scp;