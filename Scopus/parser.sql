\set ON_ERROR_STOP on
-- Reduce verbosity
-- \set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

SET script.xml_file = :'xml_file';

-- TODO ON CONFLICT DO NOTHING need to be replaced by updates

DO $block$
  DECLARE
    -- scopus_doc TEXT;
    scopus_doc_xml XML;
    cur RECORD;
  BEGIN
    SELECT xmlparse(DOCUMENT convert_from(pg_read_binary_file(current_setting('script.xml_file')), 'UTF8'))
      INTO scopus_doc_xml;

    -- scopus_publication_groups, scopus_publications attributes
    FOR cur IN (
      SELECT
        sgr,
        pub_year,
        make_date(pub_year, pub_month, pub_day) AS pub_date,
        scp,
        /*
        Prefer translated if there are *two* "English" titles in dirty data. For example:
        <citation-title>
            <titletext xml:lang="eng" original="n" language="English">Curare and anesthesia.</titletext>
            <titletext original="y" xml:lang="eng" language="English">Curare y anestesia.</titletext>
        </citation-title>
        */
        correspondence_person_indexed_name,
        correspondence_city,
        correspondence_country,
        correspondence_e_address
      FROM xmltable(--
      -- The `xml:` namespace doesn't need to be specified
        XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
        '//bibrecord' PASSING scopus_doc_xml COLUMNS --
          sgr BIGINT PATH 'item-info/itemidlist/itemid[@idtype="SGR"]', --
          pub_year SMALLINT PATH 'head/source/publicationyear/@first', --
          pub_month SMALLINT PATH 'head/source/publicationdate/month', --
          pub_day SMALLINT PATH 'head/source/publicationdate/day', --
          scp BIGINT PATH 'item-info/itemidlist/itemid[@idtype="SCP"]', --
          -- noramlize-space() converts NULLs to empty strings
          correspondence_person_indexed_name TEXT PATH 'head/correspondence/person/ce:indexed-name', --
          correspondence_city TEXT PATH 'head/correspondence/affiliation/city', --
          correspondence_country TEXT PATH 'head/correspondence/affiliation/country', --
          correspondence_e_address TEXT PATH 'head/correspondence/ce:e-address')
    ) LOOP
      INSERT INTO scopus_publication_groups(sgr, pub_year, pub_date)
      VALUES (cur.sgr, cur.pub_year, cur.pub_date)
      ON CONFLICT DO NOTHING;

      INSERT INTO scopus_publications(scp, sgr, correspondence_person_indexed_name, correspondence_city,
                                      correspondence_country, correspondence_e_address)
      VALUES (cur.scp, cur.sgr, cur.correspondence_person_indexed_name, cur.correspondence_city,
              cur.correspondence_country, cur.correspondence_e_address)
      ON CONFLICT DO NOTHING;
    END LOOP;

    -- scopus_publications: concatenated correspondence organizations
    WITH
      cte AS (
        SELECT scp, string_agg(organization, chr(10)) AS correspondence_orgs
        FROM xmltable(--
          XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
          '//bibrecord/head/correspondence/affiliation/organization' PASSING scopus_doc_xml COLUMNS --
          --@formatter:off
          scp BIGINT PATH '../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
          organization TEXT PATH 'normalize-space()'
          --@formatter:on
          )
        GROUP BY scp
      )
    UPDATE scopus_publications sp
    SET correspondence_orgs = cte.correspondence_orgs
    FROM cte
    WHERE sp.scp = cte.scp;

    -- scopus_pub_authors
    INSERT INTO scopus_pub_authors(scp, author_seq, auid, author_indexed_name, author_surname, author_given_name,
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

    -- scopus_references
    CALL update_references(scopus_doc_xml);

    CALL scopus_abstracts_titles_keywords_publication_identifiers(scopus_doc_xml);

  EXCEPTION
    WHEN OTHERS THEN --
      RAISE NOTICE E'ERROR during processing of:\n-----\n%\n-----', scopus_doc_xml;
      RAISE;
  END $block$;

/*
-- scopus_publications: concatenated abstracts
/*
TODO Report. Despite what docs say, the text contents of child elements are *not* concatenated to the result
E.g. abstract TEXT PATH 'head/abstracts/abstract[@xml:lang="eng"]'
*/
SELECT scp, string_agg(abstract, chr(10) || chr(10)) AS abstract
FROM xmltable(--
-- The `xml:` namespace doesn’t need to be specified
  XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
  --@formatter:off
  '//bibrecord/head/abstracts/abstract[@xml:lang="eng"]/ce:para'
'//bibrecord/head/abstracts/abstract[@original="y"]/ce:para'
  PASSING :scopus_doc --
  COLUMNS --

  scp BIGINT PATH '../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
  abstract TEXT PATH 'normalize-space()'
--@formatter:on
  )
GROUP BY scp;
*/
