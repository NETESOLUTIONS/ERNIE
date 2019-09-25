\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

create procedure stg_scopus_merge_keywords()
    language plpgsql
as
$$
BEGIN
INSERT INTO scopus_keywords(scp, keyword)
SELECT DISTINCT scp,
       keyword
FROM stg_scopus_keywords
ON CONFLICT (scp, keyword) DO UPDATE SET keyword=excluded.keyword;
END
$$;
