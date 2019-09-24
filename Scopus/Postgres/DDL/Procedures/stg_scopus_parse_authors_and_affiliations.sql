\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
create procedure stg_scopus_parse_authors_and_affiliations(scopus_doc_xml xml)
    language plpgsql
as
$$
BEGIN
    -- scopus_authors

    INSERT INTO stg_scopus_authors(scp, author_seq, auid, author_indexed_name, author_surname, author_given_name,
                               author_initials, author_e_address, author_rank)
                SELECT DISTINCT ON (scp, author_seq, auid)
                scp,
                author_seq,
                auid,
                author_indexed_name,
                max(author_surname)    as author_surname,
                max(author_given_name) as author_given_name,
                max(author_initials)   as author_initials,
                max(author_e_address)  as author_e_address,
                ROW_NUMBER() over (PARTITION BY scp ORDER BY author_seq, author_indexed_name) as author_rank
                FROM xmltable(--
                  XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
                '//bibrecord/head/author-group/author' PASSING scopus_doc_xml COLUMNS --
                  --@formatter:off
                  scp BIGINT PATH '../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
                  author_seq SMALLINT PATH '@seq',
                  auid BIGINT PATH '@auid',
                  author_indexed_name TEXT PATH 'ce:indexed-name',
                  author_surname TEXT PATH 'ce:surname',
                  author_given_name TEXT PATH 'ce:given-name',
                  author_initials TEXT PATH 'ce:initials',
                  author_e_address TEXT PATH 'ce:e-address'
                          --@formatter:on
                          )
                GROUP BY scp, author_seq, auid, author_indexed_name;
                                                                  COMMIT;
    -- scopus_affiliations
INSERT INTO stg_scopus_affiliations(scp, affiliation_no, afid, dptid, city_group, state, postal_code, country_code,
                                    country)

    SELECT scp,
           affiliation_no,
           afid,
           dptid,
           coalesce(city_group, city) AS city_group,
           state,
           postal_code,
           country_code,
           country
    FROM xmltable(--
                 '//bibrecord/head/author-group/affiliation' PASSING scopus_doc_xml COLUMNS
                scp BIGINT PATH '../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
                affiliation_no FOR ORDINALITY,
                afid BIGINT PATH '@afid',
                dptid BIGINT PATH '@dptid',
                city_group TEXT PATH 'city-group',
                state TEXT PATH 'state',
                postal_code TEXT PATH 'postal-code',
                city TEXT PATH 'city',
                country_code TEXT PATH '@country',
                country TEXT PATH 'country'
             );


    -- scopus_author_affiliations
    INSERT INTO stg_scopus_author_affiliations(scp, author_seq, affiliation_no)
    SELECT DISTINCT t1.scp,
           t1.author_seq,
           t2.affiliation_no
    FROM xmltable(--
                 '//bibrecord/head/author-group/author' PASSING scopus_doc_xml COLUMNS --
                scp BIGINT PATH '../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
                author_seq SMALLINT PATH '@seq'
             ) as t1,
         xmltable(--
                 '//bibrecord/head/author-group/affiliation' PASSING scopus_doc_xml COLUMNS --
             affiliation_no FOR ORDINALITY
             ) as t2
    WHERE XMLEXISTS('//bibrecord/head/author-group/affiliation' PASSING scopus_doc_xml);
END;
$$;