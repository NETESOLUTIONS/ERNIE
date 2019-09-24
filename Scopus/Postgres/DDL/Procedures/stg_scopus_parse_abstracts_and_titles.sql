\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

create or replace procedure stg_scopus_parse_abstracts_and_titles(scopus_doc_xml xml)
    language plpgsql
as
$$
BEGIN
    -- scopus_abstracts
    INSERT INTO stg_scopus_abstracts(scp, abstract_language, abstract_source)
    SELECT DISTINCT scp,
           abstract_language,
           abstract_source
    FROM xmltable(
                 XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
                 '//bibrecord/head/abstracts/abstract/ce:para' PASSING scopus_doc_xml COLUMNS
                     scp BIGINT PATH '../../../../item-info/itemidlist/itemid[@idtype="SCP"]',
--         abstract_text TEXT PATH 'normalize-space()',
                     abstract_language TEXT PATH '../@xml:lang',
                     abstract_source TEXT PATH '../@source'
             );

    -- scopus_titles
    INSERT INTO stg_scopus_titles(scp, title, language)
    SELECT scp,
           max(title) as title,
           max(language) as language
    FROM xmltable(
                 XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
                 '//bibrecord/head/citation-title/titletext' PASSING scopus_doc_xml COLUMNS
                     scp BIGINT PATH '../../../item-info/itemidlist/itemid[@idtype="SCP"]',
                     title TEXT PATH 'normalize-space()',
                     language TEXT PATH '@language'
             )
    GROUP BY scp;
END;
$$;

