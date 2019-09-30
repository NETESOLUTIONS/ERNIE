\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE stg_scopus_parse_publication_and_group(scopus_doc_xml XML)
    LANGUAGE plpgsql AS
$$
DECLARE
    cur RECORD;
BEGIN
    -- scopus_publication_groups, scopus_publications attributes
    FOR cur IN (
        SELECT sgr,
               pub_year,
               scp,
               correspondence_person_indexed_name,
               correspondence_city,
               correspondence_country,
               correspondence_e_address,
               citation_type,
               citation_language
        FROM xmltable(--
-- The `xml:` namespace doesn't need to be specified
                XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce, 'http://www.elsevier.com/xml/ani/ait' as ait), --
                '//item' PASSING scopus_doc_xml COLUMNS --
                    sgr BIGINT PATH 'bibrecord/item-info/itemidlist/itemid[@idtype="SGR"]', --
                    pub_year SMALLINT PATH 'bibrecord/head/source/publicationyear/@first', --
                    scp BIGINT PATH 'bibrecord/item-info/itemidlist/itemid[@idtype="SCP"]', --
                    -- noramlize-space() converts NULLs to empty strings
                    correspondence_person_indexed_name TEXT PATH 'bibrecord/head/correspondence/person/ce:indexed-name', --
                    correspondence_city TEXT PATH 'bibrecord/head/correspondence/affiliation/city', --
                    correspondence_country TEXT PATH 'bibrecord/head/correspondence/affiliation/country', --
                    correspondence_e_address TEXT PATH 'bibrecord/head/correspondence/ce:e-address', --
                    citation_type TEXT PATH 'bibrecord/head/citation-info/citation-type/@code', --
                    citation_language XML PATH 'bibrecord/head/citation-info/citation-language/@language'
                    )
    )
        LOOP
            INSERT INTO stg_scopus_publication_groups(sgr, pub_year)
            VALUES (cur.sgr, cur.pub_year);

            INSERT INTO stg_scopus_publications(scp, sgr, correspondence_person_indexed_name, correspondence_city,
                                                correspondence_country, correspondence_e_address,
                                                citation_type,
                                                citation_language)
            VALUES (cur.scp, cur.sgr, cur.correspondence_person_indexed_name, cur.correspondence_city,
                    cur.correspondence_country, cur.correspondence_e_address,  cur.citation_type,
                    cur.citation_language);
        END LOOP;
END ;
$$;