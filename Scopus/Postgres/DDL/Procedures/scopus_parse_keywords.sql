\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE scopus_parse_keywords(scopus_doc_xml XML) AS $$
BEGIN
  INSERT
  INTO scopus_keywords(
    scp, keyword)
  SELECT DISTINCT scp, keyword
  FROM
    xmltable(XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
             '//bibrecord/head/citation-info/author-keywords/author-keyword' PASSING scopus_doc_xml
             COLUMNS scp BIGINT PATH '../../../../item-info/itemidlist/itemid[@idtype="SCP"]', keyword TEXT PATH '.')
  ON CONFLICT (scp, keyword) DO UPDATE SET keyword=excluded.keyword;
END;
$$
LANGUAGE plpgsql;
COMMIT;
