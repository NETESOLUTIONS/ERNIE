\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- journal source and classifications
CREATE OR REPLACE PROCEDURE update_scopus_source_classifications(scopus_doc_xml XML)
AS $$
  BEGIN
  
    -- scopus_sources
    INSERT INTO scopus_sources(scp, source_id, source_type, source_title, issn_print,
                                   coden_code,issue,volume,first_page,last_page,publication_year,publication_date,
                                   publisher_name,publisher_e_address)
    SELECT DISTINCT
     scp,
     source_id,
     source_type,
     source_title,
     issn_print,
     coden_code,
     issue,
     volume,
     first_page,
     last_page,
     publication_year,
     make_date(publication_year, pub_month, pub_day) AS publication_date,
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
      coden_code TEXT PATH 'codencode',
      issue TEXT PATH 'volisspag/voliss/@issue',
      volume TEXT PATH 'volisspag/voliss/@volume',
      first_page TEXT PATH 'volisspag/pagerange/@first',
      last_page TEXT PATH 'volisspag/pagerange/@last',
      publication_year SMALLINT PATH 'publicationyear/@first',
      pub_month SMALLINT PATH 'publicationdate/month',
      pub_day SMALLINT PATH 'publicationdate/day',
      publisher_name TEXT PATH 'publisher/publishername',
      publisher_e_address TEXT PATH 'publisher/ce:e-address'
      )
      ON CONFLICT DO NOTHING;

    UPDATE scopus_sources ss
    SET issn_electronic = sq.issn_electronic
    FROM (
         SELECT DISTINCT scp, issn_electronic
         FROM xmltable(--
         '//bibrecord/head/source/issn[@type="electronic"]' PASSING scopus_doc_xml COLUMNS --
         scp BIGINT PATH '../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
         issn_electronic TEXT PATH '.'
          )
          ) AS sq
    WHERE ss.scp=sq.scp;

    UPDATE scopus_sources ss
    SET indexed_terms=sq.indexed_terms
    FROM (
         SELECT scp, string_agg(descriptors, ',') AS indexed_terms
         FROM xmltable(--
         '//bibrecord/head/enhancement/descriptorgroup/descriptors/descriptor/mainterm' PASSING scopus_doc_xml COLUMNS --
         scp BIGINT PATH '../../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
         descriptors TEXT PATH 'normalize-space()'
         )
         GROUP BY scp
         ) as sq
    WHERE ss.scp=sq.scp;

    UPDATE scopus_sources ss
    SET website=sq.website
    FROM (
         SELECT scp, string_agg(website, ',') AS website
         FROM xmltable(--
         XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
         '//bibrecord/head/source/website/ce:e-address' PASSING scopus_doc_xml COLUMNS --
         scp BIGINT PATH '../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
         website TEXT PATH 'normalize-space()'
         )
         GROUP BY scp
         ) as sq
    WHERE ss.scp=sq.scp;

    -- scopus_source_isbns
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
scopus_keywords
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
