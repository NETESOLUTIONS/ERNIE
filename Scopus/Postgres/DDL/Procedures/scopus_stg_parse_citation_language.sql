set search_path = ':';
\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE stg_scopus_parse_citation_language(scopus_doc_xml XML)
AS
$$
BEGIN
    INSERT INTO stg_scopus_publications(scp, citation_language)
    SELECT
       scp,
       string_agg(citation_language, ',') as citation_language
      FROM xmltable('//bibrecord/head/citation-info/citation-language' PASSING scopus_doc_xml COLUMNS
        scp BIGINT PATH '//bibrecord/item-info/itemidlist/itemid[@idtype="SCP"]',
        citation_language TEXT PATH '@language')
    GROUP BY scp
    ;
END ;
$$
language plpgsql;
