\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- scopus_publication_groups, scopus_publications attributes
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
  trim(coalesce(citation_title_eng_translated, citation_title_eng_original, citation_title_original)) AS citation_title,
  CASE
    WHEN coalesce(citation_title_eng_translated, citation_title_eng_original) IS NOT NULL THEN 'eng'
    ELSE citation_title_original_lang_code
  END AS citation_title_lang_code,
  correspondence_person_indexed_name,
  correspondence_city,
  correspondence_country,
  correspondence_e_address
FROM xmltable(--
-- The `xml:` namespace doesn't need to be specified
  XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
  '//bibrecord' PASSING :scopus_doc_xml COLUMNS --
    sgr BIGINT PATH 'item-info/itemidlist/itemid[@idtype="SGR"]', --
    pub_year SMALLINT PATH 'head/source/publicationyear/@first', --
    pub_month SMALLINT PATH 'head/source/publicationdate/month', --
    pub_day SMALLINT PATH 'head/source/publicationdate/day', --
    scp BIGINT PATH 'item-info/itemidlist/itemid[@idtype="SCP"]', --
    -- noramlize-space() converts NULLs to empty strings
    citation_title_eng_original TEXT PATH 'head/citation-title/titletext[@xml:lang="eng"][@original="y"]', --
    citation_title_eng_translated TEXT PATH 'head/citation-title/titletext[@xml:lang="eng"][@original="n"]', --
    citation_title_original TEXT PATH 'head/citation-title/titletext[@original="y"]', --
    citation_title_original_lang_code TEXT PATH 'head/citation-title/titletext[@original="y"]/@xml:lang', --
    correspondence_person_indexed_name TEXT PATH 'head/correspondence/person/ce:indexed-name', --
    correspondence_city TEXT PATH 'head/correspondence/affiliation/city', --
    correspondence_country TEXT PATH 'head/correspondence/affiliation/country', --
    correspondence_e_address TEXT PATH 'head/correspondence/ce:e-address');

-- TODO model multiple pub languages
-- language_code CHAR(3) PATH 'head/citation-info/citation-language/@xml:lang',

-- scopus_publications: concatenated correspondence organizations
SELECT scp, string_agg(organization, chr(10)) AS correspondence_orgs
FROM xmltable(--
  XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
  '//bibrecord/head/correspondence/affiliation/organization' PASSING :scopus_doc_xml COLUMNS --
  --@formatter:off
  scp BIGINT PATH '../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
  organization TEXT PATH 'normalize-space()'
  --@formatter:on
  )
GROUP BY scp;

-- scopus_publications: concatenated abstracts
/*
TODO Report. Despite what docs say, the text contents of child elements are *not* concatenated to the result
E.g. abstract TEXT PATH 'head/abstracts/abstract[@xml:lang="eng"]'
*/
--@formatter:off
SELECT scp, string_agg(abstract, chr(10) || chr(10)) AS abstract
FROM xmltable(--
    -- The `xml:` namespace doesn't need to be specified
    XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
    '//bibrecord/head/abstracts/abstract[@xml:lang="eng"]/ce:para' PASSING :scopus_doc_xml
    COLUMNS 00
      scp BIGINT PATH '../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
      abstract TEXT PATH 'normalize-space()'
  )
GROUP BY scp;
--@formatter:on

-- scopus_pub_authors
SELECT scp, author_seq, auid, author_indexed_name, author_surname, author_given_name, author_initials, author_e_address
FROM xmltable(--
  XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
  '//bibrecord/head/author-group/author' PASSING :scopus_doc_xml COLUMNS --
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
SELECT scp, ref_sgr, pub_ref_id
FROM xmltable(--
  '//bibrecord/tail/bibliography/reference' PASSING :scopus_doc_xml COLUMNS --
  --@formatter:off
  scp BIGINT PATH '../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
  ref_sgr BIGINT PATH 'ref-info/refd-itemidlist/itemid[@idtype="SGR"]',
  pub_ref_id SMALLINT PATH '@id'
  --@formatter:on
  );