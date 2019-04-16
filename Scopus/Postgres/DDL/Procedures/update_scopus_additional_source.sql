\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- additional source information
CREATE OR REPLACE PROCEDURE update_scopus_additional_source(scopus_doc_xml XML)
AS $$
  BEGIN
    -- scopus_conf_proceedings
    INSERT INTO scopus_conf_proceedings(source_id,issn,conf_code,conf_name,proc_part_no,proc_page_range,proc_page_count)

    SELECT
      coalesce(source_id,'') AS source_id,
      coalesce(issn,'') AS issn,
      coalesce(conf_code,'') AS conf_code,
      coalesce(conf_name,'') AS conf_name,
      proc_part_no,
      proc_page_range,
      CASE
        WHEN proc_page_count LIKE 'var%' THEN NULL
        WHEN proc_page_count LIKE '%p' THEN RTRIM(proc_page_count, 'p') :: SMALLINT
        ELSE proc_page_count :: SMALLINT
      END
    FROM
      xmltable(--
      '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication' PASSING scopus_doc_xml COLUMNS --
      source_id TEXT PATH '../../../@srcid',
      issn TEXT PATH '../../../issn[@type="print"]',
      conf_code TEXT PATH 'preceding-sibling::confevent/confcode',
      conf_name TEXT PATH 'preceding-sibling::confevent/confname',
      proc_part_no TEXT PATH 'procpartno',
      proc_page_range TEXT PATH 'procpagerange',
      proc_page_count TEXT PATH 'procpagecount'
      )
    WHERE proc_part_no IS NOT NULL OR proc_page_range IS NOT NULL or proc_page_count IS NOT NULL
    ON CONFLICT DO NOTHING;

    -- scopus_conf_editors
    INSERT INTO scopus_conf_editors(source_id, issn, conf_code,conf_name,indexed_name,role_type,
                                    initials,surname,given_name,degree,suffix)

    SELECT
      coalesce(source_id,'') AS source_id,
      coalesce(issn,'') AS issn,
      coalesce(conf_code,'') AS conf_code,
      coalesce(conf_name,'') AS conf_name,
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
      source_id TEXT PATH '//bibrecord/head/source/@srcid',
      issn TEXT PATH '//bibrecord/head/source/issn[@type="print"]',
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
      ON CONFLICT DO NOTHING;

    UPDATE scopus_conf_editors sed
    SET address=sq.address
    FROM (
         SELECT
          coalesce(source_id,'') AS source_id,
          coalesce(issn,'') AS issn,
          coalesce(conf_code,'') AS conf_code,
          coalesce(conf_name,'') AS conf_name,
          string_agg(address, ',') AS address
         FROM xmltable(--
         '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication/confeditors/editoraddress' PASSING scopus_doc_xml COLUMNS --
         source_id TEXT PATH '//bibrecord/head/source/@srcid',
         issn TEXT PATH '//bibrecord/head/source/issn[@type="print"]',
         conf_code TEXT PATH '../../preceding-sibling::confevent/confcode',
         conf_name TEXT PATH '../../preceding-sibling::confevent/confname',
         address TEXT PATH 'normalize-space()'
         )
         GROUP BY source_id, issn, conf_code, conf_name
         ) as sq
    WHERE sed.conf_code=sq.conf_code AND sed.source_id=sq.source_id AND sed.issn=sq.issn AND sed.conf_name=sq.conf_name;

    UPDATE scopus_conf_editors sed
    SET organization=sq.organization
    FROM (
         SELECT
          coalesce(source_id,'') AS source_id,
          coalesce(issn,'') AS issn,
          coalesce(conf_code,'') AS conf_code,
          coalesce(conf_name,'') AS conf_name,
          string_agg(organization, ',') AS organization
         FROM xmltable(--
         '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication/confeditors/editororganization' PASSING scopus_doc_xml COLUMNS --
         source_id TEXT PATH '//bibrecord/head/source/@srcid',
         issn TEXT PATH '//bibrecord/head/source/issn[@type="print"]',
         conf_code TEXT PATH '../../preceding-sibling::confevent/confcode',
         conf_name TEXT PATH '../../preceding-sibling::confevent/confname',
         organization TEXT PATH 'normalize-space()'
         )
         GROUP BY source_id, issn, conf_code, conf_name
         ) as sq
    WHERE sed.conf_code=sq.conf_code AND sed.source_id=sq.source_id AND sed.issn=sq.issn AND sed.conf_name=sq.conf_name;
    
  END;
  $$
  LANGUAGE plpgsql;