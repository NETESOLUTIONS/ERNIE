\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE stg_scopus_parse_abstracts_and_titles(scopus_doc_xml XML)
  LANGUAGE plpgsql AS $$
BEGIN
  -- scopus_abstracts
  INSERT INTO stg_scopus_abstracts(scp, abstract_language)
  SELECT DISTINCT scp, abstract_language
    FROM
      xmltable(XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
               '//bibrecord/head/abstracts/abstract/ce:para' PASSING scopus_doc_xml
               COLUMNS scp BIGINT PATH '../../../../item-info/itemidlist/itemid[@idtype="SCP"]', abstract_language TEXT PATH '../@xml:lang');

    WITH sca AS (
      SELECT scp, abstract_language, string_agg(abstract_text, chr(10)) AS abstract_text
        FROM
          xmltable(XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
                   '//bibrecord/head/abstracts/abstract/ce:para' PASSING scopus_doc_xml
                   COLUMNS scp BIGINT PATH '../../../../item-info/itemidlist/itemid[@idtype="SCP"]', abstract_text TEXT PATH 'normalize-space()', abstract_language TEXT PATH '../@xml:lang')
       GROUP BY scp, abstract_language
    )
  UPDATE stg_scopus_abstracts sa
     SET abstract_text=sca.abstract_text
    FROM sca
   WHERE sa.scp = sca.scp AND sa.abstract_language = sca.abstract_language;

  -- scopus_titles
  INSERT INTO stg_scopus_titles(scp, title, language)
  SELECT scp, MAX(title) AS title, coalesce(language, '') AS language
    FROM
      xmltable(XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
               '//bibrecord/head/citation-title/titletext' PASSING scopus_doc_xml COLUMNS --
                 scp BIGINT PATH '../../../item-info/itemidlist/itemid[@idtype="SCP"]', --
                 title TEXT PATH 'normalize-space()', --
                 language TEXT PATH '@language')
   GROUP BY scp, language;
END; $$
