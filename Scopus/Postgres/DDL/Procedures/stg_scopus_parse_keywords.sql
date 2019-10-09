\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE stg_scopus_parse_keywords(scopus_doc_xml XML)
  LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO stg_scopus_keywords(scp, keyword)
  SELECT DISTINCT scp, keyword
    FROM
      xmltable(XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
               '//bibrecord/head/citation-info/author-keywords/author-keyword' PASSING scopus_doc_xml COLUMNS --
                 scp BIGINT PATH '../../../../item-info/itemidlist/itemid[@idtype="SCP"]', --
                 keyword TEXT PATH '.');
END; $$