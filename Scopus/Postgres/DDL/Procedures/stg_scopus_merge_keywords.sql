\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE stg_scopus_merge_keywords()
    LANGUAGE plpgsql AS
$$
BEGIN
    INSERT INTO scopus_keywords(scp, keyword)
    SELECT DISTINCT scopus_publications.scp, keyword
    FROM stg_scopus_keywords,
         scopus_publications
    where stg_scopus_keywords.scp = scopus_publications.scp
    ON CONFLICT (scp, keyword) DO UPDATE SET keyword=excluded.keyword;
END
$$;
