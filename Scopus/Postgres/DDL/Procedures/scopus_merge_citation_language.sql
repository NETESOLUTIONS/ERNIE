set search_path = ':';
\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE stg_scopus_merge_citation_language()
AS
$$
BEGIN
    INSERT INTO scopus_publications(scp, citation_language)
    SELECT
       scp,
       string_agg(citation_language, ',') as citation_language
    GROUP BY scp
    ON CONFLICT (scp) DO UPDATE SET citation_language=excluded.citation_language;
END ;
$$
language plpgsql;
