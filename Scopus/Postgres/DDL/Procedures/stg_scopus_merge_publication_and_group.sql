\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE stg_scopus_merge_publication_and_group()
  LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO scopus_publication_groups(sgr, pub_year)
  SELECT DISTINCT sgr, pub_year
    FROM stg_scopus_publication_groups
      ON CONFLICT (sgr) DO UPDATE SET pub_year=excluded.pub_year;

  DELETE FROM scopus_publications scp USING stg_scopus_publications stg WHERE scp.scp = stg.scp;

  INSERT INTO scopus_publications(scp, sgr, correspondence_person_indexed_name, correspondence_city,
                                  correspondence_country, correspondence_e_address, citation_type, citation_language)
  SELECT
    scp, max(sgr) AS sgr, max(correspondence_person_indexed_name) AS correspondence_person_indexed_name,
    max(correspondence_city) AS correspondence_city, max(correspondence_country) AS correspondence_country,
    max(correspondence_e_address) AS correspondence_e_address, max(citation_type) AS citation_type,
    max(regexp_replace(citation_language, '([a-z])([A-Z])', '\1,\2', 'g')) AS citation_language
    FROM stg_scopus_publications
   GROUP BY scp
      ON CONFLICT (scp) DO UPDATE SET sgr=excluded.sgr,
        correspondence_person_indexed_name=excluded.correspondence_person_indexed_name,
        correspondence_city=excluded.correspondence_city,
        correspondence_country=excluded.correspondence_country,
        correspondence_e_address=excluded.correspondence_e_address,
        citation_type=excluded.citation_type,
        citation_language=excluded.citation_language;
END $$;