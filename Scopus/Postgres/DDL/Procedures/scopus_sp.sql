\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE update_scopus_chemical_groups(scopus_doc_xml XML)
AS $$
  DECLARE
    cur RECORD;
  BEGIN

    --scopus_chemical_groups
    FOR cur IN(
      SELECT
        scp,
        coalesce(chemicals_source,'esbd') as chemicals_source,
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
        INSERT INTO scopus_chemical_groups(scp, chemicals_source,chemical_name, cas_registry_number)
        VALUES(cur.scp,cur.chemicals_source,cur.chemical_name,cur.cas_registry_number)
      ON CONFLICT DO NOTHING;
    END LOOP;
  END;
  $$
  LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE update_scopus_abstracts_title(scopus_doc_xml XML)
AS $$
  BEGIN
       -- scopus_abstracts
      INSERT INTO scopus_abstracts(scp, abstract_language, abstract_source)
      SELECT
        scp,
        abstract_language,
        abstract_source
      FROM xmltable(
        XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
        '//bibrecord/head/abstracts/abstract/ce:para' PASSING scopus_doc_xml COLUMNS
        scp BIGINT PATH '../../../../item-info/itemidlist/itemid[@idtype="SCP"]',
--         abstract_text TEXT PATH 'normalize-space()',
        abstract_language TEXT PATH '../@xml:lang',
        abstract_source TEXT PATH '../@source'
        )
      ON CONFLICT DO NOTHING;


      -- scopus_abstracts: concatenated abstract_text
      WITH
      sca AS (
        SELECT scp,abstract_languagestring_agg(abstract_text,chr(10)) as abstract_text
        FROM test_scopus_2, XMLTABLE(
        XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
        '//bibrecord/head/abstracts/abstract/ce:para' PASSING test_table COLUMNS
            scp BIGINT PATH '../../../../item-info/itemidlist/itemid[@idtype="SCP"]',
            abstract_text TEXT PATH 'normalize-space()',
            abstract_language TEXT PATH '../@xml:lang'
            )
            GROUP BY scp,abstract_language
        )
        UPDATE scopus_abstracts sa
        SET abstract_text=sca.abstract_text
        FROM sca WHERE sa.scp=sca.scp and sa.abstract_language=sca.abstract_language;


      -- scopus_titles
      INSERT INTO scopus_titles(scp, title, language)
      SELECT
        scp,
        title,
        language
      FROM xmltable(
        XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
        '//bibrecord/head/citation-title/titletext' PASSING scopus_doc_xml COLUMNS
        scp BIGINT PATH '../../../item-info/itemidlist/itemid[@idtype="SCP"]',
        title TEXT PATH 'normalize-space()',
        language TEXT PATH '@language'
        )
      ON CONFLICT DO NOTHING;
  END;
  $$
  LANGUAGE plpgsql;



CREATE OR REPLACE PROCEDURE update_scopus_keywords(scopus_doc_xml XML)
AS $$
  BEGIN
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
  END;
  $$
  LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE update_scopus_publication_identifiers(scopus_doc_xml XML)
AS $$
  BEGIN
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
      WHERE document_id_type!='SCP' and document_id_type!='SGR'
      UNION
      SELECT
          scp,
          document_id,
          upper(substr(document_id_type,4))
      FROM xmltable(
        XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
        '//bibrecord/item-info/itemidlist/ce:doi' PASSING scopus_doc_xml COLUMNS
        scp BIGINT PATH '../itemid[@idtype="SCP"]',
        document_id TEXT PATH '.',
        document_id_type TEXT PATH 'name(.)'
        )
      UNION
      SELECT
          scp,
          document_id,
          upper(substr(document_id_type,4))
      FROM xmltable(
        XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
        '//bibrecord/item-info/itemidlist/ce:pii' PASSING scopus_doc_xml COLUMNS
        scp BIGINT PATH '../itemid[@idtype="SCP"]',
        document_id TEXT PATH '.',
        document_id_type TEXT PATH 'name(.)'
        )
      ON CONFLICT DO NOTHING;
  END;
  $$
LANGUAGE plpgsql;
