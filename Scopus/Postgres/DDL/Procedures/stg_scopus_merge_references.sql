\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

create or replace procedure stg_scopus_merge_references()
    language plpgsql
as
$$
BEGIN
INSERT INTO scopus_references(scp, ref_sgr, citation_text)
SELECT DISTINCT scp,
       ref_sgr,
       citation_text
FROM stg_scopus_references
ON CONFLICT (scp, ref_sgr) DO UPDATE SET citation_text=excluded.citation_text;
END
$$;