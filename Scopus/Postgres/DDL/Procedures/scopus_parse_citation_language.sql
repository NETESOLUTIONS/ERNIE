/*
 Title: Scopus-parser for citation_language
 Author: Djamil Lakhdar-Hamina
 Date: 06/20/2019
 Purpose: We were missing a field for citation_language for scopus data.

 */

set search_path to public; 
\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE scopus_parse_citation_language(scopus_doc_xml XML)
AS
$$
BEGIN
    INSERT INTO scopus_publications(scp, citation_language)
    SELECT
       scp,
       string_agg(citation_language, ",") as citation_language
      FROM xmltable('//bibrecord/head/citation-info/citation-language' PASSING scopus_doc_xml COLUMNS
        scp BIGINT PATH '//bibrecord/item-info/itemidlist/itemid[@idtype="SCP"]',
        citation_language TEXT PATH '@language')
    GROUP BY scp
    ON CONFLICT (scp) DO UPDATE SET citation_language=excluded.citation_language;
END ;
$$
language plpgsql;
