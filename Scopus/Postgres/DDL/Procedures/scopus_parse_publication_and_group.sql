\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE scopus_parse_publication_and_group(scopus_doc_xml XML)
AS
$$
  DECLARE
    cur RECORD;
  BEGIN
    -- scopus_publication_groups, scopus_publications attributes
    FOR cur IN (
      SELECT sgr,
             pub_year,
--              try_parse(pub_year, pub_month, pub_day) AS pub_date,
             scp,
             correspondence_person_indexed_name,
             correspondence_city,
             correspondence_country,
             correspondence_e_address,
             citation_type
      FROM xmltable(--
      -- The `xml:` namespace doesn't need to be specified
               XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
               '//bibrecord' PASSING scopus_doc_xml COLUMNS --
                 sgr BIGINT PATH 'item-info/itemidlist/itemid[@idtype="SGR"]', --
                 pub_year SMALLINT PATH 'head/source/publicationyear/@first', --
                 scp BIGINT PATH 'item-info/itemidlist/itemid[@idtype="SCP"]', --
            -- noramlize-space() converts NULLs to empty strings
                 correspondence_person_indexed_name TEXT PATH 'head/correspondence/person/ce:indexed-name', --
                 correspondence_city TEXT PATH 'head/correspondence/affiliation/city', --
                 correspondence_country TEXT PATH 'head/correspondence/affiliation/country', --
                 correspondence_e_address TEXT PATH 'head/correspondence/ce:e-address',
                 citation_type TEXT PATH 'head/citation-info/citation-type/@code')
    )
      LOOP
        INSERT INTO scopus_publication_groups(sgr, pub_year)
        VALUES (cur.sgr, cur.pub_year)
        ON CONFLICT UPDATE DO  cur.sgr=excluded.sgr, cur.pub_year=excluded.pub_year;

        INSERT INTO scopus_publications(scp, sgr, correspondence_person_indexed_name, correspondence_city,
                                        correspondence_country, correspondence_e_address, citation_type)
        VALUES (cur.scp, cur.sgr, cur.correspondence_person_indexed_name, cur.correspondence_city,
                cur.correspondence_country, cur.correspondence_e_address, cur.citation_type)
        ON CONFLICT UPDATE DO cur.scp=excluded.scp, cur.sgr=excluded.sgr,
        cur.correspondence_person_indexed_name=excluded.correspondence_person_indexed_name,
        cur.correspondence_city=excluded.correspondence_city, cur.correspondence_country=excluded.correspondence_country,
        cur.correspondence_e_address=excluded.correspondence_e_address, cur.citation=excluded.citation_type ;
      END LOOP;

    -- scopus_publications: concatenated correspondence organizations
    WITH cte AS (
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
  END;
$$
  LANGUAGE plpgsql;
