set search_path='jenkins';
\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';


create procedure stg_scopus_merge_abstracts_and_titles()
    language plpgsql
as
$$
BEGIN
    INSERT INTO scopus_abstracts(scp, abstract_language, abstract_source)
    SELECT DISTINCT stg.scp,
           stg.abstract_language,
           stg.abstract_source
    FROM stg_scopus_abstracts stg
    ON CONFLICT (scp,abstract_language) DO UPDATE SET abstract_source=excluded.abstract_source;
-----------------------------------------
    INSERT INTO scopus_titles(scp, title, language)
    SELECT stg.scp,
           max(title) as title,
           max(language) as language
    FROM stg_scopus_titles stg
    GROUP BY scp
    ON CONFLICT (scp, language) DO UPDATE SET title=excluded.title;
END
$$;

create or replace procedure stg_scopus_merge_authors_and_affiliations()
    language plpgsql
as
$$
BEGIN
    insert into scopus_authors(scp, author_seq, auid, author_indexed_name, author_surname, author_given_name,
                               author_initials, author_e_address, author_rank)
    SELECT scp,
           author_seq,
           auid,
           author_indexed_name,
           max(author_surname)    as author_surname,
            max(author_given_name) as author_given_name,
                max(author_initials)   as author_initials,
                max(author_e_address)  as author_e_address,
                ROW_NUMBER() over (PARTITION BY scp ORDER BY author_seq, author_indexed_name) as author_rank
    FROM stg_scopus_authors stg
        GROUP BY scp, author_seq, auid, author_indexed_name

    ON CONFLICT (scp, author_seq) DO UPDATE SET auid=excluded.auid,
                                                author_surname=excluded.author_surname,
                                                author_given_name=excluded.author_given_name,
                                                author_indexed_name=excluded.author_indexed_name,
                                                author_initials=excluded.author_initials,
                                                author_e_address=excluded.author_e_address,
                                                author_rank=excluded.author_rank;
    -- scopus_affiliations
---------------------------------------
    insert into scopus_affiliations(scp, affiliation_no, afid, dptid, city_group, state, postal_code, country_code,
                                    country)
    SELECT scp,
           affiliation_no,
           afid,
           dptid,
           city_group,
           state,
           postal_code,
           country_code,
           country
    FROM stg_scopus_affiliations
    ON CONFLICT (scp, affiliation_no) DO UPDATE SET scp=excluded.scp,
                                                    affiliation_no=excluded.affiliation_no,
                                                    afid=excluded.afid,
                                                    dptid=excluded.dptid,
                                                    city_group=excluded.city_group,
                                                    state=excluded.state,
                                                    postal_code=excluded.postal_code,
                                                    country_code=excluded.country_code,
                                                    country=excluded.country;
--------------------------------------------
    insert into scopus_author_affiliations(scp, author_seq, affiliation_no)
    select distinct scp,
           author_seq,
           affiliation_no
    from stg_scopus_author_affiliations
    ON CONFLICT (scp, author_seq, affiliation_no) DO UPDATE SET author_seq=excluded.author_seq,
                                                                affiliation_no=excluded.affiliation_no;
END
$$;

create or replace procedure stg_scopus_merge_chemical_groups()
    language plpgsql
as
$$
BEGIN
    INSERT INTO scopus_chemical_groups(scp, chemicals_source, chemical_name, cas_registry_number)
    select scp,
           chemicals_source,
           chemical_name,
           cas_registry_number
    from stg_scopus_chemical_groups
    ON CONFLICT (scp, chemical_name, cas_registry_number) DO UPDATE SET chemicals_source=excluded.chemicals_source;
END
$$;

create procedure stg_scopus_merge_grants()
    language plpgsql
as
$$
BEGIN
insert into scopus_grants(scp, grant_id, grantor_acronym, grantor,
                          grantor_country_code, grantor_funder_registry_id)
select scp,
       grant_id,
        max(grantor_acronym) as grantor_acronym,
       grantor,
       max(grantor_country_code) as grantor_country_code,
       max(grantor_funder_registry_id) as grantor_funder_registry_id
from stg_scopus_grants
GROUP BY scp, grant_id, grantor
ON CONFLICT (scp, grant_id, grantor) DO UPDATE SET grantor_acronym=excluded.grantor_acronym,
                                                   grantor_country_code=excluded.grantor_country_code,
                                                   grantor_funder_registry_id=excluded.grantor_funder_registry_id;

INSERT INTO scopus_grant_acknowledgements(scp, grant_text)
select scp,
       grant_text
from stg_scopus_grant_acknowledgements
ON CONFLICT (scp) DO UPDATE SET grant_text=excluded.grant_text;
END
$$;

create procedure stg_scopus_merge_keywords()
    language plpgsql
as
$$
BEGIN
INSERT INTO scopus_keywords(scp, keyword)
SELECT DISTNCT scp,
       keyword
FROM stg_scopus_keywords
ON CONFLICT (scp, keyword) DO UPDATE SET keyword=excluded.keyword;
END
$$;

create procedure stg_scopus_merge_pub_details_subjects_and_classes()
    language plpgsql
as
$$
BEGIN
INSERT INTO scopus_source_publication_details(scp, issue, volume, first_page, last_page, publication_year,
                                              publication_date, conf_code, conf_name)

select scp,
       issue,
       volume,
       first_page,
       last_page,
       publication_year,
       publication_date,
       conf_code,
       conf_name
from stg_scopus_source_publication_details
ON CONFLICT (scp) DO UPDATE SET issue=excluded.issue,
                                volume=excluded.volume,
                                first_page=excluded.first_page,
                                last_page=excluded.last_page,
                                publication_year=excluded.publication_year,
                                publication_date=excluded.publication_date,
                                conf_code=excluded.conf_code,
                                conf_name=excluded.conf_name;

INSERT INTO scopus_subjects (scp, subj_abbr)
SELECT scp,
       subj_abbr
FROM stg_scopus_subjects
ON CONFLICT (scp, subj_abbr) DO UPDATE SET subj_abbr=excluded.subj_abbr;

INSERT INTO scopus_subject_keywords (scp, subject)
select scp,
       subject
from stg_scopus_subject_keywords
ON CONFLICT (scp, subject) DO UPDATE SET subject=excluded.subject;

INSERT INTO scopus_classes(scp, class_type, class_code)
SELECT scp,
       class_type,
       class_code
FROM stg_scopus_classes
ON CONFLICT (scp, class_code) DO UPDATE
SET class_type=excluded.class_type, class_code=excluded.class_code;

INSERT INTO scopus_classification_lookup(class_type, class_code, description)
SELECT class_type,
       class_code,
       description
FROM stg_scopus_classification_lookup
ON CONFLICT (class_type, class_code) DO UPDATE SET description=excluded.description;
END
$$;

create procedure stg_scopus_merge_publication_and_group()
    language plpgsql
as
$$
BEGIN
INSERT INTO scopus_publication_groups(sgr, pub_year)
SELECT sgr,
       pub_year
FROM stg_scopus_publication_groups
ON CONFLICT (sgr) DO
UPDATE
SET pub_year=excluded.pub_year;

INSERT INTO scopus_publications(scp, sgr, correspondence_person_indexed_name, correspondence_city,
                                correspondence_country, correspondence_e_address, citation_type)

SELECT scp,
       sgr,
       correspondence_person_indexed_name,
       correspondence_city,
       correspondence_country,
       correspondence_e_address,
       citation_type

FROM stg_scopus_publciations
ON CONFLICT (scp) DO UPDATE SET scp=excluded.scp,
                                sgr=excluded.sgr,
                                correspondence_person_indexed_name=excluded.correspondence_person_indexed_name,
                                correspondence_city=excluded.correspondence_city,
                                correspondence_country=excluded.correspondence_country,
                                correspondence_e_address=excluded.correspondence_e_address,
                                citation_type=excluded.citation_type;
END
$$;

create procedure stg_scopus_merge_publication_identifiers()
    language plpgsql
as
$$
BEGIN
INSERT INTO scopus_publication_identifiers(scp, document_id, document_id_type)
SELECT
FROM stg_scopus_publication_identifiers
ON CONFLICT (scp, document_id, document_id_type) DO UPDATE SET document_id=excluded.document_id,
                                                               document_id_type=excluded.document_id_type;
END
$$;

create procedure stg_scopus_merge_scopus_references()
    language plpgsql
as
$$
BEGIN
INSERT INTO scopus_references(scp, ref_sgr, citation_text)
SELECT scp,
       ref_sgr,
       citation_text
FROM stg_scopus_reference
ON CONFLICT (scp, ref_sgr) DO UPDATE SET citation_text=excluded.citation_text;
END
$$;

create procedure stg_scopus_merge_source_and_conferences()
    language plpgsql
as
$$
BEGIN
INSERT INTO scopus_sources(ernie_source_id, source_id, issn_main, isbn_main, source_type, source_title,
                           coden_code, publisher_name, publisher_e_address, pub_date)
INSERT INTO scopus_sources(ernie_source_id, source_id, issn_main, isbn_main, source_type, source_title,
                           coden_code, publisher_name, publisher_e_address, pub_date)
SELECT DISTINCT ON (source_id, issn_main, isbn_main) max(ernie_source_id)                 as ernie_source_id,
                                                     source_id,
                                                     issn_main,
                                                     isbn_main,
                                                     string_agg(source_type, ' ')         as source_type,
                                                     string_agg(source_title, ' ')        as source_title,
                                                     string_agg(coden_code, ' ')          as coden_code,
                                                     string_agg(publisher_name, ' ')      as publisher_name,
                                                     string_agg(publisher_e_address, ' ') as publisher_e_address,
                                                     max(pub_date)                        as pub_date
FROM jenkins.stg_scopus_sources
group by ernie_source_id, source_id, issn_main, isbn_main
ON CONFLICT (source_id, issn_main, isbn_main) DO UPDATE SET ernie_source_id     = EXCLUDED.ernie_source_id,
                                                            source_type         = EXCLUDED.source_type,
                                                            source_title        = EXCLUDED.source_title,
                                                            coden_code          = EXCLUDED.coden_code,
                                                            publisher_name      = EXCLUDED.publisher_name,
                                                            publisher_e_address = EXCLUDED.publisher_e_address,
                                                            pub_date=EXCLUDED.pub_date;
INSERT INTO scopus_isbns(ernie_source_id, isbn, isbn_length, isbn_type, isbn_level)
select distinct ernie_source_id,
       isbn,
       isbn_length,
       isbn_type,
       isbn_level
from stg_scopus_isbns
ON CONFLICT (ernie_source_id, isbn, isbn_type) DO UPDATE SET isbn_length=excluded.isbn_length,
                                                             isbn_level=excluded.isbn_level;

INSERT INTO scopus_issns(ernie_source_id, issn, issn_type)
select ernie_source_id,
       issn,
       issn_type
from stg_scopus_issns
ON CONFLICT (ernie_source_id, issn, issn_type) DO UPDATE SET issn=excluded.issn,
                                                             issn_type=excluded.issn_type;

INSERT INTO scopus_conference_events(conf_code, conf_name, conf_address, conf_city, conf_postal_code,
                                     conf_start_date,
                                     conf_end_date, conf_number, conf_catalog_number)
select distinct
       conf_code,
       conf_name,
       conf_address,
       conf_city,
       conf_postal_code,
       conf_start_date,
       conf_end_date,
       conf_number,
       conf_catalog_number
from stg_scopus_conference_events
ON CONFLICT (conf_code, conf_name) DO UPDATE SET conf_address=excluded.conf_address,
                                                 conf_city=excluded.conf_city,
                                                 conf_postal_code=excluded.conf_postal_code,
                                                 conf_start_date=excluded.conf_start_date,
                                                 conf_end_date=excluded.conf_end_date,
                                                 conf_number=excluded.conf_number,
                                                 conf_catalog_number=excluded.conf_catalog_number;


INSERT INTO scopus_conf_proceedings(ernie_source_id, conf_code, conf_name, proc_part_no, proc_page_range,
                                    proc_page_count)
select ernie_source_id,
       conf_code,
       conf_name,
       proc_part_no,
       proc_page_range,
       proc_page_count
from stg_scopus_conf_proceedings
ON CONFLICT (ernie_source_id, conf_code, conf_name) DO UPDATE SET proc_part_no=excluded.proc_part_no,
                                                                  proc_page_range=excluded.proc_page_range,
                                                                  proc_page_count=excluded.proc_page_count;
COMMIT;
-- scopus_conf_editors

INSERT INTO scopus_conf_editors(ernie_source_id, conf_code, conf_name, indexed_name, role_type,
                                initials, surname, given_name, degree, suffix)
select ernie_source_id,
       conf_code,
       conf_name,
       indexed_name,
       role_type,
       initials,
       surname,
       given_name,
       degree,
       suffix
from stg_scopus_conf_editors
ON CONFLICT (ernie_source_id, conf_code, conf_name, indexed_name) DO UPDATE SET role_type=excluded.role_type,
                                                                                initials=excluded.initials,
                                                                                surname=excluded.surname,
                                                                                given_name=excluded.given_name,
                                                                                degree=excluded.degree,
                                                                                suffix=excluded.suffix;
END
$$;