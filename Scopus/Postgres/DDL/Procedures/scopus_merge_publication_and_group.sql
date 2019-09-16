set search_path=':';
\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

create procedure stg_scopus_merge_publication_and_group()
    language plpgsql
as
$$
BEGIN
INSERT INTO scopus_publication_groups(sgr, pub_year)
SELECT sgr,
       pub_year
FROM stg_scopus_publication_groups
ON CONFLICT (sgr) DO
UPDATE
SET pub_year=excluded.pub_year;

INSERT INTO scopus_publications(scp, sgr, correspondence_person_indexed_name, correspondence_city,
                                correspondence_country, correspondence_e_address, citation_type)

SELECT scp,
       sgr,
       correspondence_person_indexed_name,
       correspondence_city,
       correspondence_country,
       correspondence_e_address,
       citation_type

FROM stg_scopus_publciations
ON CONFLICT (scp) DO UPDATE SET scp=excluded.scp,
                                sgr=excluded.sgr,
                                correspondence_person_indexed_name=excluded.correspondence_person_indexed_name,
                                correspondence_city=excluded.correspondence_city,
                                correspondence_country=excluded.correspondence_country,
                                correspondence_e_address=excluded.correspondence_e_address,
                                citation_type=excluded.citation_type;
END
$$;
