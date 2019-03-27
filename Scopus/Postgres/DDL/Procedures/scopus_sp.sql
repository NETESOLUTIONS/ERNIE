CREATE OR REPLACE PROCEDURE scopus_abstracts_titles_keywords_publication_identifiers(scopus_doc_xml XML)
AS $$
  DECLARE
    cur RECORD;
  BEGIN

    --scopus_chemicalgroups
    FOR cur IN(
      SELECT
        scp,
        case WHEN chemicals_source is null then 'esbd'
          ELSE chemicals_source
        end as chemicals_source,
        chemical_name,
        cas_registry_number
      FROM xmltable(
        XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
        '//bibrecord/head/enhancement/chemicalgroup/chemicals/chemical/cas-registry-number' PASSING scopus_doc_xml COLUMNS
        scp BIGINT PATH '//item-info/itemidlist/itemid[@idtype="SCP"]',
        chemicals_source TEXT PATH '../chemicals[@source]',
        chemical_name TEXT PATH '../chemical-name',
        cas_registry_number TEXT PATH '.'
        ) )LOOP
        INSERT INTO scopus_chemicalgroups(scp, chemicals_source,chemical_name, cas_registry_number)
        VALUES(cur.scp,cur.chemicals_source,cur.chemical_name,cur.cas_registry_number)
      ON CONFLICT DO NOTHING;
    END LOOP;

      -- scopus_abstracts
      INSERT INTO scopus_abstracts(scp, abstract_text, abstract_language, abstract_source)
      SELECT
        scp,
        abstract_text,
        abstract_language,
        abstract_source
      FROM xmltable(
        XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
        '//bibrecord/head/abstracts/abstract/ce:para' PASSING scopus_doc_xml COLUMNS
        scp BIGINT PATH '../../../../item-info/itemidlist/itemid[@idtype="SCP"]',
        abstract_text TEXT PATH 'normalize-space()',
        abstract_language TEXT PATH '../@xml:lang',
        abstract_source TEXT PATH '../@source'
        )
      ON CONFLICT DO NOTHING;


      -- scopus_titles
      INSERT INTO scopus_titles(scp, title, language,type)
      SELECT
        scp,
        title,
        language,
        type
      FROM xmltable(
        XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
        '//bibrecord/head/citation-title/titletext' PASSING scopus_doc_xml COLUMNS
        scp BIGINT PATH '../../../item-info/itemidlist/itemid[@idtype="SCP"]',
        title TEXT PATH 'normalize-space()',
        language TEXT PATH '@language',
        type TEXT PATH  '../../citation-info/citation-type/@code'
        )
      ON CONFLICT DO NOTHING;


      -- scopus_keywords
      INSERT INTO scopus_keywords(scp, keyword)
      SELECT
        scp,
        keyword
      FROM xmltable (
        XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
        '//bibrecord/head/citation-info/author-keywords/author-keyword' PASSING scopus_doc_xml COLUMNS
        scp BIGINT PATH '../../../../item-info/itemidlist/itemid[@idtype="SCP"]',
        keyword TEXT PATH '.'
        )
      ON CONFLICT DO NOTHING;


      -- scopus_publication_identifiers
      INSERT INTO scopus_publication_identifiers(scp, document_id, document_id_type)
      SELECT
          scp,
          document_id,
          document_id_type
        FROM xmltable(--
          XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
          '//bibrecord/item-info/itemidlist/itemid' PASSING scopus_doc_xml COLUMNS --
          --@formatter:off
          scp BIGINT PATH '//itemid[@idtype="SCP"]',
          document_id TEXT PATH '.',
          document_id_type TEXT PATH '@idtype'
          --@formatter:on
          )
      WHERE document_id_type!='SCP'
      UNION
      SELECT
          scp,
          document_id,
          upper(substr(document_id_type,4))
      FROM xmltable(
        XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
        '//bibrecord/item-info/itemidlist' PASSING scopus_doc_xml COLUMNS
        scp BIGINT PATH 'itemid[@idtype="SCP"]',
        document_id TEXT PATH 'ce:doi',
        document_id_type TEXT PATH 'name(ce:doi)'
        ) WHERE document_id_type like 'ce%'
      UNION
      SELECT
          scp,
          document_id,
          upper(substr(document_id_type,4))
      FROM xmltable(
        XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
        '//bibrecord/item-info/itemidlist' PASSING scopus_doc_xml COLUMNS
        scp BIGINT PATH 'itemid[@idtype="SCP"]',
        document_id TEXT PATH 'ce:pii',
        document_id_type TEXT PATH 'name(ce:pii)'
        ) WHERE document_id_type like 'ce%'
      ON CONFLICT DO NOTHING;
  END;
  $$
  LANGUAGE plpgsql;

