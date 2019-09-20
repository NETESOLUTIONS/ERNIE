\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

create or replace procedure stg_scopus_parse_source_and_conferences(scopus_doc_xml xml)
    language plpgsql
as
$$
DECLARE
    db_id int;
BEGIN
    INSERT INTO stg_scopus_sources(ernie_source_id, source_id, issn_main, isbn_main, source_type, source_title,
                                   coden_code, publisher_name, publisher_e_address, pub_date)
    SELECT nextval('scopus_sources_ernie_source_id_seq') as ernie_source_id,
           coalesce(source_id, '')                              AS source_id,
           coalesce(issn, '')                                   AS issn_main,
           coalesce(isbn, '')                                   AS isbn_main,
           string_agg(source_type, ' ')                         as source_type,
           string_agg(source_title, ' ')                        as source_title,
           string_agg(coden_code, ' ')                          as coden_code,
           string_agg(publisher_name, ' ')                      as publisher_name,
           string_agg(publisher_e_address, ' ')                 as publisher_e_address,
           max(try_parse(pub_year, pub_month, pub_day))         AS pub_date
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
    group by source_id, issn_main, isbn_main
    RETURNING ernie_source_id into db_id;

    -- scopus_isbns
    INSERT INTO stg_scopus_isbns(ernie_source_id, isbn, isbn_length, isbn_type, isbn_level)
    SELECT DISTINCT db_id                   as ernie_source_id,
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
        );

    -- scopus_issns
    INSERT INTO stg_scopus_issns(ernie_source_id, issn, issn_type)
    SELECT db_id                   as ernie_source_id,
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

    -- scopus_conf_proceedings
    INSERT INTO stg_scopus_conf_proceedings(ernie_source_id, conf_code, conf_name, proc_part_no, proc_page_range,
                                            proc_page_count)
    SELECT db_id                   as ernie_source_id,
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
    SELECT db_id                          as ernie_source_id,
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
END ;
$$;