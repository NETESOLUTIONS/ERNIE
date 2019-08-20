\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
CREATE OR REPLACE PROCEDURE scopus_parse_source_and_conferences(scopus_doc_xml XML)
    LANGUAGE plpgsql AS $$
DECLARE db_id INTEGER;
BEGIN
    BEGIN
        INSERT INTO scopus_sources(source_id, issn_main, isbn_main, source_type, source_title,
                                   coden_code, publisher_name, publisher_e_address, pub_date)
        SELECT DISTINCT coalesce(source_id, '')                 AS source_id,
                        coalesce(issn, '')                      AS issn_main,
                        coalesce(isbn, '')                      AS isbn_main,
                        source_type,
                        source_title,
                        coden_code,
                        publisher_name,
                        publisher_e_address,
                        try_parse(pub_year, pub_month, pub_day) AS pub_date
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
        WHERE source_id != ''
           OR issn != ''
           OR XMLEXISTS('//bibrecord/head/source/isbn' PASSING scopus_doc_xml)
        ON CONFLICT (source_id, issn_main, isbn_main)
            DO UPDATE
            SET source_id           = EXCLUDED.source_id,
                issn_main           = EXCLUDED.issn_main,
                isbn_main           = EXCLUDED.isbn_main,
                source_type         = EXCLUDED.source_type,
                source_title        = EXCLUDED.source_title,
                coden_code          = EXCLUDED.coden_code,
                publisher_name      = EXCLUDED.publisher_name,
                publisher_e_address = EXCLUDED.publisher_e_address,
                pub_date=EXCLUDED.pub_date
                RETURNING ernie_source_id INTO db_id;
    END;

    UPDATE scopus_sources ss
    SET website=sq.website
    FROM (
             SELECT db_id                    AS ernie_source_id,
                    string_agg(website, ',') AS website
             FROM xmltable(--
                          XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
                          '//bibrecord/head/source/website/ce:e-address' PASSING scopus_doc_xml COLUMNS --
                              website TEXT PATH 'normalize-space()'
                      )
             GROUP BY ernie_source_id
         ) AS sq
    WHERE ss.ernie_source_id = sq.ernie_source_id;

    -- scopus_isbns
    INSERT INTO scopus_isbns(ernie_source_id, isbn, isbn_length, isbn_type, isbn_level)
    SELECT db_id AS ernie_source_id,
           isbn,
           isbn_length,
           coalesce(isbn_type, '') as isbn_type,
           isbn_level
    FROM xmltable(--
                 '//bibrecord/head/source/isbn' PASSING scopus_doc_xml COLUMNS --
                isbn TEXT PATH '.',
                isbn_length SMALLINT PATH '@length',
                isbn_type TEXT PATH '@type',
                isbn_level TEXT PATH '@level'
             )
    ON CONFLICT (ernie_source_id, isbn) DO UPDATE SET isbn_length=excluded.isbn_length,
                                                      isbn_type=excluded.isbn_type,
                                                      isbn_level=excluded.isbn_level;

    -- scopus_issns
    INSERT INTO scopus_issns(ernie_source_id, issn, issn_type)
    SELECT db_id                   AS ernie_source_id,
           issn,
           coalesce(issn_type, '') AS issn_type
    FROM xmltable(--
                 '//bibrecord/head/source/issn' PASSING scopus_doc_xml COLUMNS --
                issn TEXT PATH '.',
                issn_type TEXT PATH '@type'
             )
    ON CONFLICT (ernie_source_id, issn, issn_type) DO UPDATE SET issn=excluded.issn,
                                                                 issn_type=excluded.issn_type;

    UPDATE scopus_publications sp
    SET pub_type        = singular.pub_type,
        process_stage   = singular.process_stage,
        state           = singular.state,
        date_sort       = singular.date_sort,
        ernie_source_id = singular.ernie_source_id
    FROM (
             SELECT scp,
                    pub_type,
                    process_stage,
                    state,
                    try_parse(sort_year, sort_month, sort_day) AS date_sort,
                    db_id                                      AS ernie_source_id
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
    INSERT INTO scopus_conference_events(conf_code, conf_name, conf_address, conf_city, conf_postal_code,
                                         conf_start_date,
                                         conf_end_date, conf_number, conf_catalog_number)

    SELECT coalesce(conf_code, '')           AS conf_code,
           coalesce(conf_name, '')           AS conf_name,
           conf_address,
           conf_city,
           conf_postal_code,
           try_parse(s_year, s_month, s_day) AS conf_start_date,
           try_parse(e_year, e_month, e_day) AS conf_end_date,
           conf_number,
           conf_catalog_number
    FROM xmltable(--
                 '//bibrecord/head/source' PASSING scopus_doc_xml COLUMNS --
                conf_code TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/confcode',
                conf_name TEXT PATH 'normalize-space(additional-srcinfo/conferenceinfo/confevent/confname)',
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
    ON CONFLICT (conf_code, conf_name) DO UPDATE SET conf_address=excluded.conf_address,
                                                     conf_city=excluded.conf_city,
                                                     conf_postal_code=excluded.conf_postal_code,
                                                     conf_start_date=excluded.conf_start_date,
                                                     conf_end_date=excluded.conf_end_date,
                                                     conf_number=excluded.conf_number,
                                                     conf_catalog_number=excluded.conf_catalog_number;

    UPDATE scopus_conference_events sce
    SET conf_sponsor=sq.conf_sponsor
    FROM (
             SELECT coalesce(conf_code, '')       AS conf_code,
                    coalesce(conf_name, '')       AS conf_name,
                    string_agg(conf_sponsor, ',') AS conf_sponsor
             FROM xmltable(--
                          '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confevent/confsponsors/confsponsor' --
                          PASSING scopus_doc_xml COLUMNS --
                              conf_code TEXT PATH '../../confcode',
                              conf_name TEXT PATH 'normalize-space(../../confname)',
                              conf_sponsor TEXT PATH '.'
                      )
             GROUP BY conf_code, conf_name
         ) AS sq
    WHERE sce.conf_code = sq.conf_code
      AND sce.conf_name = sq.conf_name;

    -- scopus_conf_proceedings
    INSERT INTO scopus_conf_proceedings(ernie_source_id, conf_code, conf_name, proc_part_no, proc_page_range,
                                        proc_page_count)
    SELECT db_id                   AS ernie_source_id,
           coalesce(conf_code, '') AS conf_code,
           coalesce(conf_name, '') AS conf_name,
           proc_part_no,
           proc_page_range,
           CASE
               WHEN proc_page_count LIKE '%p' THEN RTRIM(proc_page_count, 'p') :: SMALLINT
               WHEN proc_page_count LIKE '%p.' THEN RTRIM(proc_page_count, 'p.') :: SMALLINT
               WHEN proc_page_count ~ '[^0-9]' THEN NULL
               ELSE proc_page_count :: SMALLINT
               END
    FROM xmltable(--
                 '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication' PASSING scopus_doc_xml
                 COLUMNS --
                     conf_code TEXT PATH 'preceding-sibling::confevent/confcode',
                     conf_name TEXT PATH 'normalize-space(preceding-sibling::confevent/confname)',
                     proc_part_no TEXT PATH 'procpartno',
                     proc_page_range TEXT PATH 'procpagerange',
                     proc_page_count TEXT PATH 'procpagecount'
             )
    WHERE proc_part_no IS NOT NULL
       OR proc_page_range IS NOT NULL
       OR proc_page_count IS NOT NULL
    ON CONFLICT (ernie_source_id, conf_code, conf_name) DO UPDATE SET proc_part_no=excluded.proc_part_no,
                                                                      proc_page_range=excluded.proc_page_range,
                                                                      proc_page_count=excluded.proc_page_count;

    -- scopus_conf_editors
    INSERT INTO scopus_conf_editors(ernie_source_id, conf_code, conf_name, indexed_name, role_type,
                                    initials, surname, given_name, degree, suffix)
    SELECT db_id                          AS ernie_source_id,
           coalesce(conf_code, '')        AS conf_code,
           coalesce(conf_name, '')        AS conf_name,
           coalesce(indexed_name, '')     AS indexed_name,
           coalesce(edit_role, edit_type) AS role_type,
           initials,
           surname,
           given_name,
           degree,
           suffix
    FROM xmltable(--
                 XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
                 '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication/confeditors/editors/editor' --
                 PASSING scopus_doc_xml COLUMNS --
                     conf_code TEXT PATH '../../../preceding-sibling::confevent/confcode',
                     conf_name TEXT PATH 'normalize-space(../../../preceding-sibling::confevent/confname)',
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
    ON CONFLICT (ernie_source_id, conf_code, conf_name, indexed_name) DO UPDATE SET role_type=excluded.role_type,
                                                                                    initials=excluded.initials,
                                                                                    surname=excluded.surname,
                                                                                    given_name=excluded.given_name,
                                                                                    degree=excluded.degree,
                                                                                    suffix=excluded.suffix;

    UPDATE scopus_conf_editors sed
    SET address=sq.address
    FROM (
             SELECT db_id                    AS ernie_source_id,
                    coalesce(conf_code, '')  AS conf_code,
                    coalesce(conf_name, '')  AS conf_name,
                    string_agg(address, ',') AS address
             FROM xmltable(--
                          '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication/confeditors/editoraddress' --
                          PASSING scopus_doc_xml COLUMNS --
                              conf_code TEXT PATH '../../preceding-sibling::confevent/confcode',
                              conf_name TEXT PATH 'normalize-space(../../preceding-sibling::confevent/confname)',
                              address TEXT PATH 'normalize-space()'
                      )
             GROUP BY db_id, conf_code, conf_name
         ) AS sq
    WHERE sed.ernie_source_id = sq.ernie_source_id
      AND sed.conf_code = sq.conf_code
      AND sed.conf_name = sq.conf_name;

    UPDATE scopus_conf_editors sed
    SET organization=sq.organization
    FROM (
             SELECT db_id                         AS ernie_source_id,
                    coalesce(conf_code, '')       AS conf_code,
                    coalesce(conf_name, '')       AS conf_name,
                    string_agg(organization, ',') AS organization
             FROM xmltable(--
                          '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication/confeditors/editororganization'
                          PASSING scopus_doc_xml COLUMNS --
                              conf_code TEXT PATH '../../preceding-sibling::confevent/confcode',
                              conf_name TEXT PATH 'normalize-space(../../preceding-sibling::confevent/confname)',
                              organization TEXT PATH 'normalize-space()'
                      )
             GROUP BY db_id, conf_code, conf_name
         ) AS sq
    WHERE sed.ernie_source_id = sq.ernie_source_id
      AND sed.conf_code = sq.conf_code
      AND sed.conf_name = sq.conf_name;
END;
$$;
