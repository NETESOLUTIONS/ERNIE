\set ON_ERROR_STOP on
\set ECHO all
-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
CREATE OR REPLACE PROCEDURE stg_scopus_parse_source_and_conferences(scopus_doc_xml XML)
    LANGUAGE plpgsql AS
$$
DECLARE
    db_id INT;
    cur   RECORD;
BEGIN
    INSERT INTO stg_scopus_sources(ernie_source_id, source_id, issn_main, isbn_main, source_type, source_title,
                                   coden_code, publisher_name, publisher_e_address, pub_date)
    SELECT nextval('scopus_sources_ernie_source_id_seq') AS ernie_source_id,
           coalesce(source_id, '')                       AS source_id,
           coalesce(issn, '')                            AS issn_main,
           coalesce(isbn, '')                            AS isbn_main,
           string_agg(source_type, ' ')                  AS source_type,
           string_agg(source_title, ' ')                 AS source_title,
           string_agg(coden_code, ' ')                   AS coden_code,
           string_agg(publisher_name, ' ')               AS publisher_name,
           string_agg(publisher_e_address, ' ')          AS publisher_e_address,
           max(try_parse(pub_year, pub_month, pub_day))  AS pub_date
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
    GROUP BY source_id, issn_main, isbn_main
    RETURNING ernie_source_id INTO db_id;

    UPDATE stg_scopus_sources
    SET website=sub.website
    FROM (select source_id,
                 string_agg(website, ',') AS website
          FROM xmltable(--
                  XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
                  '//bibrecord/head/source/website/ce:e-address' PASSING scopus_doc_xml COLUMNS --
                      source_id TEXT PATH '//bibrecord/head/source/@srcid',
                      website TEXT PATH 'normalize-space()')
          group by source_id)
             as sub
    WHERE stg_scopus_sources.source_id = sub.source_id;

    -- scopus_isbns
    INSERT INTO stg_scopus_isbns(ernie_source_id, isbn, isbn_length, isbn_type, isbn_level)
    SELECT DISTINCT db_id                   AS ernie_source_id,
                    isbn,
                    isbn_length,
                    coalesce(isbn_type, '') AS isbn_type,
                    isbn_level
    FROM xmltable(--
            '//bibrecord/head/source/isbn' PASSING scopus_doc_xml COLUMNS --
                isbn TEXT PATH '.',
                isbn_length SMALLINT PATH '@length',
                isbn_type TEXT PATH '@type',
                isbn_level TEXT PATH '@level'
        );
    -- scopus_issns
    INSERT INTO stg_scopus_issns(ernie_source_id, issn, issn_type)
    SELECT db_id                   AS ernie_source_id,
           issn,
           coalesce(issn_type, '') AS issn_type
    FROM xmltable(--
            '//bibrecord/head/source/issn' PASSING scopus_doc_xml COLUMNS --
                issn TEXT PATH '.',
                issn_type TEXT PATH '@type'
        );


    -- scopus_conference_events
    INSERT INTO stg_scopus_conference_events(conf_code, conf_name, conf_address, conf_city, conf_postal_code,
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
        );

        --TODO:
    UPDATE stg_scopus_conference_events sce
    SET conf_sponsor=sq.conf_sponsor
    FROM (
             SELECT coalesce(conf_code, '')       AS conf_code,
                    coalesce(conf_name, '')       AS conf_name,
                    string_agg(conf_sponsor, ',') AS conf_sponsor
             FROM xmltable(--
                     '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confevent/confsponsors/confsponsor' --
                     PASSING scopus_doc_xml COLUMNS --
                         conf_code TEXT PATH '../../confcode',
                         conf_name TEXT PATH '../../confname',
                         conf_sponsor TEXT PATH 'normalize-space()'
                 )
             GROUP BY conf_code, conf_name
         ) AS sq
    WHERE sce.conf_code = sq.conf_code
      AND sce.conf_name = sq.conf_name;

    -- scopus_conf_proceedings
    INSERT INTO stg_scopus_conf_proceedings(ernie_source_id, conf_code, conf_name, proc_part_no, proc_page_range,
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
       OR proc_page_count IS NOT NULL;

    -- scopus_conf_editors
    INSERT INTO stg_scopus_conf_editors(ernie_source_id, conf_code, conf_name, indexed_name, role_type,
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
        );

    UPDATE stg_scopus_conf_editors sed
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
                         conf_name TEXT PATH '../../preceding-sibling::confevent/confname',
                         address TEXT PATH 'normalize-space()'
                 )
             GROUP BY db_id, conf_code, conf_name
         ) AS sq
    WHERE sed.ernie_source_id = sq.ernie_source_id
      AND sed.conf_code = sq.conf_code
      AND sed.conf_name = sq.conf_name;

    UPDATE stg_scopus_conf_editors sed
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
                         conf_name TEXT PATH '../../preceding-sibling::confevent/confname',
                         organization TEXT PATH 'normalize-space()'
                 )
             GROUP BY db_id, conf_code, conf_name
         ) AS sq
    WHERE sed.ernie_source_id = sq.ernie_source_id
      AND sed.conf_code = sq.conf_code
      AND sed.conf_name = sq.conf_name;

      FOR cur IN (
        SELECT sgr,
               pub_year,
               try_parse(sort_year, sort_month, sort_day) AS date_sort,
               scp,
               correspondence_person_indexed_name,
               correspondence_city,
               correspondence_country,
               correspondence_e_address,
               citation_type,
               pub_type,
               citation_language,
               process_stage,
               state,
               db_id as ernie_source_id

        FROM xmltable(--
-- The `xml:` namespace doesn't need to be specified
                XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce, 'http://www.elsevier.com/xml/ani/ait' as ait), --
                '//item' PASSING scopus_doc_xml COLUMNS --
                    sgr BIGINT PATH 'bibrecord/item-info/itemidlist/itemid[@idtype="SGR"]', --
                    pub_year SMALLINT PATH 'bibrecord/head/source/publicationyear/@first', --
                    scp BIGINT PATH 'bibrecord/item-info/itemidlist/itemid[@idtype="SCP"]', --
                    -- noramlize-space() converts NULLs to empty strings
                    correspondence_person_indexed_name TEXT PATH 'bibrecord/head/correspondence/person/ce:indexed-name', --
                    correspondence_city TEXT PATH 'bibrecord/head/correspondence/affiliation/city', --
                    correspondence_country TEXT PATH 'bibrecord/head/correspondence/affiliation/country', --
                    correspondence_e_address TEXT PATH 'bibrecord/head/correspondence/ce:e-address', --
                    citation_type TEXT PATH 'bibrecord/head/citation-info/citation-type/@code', --
                    citation_language XML PATH 'bibrecord/head/citation-info/citation-language/@language',
                    pub_type TEXT PATH 'ait:process-info/ait:status/@type',
                    process_stage TEXT PATH 'ait:process-info/ait:status/@stage',
                    state TEXT PATH 'ait:process-info/ait:status/@state',
                    sort_year SMALLINT PATH 'ait:process-info/ait:date-sort/@year',
                    sort_month SMALLINT PATH 'ait:process-info/ait:date-sort/@month',
                    sort_day SMALLINT PATH 'ait:process-info/ait:date-sort/@day')
    )
        LOOP
            INSERT INTO stg_scopus_publication_groups(sgr, pub_year)
            VALUES (cur.sgr, cur.pub_year);

            INSERT INTO stg_scopus_publications(scp, sgr, correspondence_person_indexed_name, correspondence_city,
                                                correspondence_country, correspondence_e_address, pub_type,
                                                citation_type,
                                                citation_language, process_stage, state, date_sort, ernie_source_id)
            VALUES (cur.scp, cur.sgr, cur.correspondence_person_indexed_name, cur.correspondence_city,
                    cur.correspondence_country, cur.correspondence_e_address, cur.pub_type, cur.citation_type,
                    cur.citation_language, cur.process_stage, cur.state, cur.date_sort, cur.ernie_source_id);
        END LOOP;
END ;
$$;





