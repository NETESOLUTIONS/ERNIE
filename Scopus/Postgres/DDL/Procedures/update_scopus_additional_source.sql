\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- additional source information
CREATE OR REPLACE PROCEDURE update_scopus_additional_source(scopus_doc_xml XML)
AS $$
  BEGIN
  
    -- scopus_conferences
    INSERT INTO scopus_conferences(scp,conf_code)

    SELECT
      scp,
      conf_code
    FROM
      xmltable(--
      '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confevent' PASSING scopus_doc_xml COLUMNS --
      scp BIGINT PATH '../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
      conf_code BIGINT PATH 'confcode'
      )
      ON CONFLICT DO NOTHING;

    -- scopus_conference_events
    INSERT INTO scopus_conference_events(conf_code, conf_name, conf_address,conf_city, conf_postal_code, conf_start_date,
                                    conf_end_date, conf_number, conf_catalog_number)

    SELECT
      conf_code,
      conf_name,
      conf_address,
      conf_city,
      conf_postal_code,
      make_date(s_year, s_month, s_day) AS conf_start_date,
      make_date(e_year, e_month, e_day) AS conf_end_date,
      conf_number,
      conf_catalog_number
    FROM
      xmltable(--
      '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confevent' PASSING scopus_doc_xml COLUMNS --
      conf_code BIGINT PATH 'confcode',
      conf_name TEXT PATH 'confname',
      conf_address TEXT PATH 'conflocation/address-part',
      conf_city TEXT PATH 'conflocation/city-group',
      conf_postal_code TEXT PATH 'conflocation/postal-code',
      s_year SMALLINT PATH 'confdate/startdate/@year',
      s_month SMALLINT PATH 'confdate/startdate/@month',
      s_day SMALLINT PATH 'confdate/startdate/@day',
      e_year SMALLINT PATH 'confdate/enddate/@year',
      e_month SMALLINT PATH 'confdate/enddate/@month',
      e_day SMALLINT PATH 'confdate/enddate/@day',
      conf_number TEXT PATH 'confnumber',
      conf_catalog_number TEXT PATH 'confcatnumber'
      )
    ON CONFLICT DO NOTHING;

    UPDATE scopus_conference_events sce
    SET conf_sponsor=sq.conf_sponsor
    FROM (
         SELECT conf_code, string_agg(conf_sponsor,',') AS conf_sponsor
         FROM xmltable(--
         '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confevent/confsponsors/confsponsor' PASSING scopus_doc_xml COLUMNS --
         conf_code BIGINT PATH '../../confcode',
         conf_sponsor TEXT PATH 'normalize-space()'
         )
         GROUP BY conf_code
         ) as sq
    WHERE sce.conf_code=sq.conf_code;

    -- scopus_conf_publications
    INSERT INTO scopus_conf_publications(scp,proc_part_no,proc_page_range,proc_page_count)

    SELECT
      scp,
      proc_part_no,
      proc_page_range,
      proc_page_count
    FROM
      xmltable(--
      '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication' PASSING scopus_doc_xml COLUMNS --
      scp BIGINT PATH '../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
      proc_part_no TEXT PATH 'procpartno',
      proc_page_range TEXT PATH 'procpagerange',
      proc_page_count SMALLINT PATH 'procpagecount'
      )
    WHERE proc_part_no IS NOT NULL OR proc_page_range IS NOT NULL or proc_page_count IS NOT NULL
    ON CONFLICT DO NOTHING;

    -- scopus_conf_editors
    INSERT INTO scopus_conf_editors(conf_code,indexed_name,role_type,initials,surname,given_name,degree,suffix)

    SELECT
      conf_code,
      indexed_name,
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
      conf_code BIGINT PATH '../../../preceding-sibling::confevent/confcode',
      indexed_name TEXT PATH 'ce:indexed-name',
      edit_role TEXT PATH '@role',
      edit_type TEXT PATH '@type',
      initials TEXT PATH 'initials',
      surname TEXT PATH 'ce:surname',
      given_name TEXT PATH 'ce:given-name',
      degree TEXT PATH 'ce:degrees',
      suffix TEXT PATH 'ce:suffix'
      )
      ON CONFLICT DO NOTHING;

    UPDATE scopus_conf_editors sce
    SET address=sq.address
    FROM (
         SELECT conf_code, string_agg(address, ',') AS address
         FROM xmltable(--
         '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication/confeditors/editoraddress' PASSING scopus_doc_xml COLUMNS --
         conf_code BIGINT PATH '../../preceding-sibling::confevent/confcode',
         address TEXT PATH 'normalize-space()'
         )
         GROUP BY conf_code
         ) as sq
    WHERE sce.conf_code=sq.conf_code;

    UPDATE scopus_conf_editors sce
    SET organization=sq.organization
    FROM (
         SELECT conf_code, string_agg(organization, ',') AS organization
         FROM xmltable(--
         '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication/confeditors/editororganization' PASSING scopus_doc_xml COLUMNS --
         conf_code BIGINT PATH '../../preceding-sibling::confevent/confcode',
         organization TEXT PATH 'normalize-space()'
         )
         GROUP BY conf_code
         ) as sq
    WHERE sce.conf_code=sq.conf_code;

    
  END;
  $$
  LANGUAGE plpgsql;