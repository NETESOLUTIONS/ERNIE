\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- journal source and classifications
CREATE OR REPLACE PROCEDURE update_scopus_source_classifications(scopus_doc_xml XML)
AS $$
  BEGIN
  
     -- scopus_sources
    INSERT INTO scopus_sources(source_id, issn, source_type, source_title,
                                coden_code, publisher_name,publisher_e_address)
    SELECT DISTINCT
     coalesce(source_id,'') as source_id,
     coalesce(issn,'') as issn,
     source_type,
     source_title,
     coden_code,
     publisher_name,
     publisher_e_address
    FROM xmltable(--
      XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
      '//bibrecord/head/source/issn[@type="print"]' PASSING scopus_doc_xml COLUMNS --
      --@formatter:off
      source_id TEXT PATH '../@srcid',
      issn TEXT PATH '.',
      source_type TEXT PATH '../@type',
      source_title TEXT PATH '../sourcetitle',
      coden_code TEXT PATH '../codencode',
      publisher_name TEXT PATH '../publisher/publishername',
      publisher_e_address TEXT PATH '../publisher/ce:e-address'
      )
    WHERE source_id != '' OR issn != ''
    ON CONFLICT DO NOTHING;

    UPDATE scopus_sources ss
    SET issn_electronic = sq.issn_electronic
    FROM (
         SELECT DISTINCT
          coalesce(source_id,'') AS source_id,
          coalesce(issn,'') AS issn,
          issn_electronic
         FROM xmltable(--
         '//bibrecord/head/source/issn[@type="print"]' PASSING scopus_doc_xml COLUMNS --
         source_id TEXT PATH '../@srcid',
         issn TEXT PATH '.'
          ) as t1,
              xmltable(--
         '//bibrecord/head/source/issn[@type="electronic"]' PASSING scopus_doc_xml COLUMNS --
         issn_electronic TEXT PATH '.'
          ) as t2
         ) AS sq
    WHERE ss.source_id=sq.source_id and ss.issn=sq.issn;

    UPDATE scopus_sources ss
    SET website=sq.website
    FROM (
         SELECT
          coalesce(source_id,'') AS source_id,
          coalesce(issn,'') AS issn,
          string_agg(website, ',') AS website
         FROM xmltable(--
         XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
         '//bibrecord/head/source/website/ce:e-address' PASSING scopus_doc_xml COLUMNS --
         source_id TEXT PATH '../../@srcid',
         issn TEXT PATH '../../issn[@type="print"]',
         website TEXT PATH 'normalize-space()'
         )
         GROUP BY source_id, issn
         ) as sq
    WHERE ss.source_id=sq.source_id AND ss.issn=sq.issn;

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

    -- scopus_source_publication_details
    INSERT INTO scopus_source_publication_details(scp,issue,volume,first_page,last_page,publication_year,publication_date,conf_code,conf_name)

    SELECT
      scp,
      issue,
      volume,
      first_page,
      last_page,
      publication_year,
      make_date(publication_year, pub_month, pub_day) AS publication_date,
      coalesce(conf_code,'') AS conf_code,
      coalesce(conf_name,'') AS conf_name
    FROM
      xmltable(--
      '//bibrecord/head/source' PASSING scopus_doc_xml COLUMNS --
      scp BIGINT PATH '../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
      issue TEXT PATH 'volisspag/voliss/@issue',
      volume TEXT PATH 'volisspag/voliss/@volume',
      first_page TEXT PATH 'volisspag/pagerange/@first',
      last_page TEXT PATH 'volisspag/pagerange/@last',
      publication_year SMALLINT PATH 'publicationyear/@first',
      pub_month SMALLINT PATH 'publicationdate/month',
      pub_day SMALLINT PATH 'publicationdate/day',
      conf_code TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/confcode',
      conf_name TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/confname'
      )
    ON CONFLICT DO NOTHING;

    UPDATE scopus_source_publication_details spd
    SET indexed_terms=sq.indexed_terms
    FROM (
         SELECT
          scp,
          string_agg(descriptors, ',') AS indexed_terms
         FROM xmltable(--
         '//bibrecord/head/enhancement/descriptorgroup/descriptors/descriptor/mainterm' PASSING scopus_doc_xml COLUMNS --
         scp BIGINT PATH '../../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
         descriptors TEXT PATH 'normalize-space()'
         )
         GROUP BY scp
         ) as sq
    WHERE spd.scp=sq.scp;

    -- scopus_isbns
    INSERT INTO scopus_isbns(scp,isbn,isbn_length,isbn_level,isbn_type)

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

    -- scopus_subject_keywords
    INSERT INTO scopus_subject_keywords (scp, subject)

    SELECT 
      scp,
      subject
    FROM xmltable(--
      '//bibrecord/head/enhancement/classificationgroup/classifications[@type="SUBJECT"]/classification' PASSING scopus_doc_xml COLUMNS --
      scp BIGINT PATH '../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
      subject TEXT PATH '.'
      )
    ON CONFLICT DO NOTHING;
    
    -- scopus_classes
    INSERT INTO scopus_classes(scp,class_type,class_code)
    SELECT scp,
           class_type,
           coalesce(classification_code, classification) AS class_code
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
