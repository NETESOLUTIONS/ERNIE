set search_path=':';
\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

create procedure stg_scopus_merge_scopus_references()
    language plpgsql
as
$$
BEGIN
INSERT INTO scopus_references(scp, ref_sgr, citation_text)
SELECT scp,
       ref_sgr,
       citation_text
FROM stg_scopus_reference
ON CONFLICT (scp, ref_sgr) DO UPDATE SET citation_text=excluded.citation_text;
END
$$;