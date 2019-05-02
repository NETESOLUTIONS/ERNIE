\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE scopus_parse_publication(scopus_doc_xml XML)
AS
$$
  DECLARE
    db_id INTEGER;
    cur RECORD;
  BEGIN
      INSERT INTO scopus_sources(source_id, issn_main, isbn_main, source_type, source_title,
                                   coden_code, publisher_name,publisher_e_address,pub_date)
      SELECT DISTINCT
       coalesce(source_id,'') as source_id,
       coalesce(issn,'') as issn_main,
       coalesce(isbn,'') as isbn_main,
       source_type,
       source_title,
       coden_code,
       publisher_name,
       publisher_e_address,
       make_date(pub_year, pub_month, pub_day) AS pub_date
      FROM xmltable(--
        XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
        '//bibrecord/head/source' PASSING scopus_doc_xml COLUMNS --
        --@formatter:off
        source_id TEXT PATH '@srcid',
        issn TEXT PATH 'issn[1]',
        isbn TEXT PATH 'isbn[1]',
        source_type TEXT PATH '@type',
        source_title TEXT PATH 'sourcetitle',
        coden_code TEXT PATH 'codencode',
        publisher_name TEXT PATH 'publisher/publishername',
        publisher_e_address TEXT PATH 'publisher/ce:e-address',
        pub_year SMALLINT PATH 'publicationdate/year', --
        pub_month SMALLINT PATH 'publicationdate/month', --
        pub_day SMALLINT PATH 'publicationdate/day' --
        )
      WHERE source_id != '' OR issn !='' OR XMLEXISTS('//bibrecord/head/source/isbn' PASSING scopus_doc_xml)
      ON CONFLICT (source_id, issn_main, isbn_main)
      DO UPDATE
        SET source_id = EXCLUDED.source_id,
            issn_main = EXCLUDED.issn_main,
            isbn_main = EXCLUDED.isbn_main,
            source_type = EXCLUDED.source_type,
            source_title = EXCLUDED.source_title,
            coden_code = EXCLUDED.coden_code,
            publisher_name = EXCLUDED.publisher_name,
            publisher_e_address = EXCLUDED.publisher_e_address,
            pub_date=EXCLUDED.pub_date
      RETURNING ernie_source_id INTO db_id;

      UPDATE scopus_sources ss
      SET website=sq.website
      FROM (
           SELECT
            db_id as ernie_source_id,
            string_agg(website, ',') AS website
           FROM
           xmltable(--
           XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
           '//bibrecord/head/source/website/ce:e-address' PASSING scopus_doc_xml COLUMNS --
           website TEXT PATH 'normalize-space()'
           )
           GROUP BY ernie_source_id
           ) as sq
      WHERE ss.ernie_source_id=sq.ernie_source_id;

      -- scopus_isbns
      INSERT INTO scopus_isbns(ernie_source_id,isbn,isbn_length,isbn_type,isbn_level)

      SELECT
        db_id AS ernie_source_id,
        isbn,
        isbn_length,
        isbn_type,
        isbn_level
      FROM
        xmltable(--
        '//bibrecord/head/source/isbn' PASSING scopus_doc_xml COLUMNS --
        isbn TEXT PATH '.',
        isbn_length SMALLINT PATH '@length',
        isbn_type TEXT PATH '@type',
        isbn_level TEXT PATH'@level'
        )
      ON CONFLICT DO NOTHING;

      -- scopus_issns
      INSERT INTO scopus_issns(ernie_source_id,issn,issn_type)

      SELECT
        db_id AS ernie_source_id,
        issn,
        coalesce(issn_type,'') as issn_type
      FROM
        xmltable(--
        '//bibrecord/head/source/issn' PASSING scopus_doc_xml COLUMNS --
        issn TEXT PATH '.',
        issn_type TEXT PATH '@type'
        )
      ON CONFLICT DO NOTHING;

    -- scopus_publication_groups, scopus_publications attributes
    FOR cur IN (
      SELECT sgr,
             pub_year,
--              make_date(pub_year, pub_month, pub_day) AS pub_date,
             scp,
             correspondence_person_indexed_name,
             correspondence_city,
             correspondence_country,
             correspondence_e_address,
             citation_type
      FROM xmltable(--
      -- The `xml:` namespace doesn't need to be specified
               XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
               '//bibrecord' PASSING scopus_doc_xml COLUMNS --
                 sgr BIGINT PATH 'item-info/itemidlist/itemid[@idtype="SGR"]', --
                 pub_year SMALLINT PATH 'head/source/publicationyear/@first', --
                 scp BIGINT PATH 'item-info/itemidlist/itemid[@idtype="SCP"]', --
            -- noramlize-space() converts NULLs to empty strings
                 correspondence_person_indexed_name TEXT PATH 'head/correspondence/person/ce:indexed-name', --
                 correspondence_city TEXT PATH 'head/correspondence/affiliation/city', --
                 correspondence_country TEXT PATH 'head/correspondence/affiliation/country', --
                 correspondence_e_address TEXT PATH 'head/correspondence/ce:e-address',
                 citation_type TEXT PATH 'head/citation-info/citation-type/@code')
    )
      LOOP
        INSERT INTO scopus_publication_groups(sgr, pub_year)
        VALUES (cur.sgr, cur.pub_year)
        ON CONFLICT DO NOTHING;

        INSERT INTO scopus_publications(scp, sgr, correspondence_person_indexed_name, correspondence_city,
                                        correspondence_country, correspondence_e_address, citation_type)
        VALUES (cur.scp, cur.sgr, cur.correspondence_person_indexed_name, cur.correspondence_city,
                cur.correspondence_country, cur.correspondence_e_address, cur.citation_type)
        ON CONFLICT DO NOTHING;
      END LOOP;

    -- scopus_publications: concatenated correspondence organizations
    WITH cte AS (
      SELECT scp, string_agg(organization, chr(10)) AS correspondence_orgs
      FROM xmltable(--
               XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
               '//bibrecord/head/correspondence/affiliation/organization' PASSING scopus_doc_xml COLUMNS --
          --@formatter:off
                 scp BIGINT PATH '../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
                 organization TEXT PATH 'normalize-space()'
             --@formatter:on
             )
      GROUP BY scp
    )
    UPDATE scopus_publications sp
    SET correspondence_orgs = cte.correspondence_orgs
    FROM cte
    WHERE sp.scp = cte.scp;

    UPDATE scopus_publications sp
    SET pub_type      = singular.pub_type,
        process_stage = singular.process_stage,
        state         = singular.state,
        date_sort     = singular.date_sort,
        ernie_source_id     = singular.ernie_source_id
    FROM (
           SELECT scp,
                  pub_type,
                  process_stage,
                  state,
                  make_date(sort_year, CASE WHEN sort_month NOT BETWEEN 1 AND 12 THEN 01 ELSE sort_month END,
                            CASE WHEN sort_day NOT BETWEEN 1 AND 31 THEN 01 ELSE sort_day END) AS date_sort,
                  db_id as ernie_source_id
           FROM xmltable(--
                    XMLNAMESPACES ('http://www.elsevier.com/xml/ani/ait' AS ait), --
                    '//ait:process-info' PASSING scopus_doc_xml COLUMNS --
                      scp BIGINT PATH '//bibrecord/item-info/itemidlist/itemid[@idtype="SCP"]',
                      pub_type TEXT PATH 'ait:status/@type',
                      process_stage TEXT PATH 'ait:status/@stage',
                      state TEXT PATH 'ait:status/@state',
                      sort_year SMALLINT PATH 'ait:date-sort/@year',
                      sort_month SMALLINT PATH 'ait:date-sort/@month',
                      sort_day SMALLINT PATH 'ait:date-sort/@day'
                  )
         ) AS singular
    WHERE sp.scp = singular.scp;

   -- scopus_conference_events
    INSERT INTO scopus_conference_events(conf_code, conf_name, conf_address,conf_city, conf_postal_code, conf_start_date,
                                    conf_end_date, conf_number, conf_catalog_number)

    SELECT
      coalesce(conf_code,'') AS conf_code,
      coalesce(conf_name,'') AS conf_name,
      conf_address,
      conf_city,
      conf_postal_code,
      make_date(s_year, s_month, s_day) AS conf_start_date,
      make_date(e_year, e_month, e_day) AS conf_end_date,
      conf_number,
      conf_catalog_number
    FROM
      xmltable(--
      '//bibrecord/head/source' PASSING scopus_doc_xml COLUMNS --
      conf_code TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/confcode',
      conf_name TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/confname',
      conf_address TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/conflocation/address-part',
      conf_city TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/conflocation/city-group',
      conf_postal_code TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/conflocation/postal-code',
      s_year SMALLINT PATH 'additional-srcinfo/conferenceinfo/confevent/confdate/startdate/@year',
      s_month SMALLINT PATH 'additional-srcinfo/conferenceinfo/confevent/confdate/startdate/@month',
      s_day SMALLINT PATH 'additional-srcinfo/conferenceinfo/confevent/confdate/startdate/@day',
      e_year SMALLINT PATH 'additional-srcinfo/conferenceinfo/confevent/confdate/enddate/@year',
      e_month SMALLINT PATH 'additional-srcinfo/conferenceinfo/confevent/confdate/enddate/@month',
      e_day SMALLINT PATH 'additional-srcinfo/conferenceinfo/confevent/confdate/enddate/@day',
      conf_number TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/confnumber',
      conf_catalog_number TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/confcatnumber'
      )
    ON CONFLICT DO NOTHING;

    UPDATE scopus_conference_events sce
    SET conf_sponsor=sq.conf_sponsor
    FROM (
         SELECT
          coalesce(conf_code, '') AS conf_code,
          coalesce(conf_name,'') AS conf_name,
          string_agg(conf_sponsor,',') AS conf_sponsor
         FROM xmltable(--
         '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confevent/confsponsors/confsponsor' PASSING scopus_doc_xml COLUMNS --
         conf_code TEXT PATH '../../confcode',
         conf_name TEXT PATH '../../confname',
         conf_sponsor TEXT PATH 'normalize-space()'
         )
         GROUP BY conf_code, conf_name
         ) as sq
    WHERE sce.conf_code=sq.conf_code AND sce.conf_name=sq.conf_name;

    -- scopus_conf_proceedings
    INSERT INTO scopus_conf_proceedings(ernie_source_id,conf_code,conf_name,proc_part_no,proc_page_range,proc_page_count)

    SELECT
      db_id AS ernie_source_id,
      coalesce(conf_code,'') AS conf_code,
      coalesce(conf_name,'') AS conf_name,
      proc_part_no,
      proc_page_range,
      CASE
        WHEN proc_page_count LIKE '%p' THEN RTRIM(proc_page_count, 'p') :: SMALLINT
        WHEN proc_page_count LIKE '%p.' THEN RTRIM(proc_page_count, 'p.') :: SMALLINT
        WHEN proc_page_count ~ '[^0-9]' THEN NULL
        ELSE proc_page_count :: SMALLINT
      END
    FROM
      xmltable(--
      '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication' PASSING scopus_doc_xml COLUMNS --
      conf_code TEXT PATH 'preceding-sibling::confevent/confcode',
      conf_name TEXT PATH 'preceding-sibling::confevent/confname',
      proc_part_no TEXT PATH 'procpartno',
      proc_page_range TEXT PATH 'procpagerange',
      proc_page_count TEXT PATH 'procpagecount'
      )
    WHERE proc_part_no IS NOT NULL OR proc_page_range IS NOT NULL or proc_page_count IS NOT NULL
    ON CONFLICT DO NOTHING;

    -- scopus_conf_editors
    INSERT INTO scopus_conf_editors(ernie_source_id,conf_code,conf_name,indexed_name,role_type,
                                    initials,surname,given_name,degree,suffix)
    SELECT
      db_id as ernie_source_id,
      coalesce(conf_code,'') AS conf_code,
      coalesce(conf_name,'') AS conf_name,
      coalesce(indexed_name,'') AS indexed_name,
      coalesce(edit_role, edit_type) AS role_type,
      initials,
      surname,
      given_name,
      degree,
      suffix
    FROM
      xmltable(--
      XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
      '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication/confeditors/editors/editor' PASSING scopus_doc_xml COLUMNS --
      conf_code TEXT PATH '../../../preceding-sibling::confevent/confcode',
      conf_name TEXT PATH '../../../preceding-sibling::confevent/confname',
      indexed_name TEXT PATH 'ce:indexed-name',
      edit_role TEXT PATH '@role',
      edit_type TEXT PATH '@type',
      initials TEXT PATH 'initials',
      surname TEXT PATH 'ce:surname',
      given_name TEXT PATH 'ce:given-name',
      degree TEXT PATH 'ce:degrees',
      suffix TEXT PATH 'ce:suffix'
      )
    WHERE db_id IS NOT NULL
    ON CONFLICT DO NOTHING;

    UPDATE scopus_conf_editors sed
    SET address=sq.address
    FROM (
         SELECT
          db_id AS ernie_source_id,
          coalesce(conf_code,'') AS conf_code,
          coalesce(conf_name,'') AS conf_name,
          string_agg(address, ',') AS address
         FROM
         xmltable(--
         '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication/confeditors/editoraddress' PASSING scopus_doc_xml COLUMNS --
         conf_code TEXT PATH '../../preceding-sibling::confevent/confcode',
         conf_name TEXT PATH '../../preceding-sibling::confevent/confname',
         address TEXT PATH 'normalize-space()'
         )
         GROUP BY db_id,conf_code, conf_name
         ) as sq
    WHERE sed.ernie_source_id=sq.ernie_source_id AND sed.conf_code=sq.conf_code AND sed.conf_name=sq.conf_name;

    UPDATE scopus_conf_editors sed
    SET organization=sq.organization
    FROM (
         SELECT
          db_id AS ernie_source_id,
          coalesce(conf_code,'') AS conf_code,
          coalesce(conf_name,'') AS conf_name,
          string_agg(organization, ',') AS organization
         FROM
         xmltable(--
         '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication/confeditors/editororganization' PASSING scopus_doc_xml COLUMNS --
         conf_code TEXT PATH '../../preceding-sibling::confevent/confcode',
         conf_name TEXT PATH '../../preceding-sibling::confevent/confname',
         organization TEXT PATH 'normalize-space()'
         )
         GROUP BY db_id,conf_code, conf_name
         ) as sq
    WHERE sed.ernie_source_id=sq.ernie_source_id AND sed.conf_code=sq.conf_code AND sed.conf_name=sq.conf_name;
  END;
$$
  LANGUAGE plpgsql;
