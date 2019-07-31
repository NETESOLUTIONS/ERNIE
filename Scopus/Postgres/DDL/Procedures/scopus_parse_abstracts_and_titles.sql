\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE scopus_parse_abstracts_and_titles(scopus_doc_xml XML)
AS
$$
BEGIN
    -- scopus_abstracts
    INSERT INTO scopus_abstracts(scp, abstract_language, abstract_source)
    SELECT scp,
           abstract_language,
           abstract_source
    FROM xmltable(
                 XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
                 '//bibrecord/head/abstracts/abstract/ce:para' PASSING scopus_doc_xml COLUMNS
                     scp BIGINT PATH '../../../../item-info/itemidlist/itemid[@idtype="SCP"]',
--         abstract_text TEXT PATH 'normalize-space()',
                     abstract_language TEXT PATH '../@xml:lang',
                     abstract_source TEXT PATH '../@source'
             )
    ON CONFLICT (scp,abstract_language) DO UPDATE SET abstract_source=excluded.abstract_source;


    -- scopus_abstracts: concatenated abstract_text
    WITH sca AS (
        SELECT scp, abstract_language, string_agg(abstract_text, chr(10)) as abstract_text
        FROM xmltable(
                     XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
                     '//bibrecord/head/abstracts/abstract/ce:para' PASSING scopus_doc_xml COLUMNS
                         scp BIGINT PATH '../../../../item-info/itemidlist/itemid[@idtype="SCP"]',
                         abstract_text TEXT PATH 'normalize-space()',
                         abstract_language TEXT PATH '../@xml:lang'
                 )
        GROUP BY scp, abstract_language
    )
    UPDATE scopus_abstracts sa
    SET abstract_text=sca.abstract_text
    FROM sca
    WHERE sa.scp = sca.scp
      and sa.abstract_language = sca.abstract_language;


    -- scopus_titles
    INSERT INTO scopus_titles(scp, title, language)
    SELECT scp,
           title,
           language
    FROM xmltable(
                 XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
                 '//bibrecord/head/citation-title/titletext' PASSING scopus_doc_xml COLUMNS
                     scp BIGINT PATH '../../../item-info/itemidlist/itemid[@idtype="SCP"]',
                     title TEXT PATH 'normalize-space()',
                     language TEXT PATH '@language'
             )
    ON CONFLICT (scp, language) DO UPDATE SET  scp=excluded.scp, title=excluded.title, language =excluded.language;
END;
$$
    LANGUAGE plpgsql;
