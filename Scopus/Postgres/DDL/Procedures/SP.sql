CREATE OR REPLACE PROCEDURE update_scopus_source_classifications(scopus_doc_xml XML)
AS $$
  BEGIN
    -- scopus_sources
    INSERT INTO scopus_sources(scp, source_id, source_type, source_title, issn_print, issn_electronic,
                                   codencode,issue,volume,first_page,last_page,publication_year,publication_date,
                                   website,publisher_name,publisher_e_address)
    SELECT
     scp,
     source_id,
     source_type,
     source_title,
     issn_print,
     issn_electronic,
     codencode,
     issue,
     volume,
     first_page,
     last_page,
     publication_year,
     make_date(publication_year, pub_month, pub_day) AS publication_date,
     website,
     publisher_name,
     publisher_e_address
    FROM xmltable(--
      XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
      '//bibrecord/head/source' PASSING scopus_doc_xml COLUMNS --
      --@formatter:off
      scp BIGINT PATH '../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
      source_id BIGINT PATH '@srcid',
      source_type TEXT PATH '@type',
      source_title TEXT PATH 'sourcetitle',
      issn_print TEXT PATH 'issn[@type="print"]',
      issn_electronic TEXT PATH 'issn[@type="electronic"]',
      codencode TEXT PATH 'codencode',
      issue TEXT PATH 'volisspag/voliss/@issue',
      volume TEXT PATH 'volisspag/voliss/@volume',
      first_page TEXT PATH 'volisspag/pagerange/@first',
      last_page TEXT PATH 'volisspag/pagerange/@last',
      publication_year SMALLINT PATH 'publicationyear/@first',
      pub_month SMALLINT PATH 'publicationdate/month',
      pub_day SMALLINT PATH 'publicationdate/day',
      website TEXT PATH 'website/ce:e-address',
      publisher_name TEXT PATH 'publisher/publishername',
      publisher_e_address TEXT PATH 'publisher/ce:e-address'
      )
      ON CONFLICT DO NOTHING;

    UPDATE scopus_sources ss
    SET descriptors=temp1.descriptors
    FROM (
         SELECT scp, string_agg(descriptors, ',') AS descriptors
         FROM xmltable(--
         '//bibrecord/head/enhancement/descriptorgroup/descriptors/descriptor/mainterm' PASSING scopus_doc_xml COLUMNS --
         scp BIGINT PATH '../../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
         descriptors TEXT PATH 'normalize-space()'
         )
         GROUP BY scp
         ) as temp1
    WHERE ss.scp=temp1.scp;

    UPDATE scopus_sources ss
    SET subjects=temp2.subjects
    FROM (
         SELECT scp, string_agg(subject, ',') AS subjects
         FROM xmltable(--
         '//bibrecord/head/enhancement/classificationgroup/classifications[@type="SUBJECT"]/classification' PASSING scopus_doc_xml COLUMNS --
         scp BIGINT PATH '../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
         subject TEXT PATH 'normalize-space()'
         )
         GROUP BY scp
         ) as temp2
    WHERE ss.scp=temp2.scp;

    -- scopus_isbn
    INSERT INTO scopus_source_isbns(scp,isbn,isbn_length,isbn_level,isbn_type)

    SELECT
      scp,
      isbn,
      isbn_length,
      isbn_level,
      isbn_type
    FROM xmltable(--
      '//bibrecord/head/source/isbn' PASSING scopus_doc_xml COLUMNS --
      scp BIGINT PATH '../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
      isbn TEXT PATH '.',
      isbn_length SMALLINT PATH '@length',
      isbn_level TEXT PATH'@level',
      isbn_type TEXT PATH '@type'
      )
    ON CONFLICT DO NOTHING;

    -- scopus_subjects
    INSERT INTO scopus_subjects (scp, subj_abbr)

    SELECT
      scp,
      subj_abbr
    FROM xmltable(--
      '//bibrecord/head/enhancement/classificationgroup/classifications[@type="SUBJABBR"]/classification' PASSING scopus_doc_xml COLUMNS --
      scp BIGINT PATH '../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
      subj_abbr TEXT PATH '.'
      )
    ON CONFLICT DO NOTHING;

    -- scopus_classes
    INSERT INTO scopus_classes(scp,class_type,class_code)
    SELECT scp,
           class_type,
           CASE
               WHEN coalesce(classification_code) IS NOT NULL THEN classification_code
               ELSE classification
           END AS class_code
    FROM xmltable(--
      '//bibrecord/head/enhancement/classificationgroup/classifications[not(@type="SUBJABBR" or @type="SUBJECT")]/classification' PASSING scopus_doc_xml COLUMNS --
      scp BIGINT PATH '../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
      class_type TEXT PATH '../@type',
      classification_code TEXT PATH 'classification-code',
      classification TEXT PATH '.'
    )
    ON CONFLICT DO NOTHING;

    -- scopus_classification_lookup
    INSERT INTO scopus_classification_lookup(class_type,class_code,description)
    SELECT class_type,
           class_code,
           description
    FROM xmltable(--
      '//bibrecord/head/enhancement/classificationgroup/classifications[not(@type="ASJC" or @type="SUBJABBR" or @type="SUBJECT")]/classification/classification-code' PASSING scopus_doc_xml COLUMNS --
      class_type TEXT PATH '../../@type',
      class_code TEXT PATH '.',
      description TEXT PATH 'following-sibling::classification-description'
    )
    ON CONFLICT DO NOTHING;

  END;
  $$
  LANGUAGE plpgsql;

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

-- additional source information
CREATE OR REPLACE PROCEDURE update_scopus_additional_source(scopus_doc_xml XML)
AS $$
  BEGIN
    -- scopus_conferences
    INSERT INTO scopus_conferences(scp, conf_name, conf_address,conf_city, conf_postal_code, conf_start_date,
                                    conf_end_date, conf_number, conf_catnumber,conf_code)

    SELECT
      scp,
      conf_name,
      conf_address,
      conf_city,
      conf_postal_code,
      make_date(s_year, s_month, s_day) AS conf_start_date,
      make_date(e_year, e_month, e_day) AS conf_end_date,
      conf_number,
      conf_catnumber,
      conf_code
    FROM
      xmltable(--
      '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confevent' PASSING scopus_doc_xml COLUMNS --
      scp BIGINT PATH '../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
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
      conf_catnumber TEXT PATH 'confcatnumber',
      conf_code TEXT PATH 'confcode'
      )
      ON CONFLICT DO NOTHING;

    -- scopus_conf_sponsors
    INSERT INTO scopus_conf_sponsors(scp, conf_sponsor)

    SELECT
      scp,
      conf_sponsor
    FROM
      xmltable(--
      '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confevent/confsponsors/confsponsor' PASSING scopus_doc_xml COLUMNS --
      scp BIGINT PATH '../../../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
      conf_sponsor TEXT PATH '.'
      )
    ON CONFLICT DO NOTHING;

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
      ON CONFLICT DO NOTHING;

    -- scopus_conf_editors
    INSERT INTO scopus_conf_editors(scp,indexed_name,role_type,initials,surname,given_name,degree,suffix)

    SELECT
      scp,
      indexed_name,
      CASE
        WHEN coalesce(edit_role) IS NOT NULL THEN edit_role
        ELSE edit_type
      END AS role_type,
      initials,
      surname,
      given_name,
      degree,
      suffix
    FROM
      xmltable(--
      XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
      '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication/confeditors/editors/editor' PASSING scopus_doc_xml COLUMNS --
      scp BIGINT PATH '../../../../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
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
    SET address=temp1.address
    FROM (
         SELECT scp, string_agg(address, ',') AS address
         FROM xmltable(--
         '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication/confeditors/editoraddress' PASSING scopus_doc_xml COLUMNS --
         scp BIGINT PATH '../../../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
         address TEXT PATH 'normalize-space()'
         )
         GROUP BY scp
         ) as temp1
    WHERE sce.scp=temp1.scp;

    UPDATE scopus_conf_editors sce
    SET organization=temp2.organization
    FROM (
         SELECT scp, string_agg(organization, ',') AS organization
         FROM xmltable(--
         '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication/confeditors/editororganization' PASSING scopus_doc_xml COLUMNS --
         scp BIGINT PATH '../../../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
         organization TEXT PATH 'normalize-space()'
         )
         GROUP BY scp
         ) as temp2
    WHERE sce.scp=temp2.scp;

  END;
  $$
  LANGUAGE plpgsql;