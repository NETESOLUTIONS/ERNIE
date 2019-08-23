\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE scopus_parse_authors_and_affiliations(scopus_doc_xml xml)
    language plpgsql
AS
$$
BEGIN
    INSERT INTO scopus_authors(scp, author_seq, auid, author_indexed_name, author_surname, author_given_name,
                               author_initials, author_e_address, author_rank)    -- scopus_authors
    SELECT DISTINCT scp,
                    author_seq,
                    max(auid) as auid,
                    max(author_indexed_name) as author_indexed_name,
                    author_surname,
                    max(author_given_name) as author_given,
                    max(author_initials) as author_initials,
                    max(author_e_address) as author_e_address,
                    ROW_NUMBER()
                    over (PARTITION BY scp ORDER BY author_seq, author_surname, author_indexed_name)  as author_rank
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
                     author_e_address TEXT PATH 'ce:e-address' )
GROUP BY scp, author_seq, author_surname
ON CONFLICT (scp, author_seq) DO UPDATE SET auid=excluded.auid,
                                        author_surname=excluded.author_surname,
                                        author_indexed_name=excluded.author_indexed_name, 
                                        author_given_name=excluded.author_given_name,
                                        author_initials=excluded.author_initials,
                                        author_e_address=excluded.author_e_address,
                                        authro_rank=excluded.author_rank;

    -- scopus_affiliations
    INSERT INTO scopus_affiliations(scp, affiliation_no, afid, dptid, city_group, state, postal_code, country_code,
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
             )
    ON CONFLICT (scp, affiliation_no) DO UPDATE SET scp=excluded.scp,
                                                    affiliation_no=excluded.affiliation_no,
                                                    afid=excluded.afid,
                                                    dptid=excluded.dptid,
                                                    city_group=excluded.city_group,
                                                    state=excluded.state,
                                                    postal_code=excluded.postal_code,
                                                    country_code=excluded.country_code,
                                                    country=excluded.country;

    UPDATE scopus_affiliations sa
    SET organization=sq.organization
    FROM (
             SELECT scp, affiliation_no, RTRIM(organization, ',') AS organization
             FROM xmltable(--
                          '//bibrecord/head/author-group/affiliation' PASSING scopus_doc_xml COLUMNS --
                         scp BIGINT PATH '../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
                         affiliation_no FOR ORDINALITY,
                         organization TEXT PATH 'concat(organization[1]/text(), ",",organization[2]/text(), ",",organization[3]/text())'
                      )
         ) as sq
    WHERE sa.scp = sq.scp
      and sa.affiliation_no = sq.affiliation_no;

    -- scopus_author_affiliations
    INSERT INTO scopus_author_affiliations(scp, author_seq, affiliation_no)
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
    WHERE XMLEXISTS('//bibrecord/head/author-group/affiliation' PASSING scopus_doc_xml)
    ON CONFLICT (scp, author_seq, affiliation_no) DO UPDATE SET author_seq=excluded.author_seq,
                                                                affiliation_no=excluded.affiliation_no;

END;
$$;
