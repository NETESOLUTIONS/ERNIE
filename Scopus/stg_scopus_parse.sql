set search_path='jenkins';
create or replace procedure stg_scopus_parse_abstracts_and_titles(scopus_doc_xml xml)
    language plpgsql
as
$$
BEGIN
    -- scopus_abstracts
    INSERT INTO stg_scopus_abstracts(scp, abstract_language, abstract_source)
    SELECT DISTINCT scp,
           abstract_language,
           abstract_source
    FROM xmltable(
                 XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
                 '//bibrecord/head/abstracts/abstract/ce:para' PASSING scopus_doc_xml COLUMNS
                     scp BIGINT PATH '../../../../item-info/itemidlist/itemid[@idtype="SCP"]',
--         abstract_text TEXT PATH 'normalize-space()',
                     abstract_language TEXT PATH '../@xml:lang',
                     abstract_source TEXT PATH '../@source'
             );

    -- scopus_titles
    INSERT INTO stg_scopus_titles(scp, title, language)
    SELECT scp,
           max(title) as title,
           max(language) as language
    FROM xmltable(
                 XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
                 '//bibrecord/head/citation-title/titletext' PASSING scopus_doc_xml COLUMNS
                     scp BIGINT PATH '../../../item-info/itemidlist/itemid[@idtype="SCP"]',
                     title TEXT PATH 'normalize-space()',
                     language TEXT PATH '@language'
             )
    GROUP BY scp;
--     COMMIT;
END;
$$;


create procedure stg_scopus_parse_authors_and_affiliations(scopus_doc_xml xml)
    language plpgsql
as
$$
BEGIN
    -- scopus_authors

    INSERT INTO stg_scopus_authors(scp, author_seq, auid, author_indexed_name, author_surname, author_given_name,
                               author_initials, author_e_address, author_rank)
                SELECT DISTINCT ON (scp, author_seq, auid)
                scp,
                author_seq,
                auid,
                author_indexed_name,
                max(author_surname)    as author_surname,
                max(author_given_name) as author_given_name,
                max(author_initials)   as author_initials,
                max(author_e_address)  as author_e_address,
                ROW_NUMBER() over (PARTITION BY scp ORDER BY author_seq, author_indexed_name) as author_rank
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
                GROUP BY scp, author_seq, auid, author_indexed_name;
--                                                                   COMMIT;
    -- scopus_affiliations
INSERT INTO stg_scopus_affiliations(scp, affiliation_no, afid, dptid, city_group, state, postal_code, country_code,
                                    country)

    SELECT scp,
           affiliation_no,
           afid,
           dptid,
           coalesce(city_group, city) AS city_group,
           state,
           postal_code,
           country_code,
           country
    FROM xmltable(--
                 '//bibrecord/head/author-group/affiliation' PASSING scopus_doc_xml COLUMNS
                scp BIGINT PATH '../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
                affiliation_no FOR ORDINALITY,
                afid BIGINT PATH '@afid',
                dptid BIGINT PATH '@dptid',
                city_group TEXT PATH 'city-group',
                state TEXT PATH 'state',
                postal_code TEXT PATH 'postal-code',
                city TEXT PATH 'city',
                country_code TEXT PATH '@country',
                country TEXT PATH 'country'
             );


    -- scopus_author_affiliations
    INSERT INTO stg_scopus_author_affiliations(scp, author_seq, affiliation_no)
    SELECT DISTINCT t1.scp,
           t1.author_seq,
           t2.affiliation_no
    FROM xmltable(--
                 '//bibrecord/head/author-group/author' PASSING scopus_doc_xml COLUMNS --
                scp BIGINT PATH '../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
                author_seq SMALLINT PATH '@seq'
             ) as t1,
         xmltable(--
                 '//bibrecord/head/author-group/affiliation' PASSING scopus_doc_xml COLUMNS --
             affiliation_no FOR ORDINALITY
             ) as t2
    WHERE XMLEXISTS('//bibrecord/head/author-group/affiliation' PASSING scopus_doc_xml)
    ON CONFLICT (scp, author_seq, affiliation_no) DO UPDATE SET author_seq=excluded.author_seq, affiliation_no=excluded.affiliation_no;
--     COMMIT;
END;
$$;

create or replace procedure stg_scopus_parse_chemical_groups(scopus_doc_xml xml)
    language plpgsql
as
$$
DECLARE
    cur RECORD;
    ELSEVIER_BIBLIO_DB_DIVISION_CHEMICAL_SRC CONSTANT VARCHAR = 'esbd';
  BEGIN
    --scopus_chemical_groups
    FOR cur IN(
      SELECT
        scp,
        coalesce(chemicals_source,ELSEVIER_BIBLIO_DB_DIVISION_CHEMICAL_SRC) as chemicals_source,
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
        INSERT INTO stg_scopus_chemical_groups(scp, chemicals_source,chemical_name, cas_registry_number)
        VALUES(cur.scp,cur.chemicals_source,cur.chemical_name,cur.cas_registry_number);
--         COMMIT;
    END LOOP;
  END;
$$;

CREATE OR REPLACE PROCEDURE stg_scopus_parse_grants(scopus_doc_xml XML)
language plpgsql
AS
$$
BEGIN
    -- scopus_grants
INSERT
INTO stg_scopus_grants(scp, grant_id, grantor_acronym, grantor,
                   grantor_country_code, grantor_funder_registry_id)
SELECT
        scp,
       coalesce(grant_id, '') AS grant_id,
       max(grantor_acronym) as grantor_acronym,
       grantor,
       max(grantor_country_code) as grantor_country_code,
       max(grantor_funder_registry_id) as grantor_funder_registry_id
FROM xmltable(--
             '//bibrecord/head/grantlist/grant' PASSING scopus_doc_xml COLUMNS --
            scp BIGINT PATH '../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
            grant_id TEXT PATH 'grant-id',
            grantor_acronym TEXT PATH 'grant-acronym',
            grantor TEXT PATH 'grant-agency',
            grantor_country_code TEXT PATH 'grant-agency/@iso-code',
            grantor_funder_registry_id TEXT PATH 'grant-agency-id'
         )
GROUP BY scp, grant_id, grantor;
--                                           COMMIT;
-- scopus_grant_acknowledgements
INSERT INTO scopus_grant_acknowledgements(scp, grant_text)

SELECT scp,
       grant_text
FROM xmltable(--
             '//bibrecord/head/grantlist/grant-text' PASSING scopus_doc_xml COLUMNS --
            scp BIGINT PATH '../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
            grant_text TEXT PATH '.'
         );
-- COMMIT;
END;
$$;


create or replace procedure stg_scopus_parse_keywords(scopus_doc_xml xml)
    language plpgsql
as
$$
BEGIN
  INSERT
  INTO stg_scopus_keywords(
    scp, keyword)
  SELECT DISTINCT scp, keyword
  FROM
    xmltable(XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
             '//bibrecord/head/citation-info/author-keywords/author-keyword' PASSING scopus_doc_xml
             COLUMNS scp BIGINT PATH '../../../../item-info/itemidlist/itemid[@idtype="SCP"]', keyword TEXT PATH '.');
  --   COMMIT;
END;
$$;

create or replace procedure stg_scopus_parse_pub_details_subjects_and_classes(scopus_doc_xml xml)
    language plpgsql
as
$$
BEGIN
    -- scopus_source_publication_details
    INSERT INTO stg_scopus_source_publication_details(scp, issue, volume, first_page, last_page, publication_year,
                                                  publication_date, conf_code, conf_name)

    SELECT DISTINCT scp,
                    issue,
                    volume,
                    first_page,
                    last_page,
                    publication_year,
                    try_parse(pub_year, pub_month, pub_day) AS publication_date,
                    conf_code                               AS conf_code,
                    conf_name                               AS conf_name
    FROM xmltable(--
                 '//bibrecord/head/source' PASSING scopus_doc_xml COLUMNS --
                scp BIGINT PATH '../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
                issue TEXT PATH 'volisspag/voliss/@issue',
                volume TEXT PATH 'volisspag/voliss/@volume',
                first_page TEXT PATH 'volisspag/pagerange/@first',
                last_page TEXT PATH 'volisspag/pagerange/@last',
                publication_year SMALLINT PATH 'publicationyear/@first',
                pub_year SMALLINT PATH 'publicationdate/year',
                pub_month SMALLINT PATH 'publicationdate/month',
                pub_day SMALLINT PATH 'publicationdate/day',
                conf_code TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/confcode',
                conf_name TEXT PATH 'normalize-space(additional-srcinfo/conferenceinfo/confevent/confname)'
             );

    -- scopus_subjects
    INSERT INTO stg_scopus_subjects (scp, subj_abbr)

    SELECT scp,
           subj_abbr
    FROM xmltable(--
                 '//bibrecord/head/enhancement/classificationgroup/classifications[@type="SUBJABBR"]/classification'
                 PASSING scopus_doc_xml COLUMNS --
                     scp BIGINT PATH '../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
                     subj_abbr SCOPUS_SUBJECT_ABBRE_TYPE PATH '.'
             );

    -- scopus_subject_keywords
    INSERT INTO stg_scopus_subject_keywords (scp, subject)

    SELECT scp,
           subject
    FROM xmltable(--
                 '//bibrecord/head/enhancement/classificationgroup/classifications[@type="SUBJECT"]/classification'
                 PASSING scopus_doc_xml COLUMNS --
                     scp BIGINT PATH '../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
                     subject TEXT PATH '.'
             );
--     COMMIT;

    -- scopus_classes
    INSERT INTO stg_scopus_classes(scp, class_type, class_code)
    SELECT DISTINCT scp,
           class_type,
           coalesce(classification_code, classification) AS class_code
    FROM xmltable(--
                 '//bibrecord/head/enhancement/classificationgroup/classifications[not(@type="SUBJABBR" or @type="SUBJECT")]/classification'
                 PASSING scopus_doc_xml COLUMNS --
                     scp BIGINT PATH '../../../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
                     class_type TEXT PATH '../@type',
                     classification_code TEXT PATH 'classification-code',
                     classification TEXT PATH '.'
             );
--     COMMIT;

    -- scopus_classification_lookup
    INSERT INTO stg_scopus_classification_lookup(class_type, class_code, description)
    SELECT DISTINCT class_type,
           class_code,
           description
    FROM xmltable(--
                 '//bibrecord/head/enhancement/classificationgroup/classifications[not(@type="ASJC" or @type="SUBJABBR" or @type="SUBJECT")]/classification/classification-code'
                 PASSING scopus_doc_xml COLUMNS --
                     class_type TEXT PATH '../../@type',
                     class_code TEXT PATH '.',
                     description TEXT PATH 'following-sibling::classification-description'
             );
--     COMMIT;
END;
$$;

create procedure stg_scopus_parse_publication_and_group(scopus_doc_xml xml)
    language plpgsql
as
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
            INSERT INTO stg_scopus_publication_groups(sgr, pub_year)
            VALUES (cur.sgr, cur.pub_year);

            INSERT INTO stg_scopus_publications(scp, sgr, correspondence_person_indexed_name, correspondence_city,
                                            correspondence_country, correspondence_e_address, citation_type)
            VALUES (cur.scp, cur.sgr, cur.correspondence_person_indexed_name, cur.correspondence_city,
                    cur.correspondence_country, cur.correspondence_e_address, cur.citation_type);
        COMMIT;
        END LOOP;

    -- scopus_publications: concatenated correspondence organizations
END;
$$;

create or replace procedure stg_scopus_parse_publication_identifiers(scopus_doc_xml xml)
    language plpgsql
as
$$
BEGIN
      INSERT INTO stg_scopus_publication_identifiers(scp, document_id, document_id_type)
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
        );
      --       COMMIT;
  END;
$$;


create procedure stg_scopus_parse_references(input_xml xml)
    language plpgsql
as
$$
DECLARE
    v_state   TEXT;
    v_msg     TEXT;
    v_detail  TEXT;
    v_hint    TEXT;
    v_context TEXT;
  BEGIN
--     BEGIN
    INSERT INTO stg_scopus_references(scp,ref_sgr,citation_text)
    SELECT
          xmltable.scp AS scp,
          xmltable.ref_sgr AS ref_sgr,
          --row_number() over (PARTITION BY scp  ORDER BY xmltable.pub_ref_id DESC NULLS LAST, COALESCE(xmltable.ref_fulltext,xmltable.ref_text) ASC ) as pub_ref_id, -- introduced ERNIE team produced pub_ref_id, but be on alert from Elsevier to determine if this is actually fair to do
          max(COALESCE(xmltable.ref_fulltext,xmltable.ref_text)) AS citation_text
     FROM
     XMLTABLE('//bibrecord/tail/bibliography/reference' PASSING input_xml
              COLUMNS
                scp BIGINT PATH '//itemidlist/itemid[@idtype="SCP"]/text()',
                ref_sgr BIGINT PATH 'ref-info/refd-itemidlist/itemid[@idtype="SGR"]/text()',
                --pub_ref_id INT PATH'@id',
                ref_fulltext TEXT PATH 'ref-fulltext/text()[1]', -- should work around situations where additional tags are included in the text field (e.g. a <br/> tag). Otherwise, would encounter a "more than one value returned by column XPath expression" error.
                ref_text TEXT PATH 'ref-info/ref-text/text()[1]'
                )
    GROUP BY scp, ref_sgr;
    EXCEPTION WHEN OTHERS THEN

    get stacked diagnostics
        v_state   = returned_sqlstate,
        v_msg     = message_text,
        v_detail  = pg_exception_detail,
        v_hint    = pg_exception_hint,
        v_context = pg_exception_context;

    RAISE NOTICE E'GOT EXCEPTION:
        STATE  : %
        MESSAGE: %
        DETAIL : %
        HINT   : %
        CONTEXT: %', v_state, v_msg, v_detail, v_hint, v_context;

    RAISE NOTICE E'GOT EXCEPTION: SQLSTATE: %, SQLERRM: % ', SQLSTATE, SQLERRM;
      CALL stg_scopus_parse_references_one_by_one(input_xml);
--     COMMIT;
    END;
-- END;
$$;

create or replace procedure stg_scopus_parse_references_one_by_one(input_xml xml)
    language plpgsql
as
$$
DECLARE row RECORD;
  BEGIN
      FOR row IN
      SELECT
            xmltable.scp AS scp,
            xmltable.ref_sgr AS ref_sgr,
            --row_number() over (PARTITION BY scp  ORDER BY xmltable.pub_ref_id DESC NULLS LAST, COALESCE(xmltable.ref_fulltext,xmltable.ref_text) ASC ) as pub_ref_id, -- introduced ERNIE team produced pub_ref_id, but be on alert from Elsevier to determine if this is actually fair to do
            COALESCE(xmltable.ref_fulltext,xmltable.ref_text) AS citation_text
       FROM
       XMLTABLE('//bibrecord/tail/bibliography/reference' PASSING input_xml
                COLUMNS
                  scp BIGINT PATH '//itemidlist/itemid[@idtype="SCP"]/text()',
                  ref_sgr BIGINT PATH 'ref-info/refd-itemidlist/itemid[@idtype="SGR"]/text()',
                  --pub_ref_id INT PATH'@id',
                  ref_fulltext TEXT PATH 'ref-fulltext/text()[1]', -- should work around situations where additional tags are included in the text field (e.g. a <br/> tag). Otherwise, would encounter a "more than one value returned by column XPath expression" error.
                  ref_text TEXT PATH 'ref-info/ref-text/text()[1]'
                  )
      LOOP
        BEGIN
          INSERT INTO stg_scopus_references VALUES (row.scp,row.ref_sgr,row.citation_text) ON CONFLICT (scp, ref_sgr) DO UPDATE SET citation_text=excluded.citation_text;
        -- Exception commented out so that error bubbles up
        /*EXCEPTION WHEN OTHERS THEN
          RAISE NOTICE 'CANNOT INSERT VALUES (scp=%,ref_sgr=%,pub_ref_id=%)',row.scp,row.ref_sgr,row.pub_ref_id;
          CONTINUE;*/
        END;
--         COMMIT;
      END LOOP;
  END;
$$;

create or replace procedure scopus_parse_source_and_conferences(scopus_doc_xml xml)
    language plpgsql
as
$$
DECLARE db_id INTEGER;
BEGIN
        INSERT INTO stg_scopus_sources(source_id, issn_main, isbn_main, source_type, source_title,
                                   coden_code, publisher_name, publisher_e_address, pub_date)
        SELECT  coalesce(source_id, '')                  AS source_id,
                        coalesce(issn, '')                      AS issn_main,
                        coalesce(isbn, '')                      AS isbn_main,
                        string_agg(source_type, ' ') as source_type,
                        string_agg(source_title, ' ') as source_title,
                        string_agg(coden_code, ' ') as coden_code,
                        string_agg(publisher_name, ' ') as publisher_name,
                        string_agg(publisher_e_address, ' ') as publisher_e_address,
                        max(try_parse(pub_year, pub_month, pub_day)) AS pub_date
        FROM xmltable(--
                     XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
                     '//bibrecord/head/source' PASSING scopus_doc_xml COLUMNS --
                --@formatter:off
                         source_id TEXT PATH '@srcid',
                         issn TEXT PATH 'issn[1]',
                         isbn TEXT PATH 'isbn[1]',
                         source_type TEXT PATH '@type',
                         source_title TEXT PATH 'sourcetitle',
                         coden_code TEXT PATH 'codencode',
                         publisher_name TEXT PATH 'publisher/publishername',
                         publisher_e_address TEXT PATH 'publisher/ce:e-address',
                         pub_year SMALLINT PATH 'publicationdate/year', --
                         pub_month SMALLINT PATH 'publicationdate/month', --
                         pub_day SMALLINT PATH 'publicationdate/day' --
                 )
        WHERE source_id != ''
           OR issn != ''
           OR XMLEXISTS('//bibrecord/head/source/isbn' PASSING scopus_doc_xml)
        group by source_id, issn_main, isbn_main
        RETURNING ernie_source_id into db_id;
                COMMIT;
    -- scopus_isbns
    INSERT INTO stg_scopus_isbns(ernie_source_id, isbn, isbn_length, isbn_type, isbn_level)
    SELECT DISTINCT db_id AS ernie_source_id,
           isbn,
           isbn_length,
           coalesce(isbn_type, '') as isbn_type,
           isbn_level
    FROM xmltable(--
                 '//bibrecord/head/source/isbn' PASSING scopus_doc_xml COLUMNS --
                isbn TEXT PATH '.',
                isbn_length SMALLINT PATH '@length',
                isbn_type TEXT PATH '@type',
                isbn_level TEXT PATH '@level'
             )

                                                      COMMIT;
    -- scopus_issns
    INSERT INTO stg_scopus_issns(ernie_source_id, issn, issn_type)
    SELECT db_id                   AS ernie_source_id,
           issn,
           coalesce(issn_type, '') AS issn_type
    FROM xmltable(--
                 '//bibrecord/head/source/issn' PASSING scopus_doc_xml COLUMNS --
                issn TEXT PATH '.',
                issn_type TEXT PATH '@type'
             )

                                                                 COMMIT ;


    -- scopus_conference_events
    INSERT INTO stg_scopus_conference_events(conf_code, conf_name, conf_address, conf_city, conf_postal_code,
                                         conf_start_date,
                                         conf_end_date, conf_number, conf_catalog_number)

    SELECT coalesce(conf_code, '')           AS conf_code,
           coalesce(conf_name, '')           AS conf_name,
           conf_address,
           conf_city,
           conf_postal_code,
           try_parse(s_year, s_month, s_day) AS conf_start_date,
           try_parse(e_year, e_month, e_day) AS conf_end_date,
           conf_number,
           conf_catalog_number
    FROM xmltable(--
                 '//bibrecord/head/source' PASSING scopus_doc_xml COLUMNS --
                conf_code TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/confcode',
                conf_name TEXT PATH 'normalize-space(additional-srcinfo/conferenceinfo/confevent/confname)',
                conf_address TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/conflocation/address-part',
                conf_city TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/conflocation/city-group',
                conf_postal_code TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/conflocation/postal-code',
                s_year SMALLINT PATH 'additional-srcinfo/conferenceinfo/confevent/confdate/startdate/@year',
                s_month SMALLINT PATH 'additional-srcinfo/conferenceinfo/confevent/confdate/startdate/@month',
                s_day SMALLINT PATH 'additional-srcinfo/conferenceinfo/confevent/confdate/startdate/@day',
                e_year SMALLINT PATH 'additional-srcinfo/conferenceinfo/confevent/confdate/enddate/@year',
                e_month SMALLINT PATH 'additional-srcinfo/conferenceinfo/confevent/confdate/enddate/@month',
                e_day SMALLINT PATH 'additional-srcinfo/conferenceinfo/confevent/confdate/enddate/@day',
                conf_number TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/confnumber',
                conf_catalog_number TEXT PATH 'additional-srcinfo/conferenceinfo/confevent/confcatnumber'
             )
                                                     COMMIT;


    -- scopus_conf_proceedings
    INSERT INTO stg_scopus_conf_proceedings(ernie_source_id, conf_code, conf_name, proc_part_no, proc_page_range,
                                        proc_page_count)
    SELECT db_id                   AS ernie_source_id,
           coalesce(conf_code, '') AS conf_code,
           coalesce(conf_name, '') AS conf_name,
           proc_part_no,
           proc_page_range,
           CASE
               WHEN proc_page_count LIKE '%p' THEN RTRIM(proc_page_count, 'p') :: SMALLINT
               WHEN proc_page_count LIKE '%p.' THEN RTRIM(proc_page_count, 'p.') :: SMALLINT
               WHEN proc_page_count ~ '[^0-9]' THEN NULL
               ELSE proc_page_count :: SMALLINT
               END
    FROM xmltable(--
                 '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication' PASSING scopus_doc_xml
                 COLUMNS --
                     conf_code TEXT PATH 'preceding-sibling::confevent/confcode',
                     conf_name TEXT PATH 'normalize-space(preceding-sibling::confevent/confname)',
                     proc_part_no TEXT PATH 'procpartno',
                     proc_page_range TEXT PATH 'procpagerange',
                     proc_page_count TEXT PATH 'procpagecount'
             )
    WHERE proc_part_no IS NOT NULL
       OR proc_page_range IS NOT NULL
       OR proc_page_count IS NOT NULL;
    COMMIT;
    -- scopus_conf_editors
    INSERT INTO stg_scopus_conf_editors(ernie_source_id, conf_code, conf_name, indexed_name, role_type,
                                    initials, surname, given_name, degree, suffix)
    SELECT db_id                          AS ernie_source_id,
           coalesce(conf_code, '')        AS conf_code,
           coalesce(conf_name, '')        AS conf_name,
           coalesce(indexed_name, '')     AS indexed_name,
           coalesce(edit_role, edit_type) AS role_type,
           initials,
           surname,
           given_name,
           degree,
           suffix
    FROM xmltable(--
                 XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
                 '//bibrecord/head/source/additional-srcinfo/conferenceinfo/confpublication/confeditors/editors/editor' --
                 PASSING scopus_doc_xml COLUMNS --
                     conf_code TEXT PATH '../../../preceding-sibling::confevent/confcode',
                     conf_name TEXT PATH 'normalize-space(../../../preceding-sibling::confevent/confname)',
                     indexed_name TEXT PATH 'ce:indexed-name',
                     edit_role TEXT PATH '@role',
                     edit_type TEXT PATH '@type',
                     initials TEXT PATH 'initials',
                     surname TEXT PATH 'ce:surname',
                     given_name TEXT PATH 'ce:given-name',
                     degree TEXT PATH 'ce:degrees',
                     suffix TEXT PATH 'ce:suffix'
             )
    WHERE db_id IS NOT NULL;
COMMIT;
END;
$$;