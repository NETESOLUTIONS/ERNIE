/*
 Title: Scopus-parser for citation_language
 Author: Djamil Lakhdar-Hamina
 Date: 06/20/2019
 Purpose: We were missing a field for citation_language for scopus data.

 */

 --set search_path to djamil; (for testing)
\set ON_ERROR_STOP on
\set ECHO all
\timing

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE scopus_parser_citation_language(input_xml XML)
AS
$$
BEGIN
    INSERT INTO scopus_publications(scp, citation_language)
    SELECT
       scp,
       citation_language
    FROM xmltable('//itemidlist' PASSING input_xml COLUMNS
        scp BIGINT PATH 'itemid[@idtype="SCP"]',
        citation_language TEXT PATH '//citation-language/@language')
    ON CONFLICT (scp) DO UPDATE SET citation_language=excluded.citation_language;
END ;
$$
language plpgsql;
