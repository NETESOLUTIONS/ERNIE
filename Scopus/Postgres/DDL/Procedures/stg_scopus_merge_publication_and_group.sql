\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

create or replace procedure stg_scopus_merge_publication_and_group()
    language plpgsql
as
$$
BEGIN
    INSERT INTO scopus_publication_groups(sgr, pub_year)
    SELECT DISTINCT sgr,
                    pub_year
    FROM stg_scopus_publication_groups
    ON CONFLICT (sgr) DO UPDATE
        SET pub_year=excluded.pub_year;

    INSERT INTO scopus_publications(scp, sgr, correspondence_person_indexed_name, correspondence_city,
                                    correspondence_country, correspondence_e_address, citation_type, citation_language)
    SELECT scp,
           max(sgr)                                                               as sgr,
           max(correspondence_person_indexed_name)                                as correspondence_person_indexed_name,
           max(correspondence_city)                                               as correspondence_city,
           max(correspondence_country)                                            as correspondence_country,
           max(correspondence_e_address)                                          as correspondence_e_address,
           max(citation_type)                                                     as citation_type,
           max(regexp_replace(citation_language, '([a-z])([A-Z])', '\1,\2', 'g')) as citation_language
    FROM stg_scopus_publications
    GROUP BY scp
    ON CONFLICT (scp) DO UPDATE SET sgr=excluded.sgr,
                                    correspondence_person_indexed_name=excluded.correspondence_person_indexed_name,
                                    correspondence_city=excluded.correspondence_city,
                                    correspondence_country=excluded.correspondence_country,
                                    correspondence_e_address=excluded.correspondence_e_address,
                                    citation_type=excluded.citation_type,
                                    citation_language=excluded.citation_language;

    DELETE FROM scopus_publications scp USING stg_scopus_publications stg where scp.scp = stg.scp;
END
$$;