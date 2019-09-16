set search_path=':';
\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

create or replace procedure stg_scopus_merge_authors_and_affiliations()
    language plpgsql
as
$$
BEGIN
    insert into scopus_authors(scp, author_seq, auid, author_indexed_name, author_surname, author_given_name,
                               author_initials, author_e_address, author_rank)
    SELECT scp,
           author_seq,
           auid,
           author_indexed_name,
           max(author_surname)    as author_surname,
            max(author_given_name) as author_given_name,
                max(author_initials)   as author_initials,
                max(author_e_address)  as author_e_address,
                ROW_NUMBER() over (PARTITION BY scp ORDER BY author_seq, author_indexed_name) as author_rank
    FROM stg_scopus_authors stg
        GROUP BY scp, author_seq, auid, author_indexed_name

    ON CONFLICT (scp, author_seq) DO UPDATE SET auid=excluded.auid,
                                                author_surname=excluded.author_surname,
                                                author_given_name=excluded.author_given_name,
                                                author_indexed_name=excluded.author_indexed_name,
                                                author_initials=excluded.author_initials,
                                                author_e_address=excluded.author_e_address,
                                                author_rank=excluded.author_rank;
    -- scopus_affiliations
---------------------------------------
    insert into scopus_affiliations(scp, affiliation_no, afid, dptid, city_group, state, postal_code, country_code,
                                    country)
    SELECT scp,
           affiliation_no,
           afid,
           dptid,
           city_group,
           state,
           postal_code,
           country_code,
           country
    FROM stg_scopus_affiliations
    ON CONFLICT (scp, affiliation_no) DO UPDATE SET scp=excluded.scp,
                                                    affiliation_no=excluded.affiliation_no,
                                                    afid=excluded.afid,
                                                    dptid=excluded.dptid,
                                                    city_group=excluded.city_group,
                                                    state=excluded.state,
                                                    postal_code=excluded.postal_code,
                                                    country_code=excluded.country_code,
                                                    country=excluded.country;
--------------------------------------------
    insert into scopus_author_affiliations(scp, author_seq, affiliation_no)
    select distinct scp,
           author_seq,
           affiliation_no
    from stg_scopus_author_affiliations
    ON CONFLICT (scp, author_seq, affiliation_no) DO UPDATE SET author_seq=excluded.author_seq,
                                                                affiliation_no=excluded.affiliation_no;
END
$$;