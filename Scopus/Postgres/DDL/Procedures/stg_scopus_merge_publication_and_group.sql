\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE stg_scopus_merge_publication_and_group()
    LANGUAGE plpgsql AS
$$
BEGIN
    INSERT INTO scopus_publication_groups(sgr, pub_year)
    SELECT DISTINCT sgr, pub_year
    FROM stg_scopus_publication_groups
    ON CONFLICT (sgr) DO UPDATE SET pub_year=excluded.pub_year;

    DELETE FROM scopus_publications scp USING stg_scopus_publications stg WHERE scp.scp = stg.scp;

    INSERT INTO scopus_publications(scp, sgr, correspondence_person_indexed_name, correspondence_city,
                                    correspondence_country, correspondence_e_address, pub_type, citation_type,
                                    citation_language, process_stage, state, date_sort, ernie_source_id)
    SELECT stg_scopus_publications.scp,
           max(sgr)                                                               AS sgr,
           max(correspondence_person_indexed_name)                                AS correspondence_person_indexed_name,
           max(correspondence_city)                                               AS correspondence_city,
           max(correspondence_country)                                            AS correspondence_country,
           max(correspondence_e_address)                                          AS correspondence_e_address,
           max(pub_type)                                                          as pub_type,
           max(citation_type)                                                     AS citation_type,
           max(regexp_replace(citation_language, '([a-z])([A-Z])', '\1,\2', 'g')) AS citation_language,
           max(process_stage)                                                     as process_stage,
           max(state)                                                             as state,
           max(date_sort)                                                         as date_sort,
           stg_scopus_publications.ernie_source_id
    FROM stg_scopus_publications
           INNER JOIN  scopus_sources ON scopus_sources.ernie_source_id = stg_scopus_publications.ernie_source_id
    GROUP BY scp, stg_scopus_publications.ernie_source_id
    ON CONFLICT (scp) DO UPDATE SET sgr=excluded.sgr,
                                    correspondence_person_indexed_name=excluded.correspondence_person_indexed_name,
                                    correspondence_city=excluded.correspondence_city,
                                    correspondence_country=excluded.correspondence_country,
                                    correspondence_e_address=excluded.correspondence_e_address,
                                    pub_type= excluded.pub_type,
                                    citation_type=excluded.citation_type,
                                    citation_language=excluded.citation_language,
                                    ernie_source_id=excluded.ernie_source_id;
END;
$$;