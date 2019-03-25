\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- author information
CREATE OR REPLACE PROCEDURE update_scopus_author_affiliations(scopus_doc_xml XML)
AS $$
  BEGIN
    -- scopus_pub_authors
    INSERT INTO scopus_authors(scp, author_seq, auid, author_indexed_name, author_surname, author_given_name,
                                   author_initials, author_e_address)
    SELECT
      scp,
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
    ON CONFLICT DO NOTHING;

    -- scopus_auth_affiliations
    INSERT INTO scopus_affiliations(scp, affiliation_no, afid, dptid, city_group, state, postal_code, country_code, country)

    SELECT
      scp, 
      affiliation_no, 
      afid,
      dptid,
      CASE
          WHEN coalesce(city_group) IS NOT NULL THEN city_group
          ELSE city
      END AS city_group,
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
    ON CONFLICT DO NOTHING;

    UPDATE scopus_affiliations sa
    SET organization=temp1.organization
    FROM (
         SELECT scp, string_agg(organization, ',') AS organization
         FROM xmltable(--
         '//bibrecord/head/author-group/affiliation/organization' PASSING scopus_doc_xml COLUMNS --
         scp BIGINT PATH '../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
         organization TEXT PATH 'normalize-space()'
         )
         GROUP BY scp
         )as temp1
    WHERE sa.scp=temp1.scp;


    -- scopus_auth_affiliation_mapping
    INSERT INTO scopus_affiliation_mapping(scp, author_seq,affiliation_no)
    SELECT
      t1.scp,
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
    ON CONFLICT DO NOTHING;

  END;
  $$
  LANGUAGE plpgsql;