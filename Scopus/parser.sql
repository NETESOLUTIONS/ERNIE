\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- FIXME For production deployment, INSERTs need tobe converted to MERGEs

CREATE TEMPORARY TABLE stg_scopus_doc (
  scopus_doc_line_num SERIAL,
  scopus_doc_line TEXT
);

-- Import file to a table of lines
\copy stg_scopus_doc(scopus_doc_line) FROM pstdin

-- scopus_publication_groups, scopus_publications attributes
DO $block$
  DECLARE
    scopus_doc TEXT;
    scopus_doc_xml XML;
    cur RECORD;
  BEGIN
    SELECT string_agg(ssd.scopus_doc_line, chr(10) ORDER BY ssd.scopus_doc_line_num) INTO scopus_doc
    FROM stg_scopus_doc ssd;

    SELECT xmlparse(DOCUMENT scopus_doc) INTO scopus_doc_xml
    FROM stg_scopus_doc;

    FOR cur IN (
      SELECT
        sgr,
        pub_year,
        make_date(pub_year, pub_month, pub_day) AS pub_date,
        scp,
        language_code,
        coalesce(citation_title_eng, citation_title_original) AS citation_title,
        coalesce(title_lang_code_eng, title_lang_code_original) AS title_lang_code,
        --   abstract_lang_code,
        correspondence_person_indexed_name,
        correspondence_city,
        correspondence_country,
        correspondence_e_address
      FROM xmltable(--
      -- The `xml:` namespace doesn’t need to be specified
        XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
        '//bibrecord' PASSING scopus_doc_xml COLUMNS --
        --@formatter:off
        -- region scopus_publication_groups
        sgr BIGINT PATH 'item-info/itemidlist/itemid[@idtype="SGR"]',
        pub_year SMALLINT PATH 'head/source/publicationyear/@first',
        pub_month SMALLINT PATH 'head/source/publicationdate/month',
        pub_day SMALLINT PATH 'head/source/publicationdate/day',
        -- endregion

        -- region scopus_publications
        scp BIGINT PATH 'item-info/itemidlist/itemid[@idtype="SCP"]',
        language_code CHAR(3) PATH 'head/citation-info/citation-language/@xml:lang',
        citation_title_eng TEXT PATH 'head/citation-title/titletext[@xml:lang="eng"]',
        citation_title_original TEXT PATH 'head/citation-title/titletext[@original="y"]',
        title_lang_code_eng CHAR(3) PATH 'head/citation-title/titletext[@xml:lang="eng"]/@xml:lang',
        title_lang_code_original CHAR(3) PATH 'head/citation-title/titletext[@original="y"]/@xml:lang',
      --   abstract_lang_code CHAR(3) PATH 'head/abstracts/abstract[@xml:lang="eng"]/@xml:lang,
        correspondence_person_indexed_name TEXT PATH 'head/correspondence/person/ce:indexed-name',
        correspondence_city TEXT PATH 'head/correspondence/affiliation/city',
        correspondence_country TEXT PATH 'head/correspondence/affiliation/country',
        correspondence_e_address TEXT PATH 'head/correspondence/ce:e-address'
        -- endregion
        --@formatter:on
        )
    ) LOOP
      INSERT INTO scopus_publication_groups(sgr, pub_year, pub_date)
      VALUES (cur.sgr, cur.pub_year, cur.pub_date);

      INSERT INTO scopus_publications(scp, sgr, language_code, citation_title, title_lang_code,
                                      correspondence_person_indexed_name, correspondence_city,
                                      correspondence_country, correspondence_e_address)
      VALUES (cur.scp, cur.sgr, cur.language_code, cur.citation_title, cur.title_lang_code,
              cur.correspondence_person_indexed_name, cur.correspondence_city,
              cur.correspondence_country, cur.correspondence_e_address);
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
      );

    -- scopus_references
    INSERT INTO scopus_references(scp, ref_sgr, pub_ref_id)
    SELECT scp, ref_sgr, pub_ref_id
    FROM xmltable(--
      '//bibrecord/tail/bibliography/reference' PASSING scopus_doc_xml COLUMNS --
      --@formatter:off
      scp BIGINT PATH '../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
      ref_sgr BIGINT PATH 'ref-info/refd-itemidlist/itemid[@idtype="SGR"]',
      pub_ref_id SMALLINT PATH '@id'
      --@formatter:on
      );
  EXCEPTION
    WHEN OTHERS THEN --
      RAISE NOTICE E'ERROR during processing of:\n-----\n%\n-----', scopus_doc;
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
