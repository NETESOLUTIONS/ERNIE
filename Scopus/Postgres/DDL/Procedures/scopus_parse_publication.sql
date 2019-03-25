\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE scopus_parse_publication(scopus_doc_xml XML)
AS $$
  DECLARE
    cur RECORD;
  BEGIN
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

    UPDATE scopus_publications sp
    SET pub_type = singular.pub_type,
        process_stage = singular.process_stage,
        state = singular.state,
        date_sort = singular.date_sort
    FROM (SELECT scp, pub_type, process_stage, state, make_date(sort_year, sort_month, sort_day) AS date_sort
          FROM xmltable(--
               XMLNAMESPACES ('http://www.elsevier.com/xml/ani/ait' AS ait), --
               '//ait:process-info' PASSING scopus_doc_xml COLUMNS --
                scp BIGINT PATH '//bibrecord/item-info/itemidlist/itemid[@idtype="SCP"]',
                pub_type TEXT PATH 'ait:status/@type',
                process_stage TEXT PATH 'ait:status/@stage',
                state TEXT PATH 'ait:status/@state',
                sort_year SMALLINT PATH 'ait:date-sort/@year',
                sort_month SMALLINT PATH 'ait:date-sort/@month',
                sort_day SMALLINT PATH 'ait:date-sort/@day')
         ) AS singular
    WHERE sp.scp = singular.scp;

  END;
  $$
  LANGUAGE plpgsql;