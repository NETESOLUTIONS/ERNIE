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
               try_parse(sort_year, sort_month, sort_day) AS date_sort,
               scp,
               correspondence_person_indexed_name,
               correspondence_city,
               correspondence_country,
               correspondence_e_address,
               citation_type,
               pub_type,
               citation_language,
               process_stage,
               state

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
                    citation_language XML PATH 'bibrecord/head/citation-info/citation-language/@language',
                    pub_type TEXT PATH 'ait:process-info/ait:status/@type',
                    process_stage TEXT PATH 'ait:process-info/ait:status/@stage',
                    state TEXT PATH 'ait:process-info/ait:status/@state',
                    sort_year SMALLINT PATH 'ait:process-info/ait:date-sort/@year',
                    sort_month SMALLINT PATH 'ait:process-info/ait:date-sort/@month',
                    sort_day SMALLINT PATH 'ait:process-info/ait:date-sort/@day')
    )
        LOOP
            INSERT INTO stg_scopus_publication_groups(sgr, pub_year)
            VALUES (cur.sgr, cur.pub_year);

            INSERT INTO stg_scopus_publications(scp, sgr, correspondence_person_indexed_name, correspondence_city,
                                                correspondence_country, correspondence_e_address, pub_type,
                                                citation_type,
                                                citation_language, process_stage, state, date_sort)
            VALUES (cur.scp, cur.sgr, cur.correspondence_person_indexed_name, cur.correspondence_city,
                    cur.correspondence_country, cur.correspondence_e_address, cur.pub_type, cur.citation_type,
                    cur.citation_language, cur.process_stage, cur.state, cur.date_sort);
        END LOOP;
END ;
$$;