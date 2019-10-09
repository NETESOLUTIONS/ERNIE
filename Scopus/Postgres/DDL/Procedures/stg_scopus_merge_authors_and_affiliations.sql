\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- TODO JOINs to scopus_publications look unnecessary
CREATE OR REPLACE PROCEDURE stg_scopus_merge_authors_and_affiliations()
  LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO scopus_authors(scp, author_seq, auid, author_indexed_name, author_surname, author_given_name,
                             author_initials, author_e_address, author_rank)
  SELECT
    scopus_publications.scp, author_seq, auid, author_indexed_name, max(author_surname) AS author_surname,
    max(author_given_name) AS author_given_name, max(author_initials) AS author_initials,
    max(author_e_address) AS author_e_address,
        ROW_NUMBER() OVER (PARTITION BY scopus_publications.scp ORDER BY author_seq, author_indexed_name) AS author_rank
    FROM stg_scopus_authors stg, scopus_publications
   WHERE stg.scp = scopus_publications.scp
   GROUP BY scopus_publications.scp, author_seq, auid, author_indexed_name
      ON CONFLICT (scp, author_seq) DO UPDATE SET auid=excluded.auid,
        author_surname=excluded.author_surname,
        author_given_name=excluded.author_given_name,
        author_indexed_name=excluded.author_indexed_name,
        author_initials=excluded.author_initials,
        author_e_address=excluded.author_e_address,
        author_rank=excluded.author_rank;

  INSERT INTO scopus_affiliations(scp, affiliation_no, afid, dptid, organization, city_group, state, postal_code,
                                  country_code,
                                  country)
  SELECT DISTINCT
    scopus_publications.scp, affiliation_no, afid, dptid, organization, city_group, stg_scopus_affiliations.state,
    postal_code, country_code, country
    FROM stg_scopus_affiliations, scopus_publications
   WHERE stg_scopus_affiliations.scp = scopus_publications.scp
      ON CONFLICT (scp, affiliation_no) DO UPDATE SET afid=excluded.afid,
        dptid=excluded.dptid,
        city_group=excluded.city_group,
        organization=excluded.organization,
        state=excluded.state,
        postal_code=excluded.postal_code,
        country_code=excluded.country_code,
        country=excluded.country;

  -- TODO JOIN to scopus_affiliations might looks unnecessary
  INSERT INTO scopus_author_affiliations(scp, author_seq, affiliation_no)
  SELECT DISTINCT
    scopus_affiliations.scp, stg_scopus_author_affiliations.author_seq, stg_scopus_author_affiliations.affiliation_no
    FROM stg_scopus_author_affiliations, scopus_affiliations
   WHERE stg_scopus_author_affiliations.scp = scopus_affiliations.scp
      ON CONFLICT (scp, author_seq, affiliation_no) DO UPDATE SET author_seq=excluded.author_seq,
        affiliation_no=excluded.affiliation_no;
END; $$