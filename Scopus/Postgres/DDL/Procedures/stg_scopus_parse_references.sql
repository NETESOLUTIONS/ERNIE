\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE stg_scopus_parse_references(input_xml XML)
  LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO stg_scopus_references(scp, ref_sgr, citation_text)
  SELECT
    xmltable.scp AS scp, xmltable.ref_sgr AS ref_sgr,
    max(COALESCE(xmltable.ref_fulltext, xmltable.ref_text)) AS citation_text
    FROM
      XMLTABLE('//bibrecord/tail/bibliography/reference' PASSING input_xml COLUMNS --
        scp BIGINT PATH '//itemidlist/itemid[@idtype="SCP"]/text()', --
        ref_sgr BIGINT PATH 'ref-info/refd-itemidlist/itemid[@idtype="SGR"]/text()',
        /* This should work around situations where additional tags are included in the text field (e.g. a <br/> tag).
        Otherwise, would encounter a "more than one value returned by column XPath expression" error. */
        ref_fulltext TEXT PATH 'ref-fulltext/text()[1]', --
        ref_text TEXT PATH 'ref-info/ref-text/text()[1]')
   GROUP BY scp, ref_sgr;
END; $$