/*
 Title: Scopus-parser for citation_language
 Author: Djamil Lakhdar-Hamina
 Date: 06/20/2019
 Purpose: We were missing a field for citation_language for scopus data.

 */

 --set search_path to djamil; (for testing)
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
<<<<<<< HEAD
       string_agg(citation_language, ",")
    FROM xmltable('//citation-info//citation-language' PASSING input_xml COLUMNS
        scp BIGINT PATH '//bibrecord/item-info/itemidlist/itemid[@idtype="SCP"]'
        citation_language TEXT PATH '@language')
=======
       citation_language
    FROM xmltable('//itemidlist' PASSING scopus_doc_xml COLUMNS
        scp BIGINT PATH 'itemid[@idtype="SCP"]',
        citation_language TEXT PATH '//citation-language/@language')
>>>>>>> 2fb71abe7c6d64b6ffd1bcc14342d97e812620f7
    ON CONFLICT (scp) DO UPDATE SET citation_language=excluded.citation_language;
END ;
$$
language plpgsql;
