CREATE OR REPLACE PROCEDURE scopus_parse_authors_and_affiliations(scopus_doc_xml XML)
AS
$$
BEGIN
    -- scopus_authors
    INSERT INTO scopus_authors(scp, author_seq, auid, author_indexed_name, author_surname, author_given_name,
                               author_initials, author_e_address)
    SELECT DISTINCT scp,
           author_seq,
           auid,
           author_indexed_name,
           author_surname,
           author_given_name,
           author_initials,
           author_e_address
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
    ON CONFLICT (scp, author_seq) DO UPDATE SET auid=excluded.auid,
                                                author_surname=excluded.author_surname,
                                                author_given_name=excluded.author_given_name,
                                                author_initials=excluded.author_initials,
                                                author_e_address=excluded.author_e_address;

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
             SELECT scp, string_agg(organization, ',') AS organization
             FROM xmltable(--
                          '//bibrecord/head/author-group/affiliation/organization' PASSING scopus_doc_xml COLUMNS --
                         scp BIGINT PATH '../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
                         organization TEXT PATH 'normalize-space()'
                      )
             GROUP BY scp
         ) as sq
    WHERE sa.scp = sq.scp;


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
    ON CONFLICT (scp, author_seq, affiliation_no) DO UPDATE SET author_seq=excluded.author_seq, affiliation_no=excluded.affiliation_no;

END;
$$
    LANGUAGE plpgsql;
