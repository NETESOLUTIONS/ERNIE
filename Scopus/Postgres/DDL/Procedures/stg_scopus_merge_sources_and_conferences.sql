\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

create or replace procedure stg_scopus_merge_source_and_conferences()
    language plpgsql
as
$$
DECLARE
    single_row RECORD;
BEGIN
        FOR single_row IN (
            SELECT DISTINCT ernie_source_id,
                            source_id,
                            issn_main,
                            isbn_main,
                            source_type,
                            source_title,
                            coden_code,
                            publisher_name,
                            publisher_e_address,
                            pub_date
            FROM stg_scopus_sources)
            LOOP
                INSERT INTO scopus_sources(ernie_source_id, source_id, issn_main, isbn_main, source_type,
                                           source_title,
                                           coden_code, publisher_name, publisher_e_address, pub_date)
                VALUES (single_row.ernie_source_id, single_row.source_id, single_row.issn_main,
                        single_row.isbn_main, single_row.source_type,
                        single_row.source_title,
                        single_row.coden_code, single_row.publisher_name, single_row.publisher_e_address,
                        single_row.pub_date)
                ON CONFLICT (source_id, issn_main, isbn_main) DO UPDATE SET source_type         = EXCLUDED.source_type,
                                                                            source_title        = EXCLUDED.source_title,
                                                                            coden_code          = EXCLUDED.coden_code,
                                                                            publisher_name      = EXCLUDED.publisher_name,
                                                                            publisher_e_address = EXCLUDED.publisher_e_address,
                                                                            pub_date            = EXCLUDED.pub_date;
            END LOOP;


    INSERT INTO scopus_isbns (ernie_source_id, isbn, isbn_length, isbn_type, isbn_level)
    select distinct scopus_sources.ernie_source_id,
                    isbn,
                    isbn_length,
                    isbn_type,
                    isbn_level
    from stg_scopus_isbns, scopus_sources
    where scopus_sources.ernie_source_id=stg_scopus_isbns.ernie_source_id
    ON CONFLICT (ernie_source_id, isbn, isbn_type) DO UPDATE SET isbn_length=excluded.isbn_length,
                                                                 isbn_level=excluded.isbn_level;
--
    INSERT INTO scopus_issns(ernie_source_id, issn, issn_type)
    select distinct scopus_sources.ernie_source_id,
                    issn,
                    issn_type
    from stg_scopus_issns, scopus_sources
    where scopus_sources.ernie_source_id=stg_scopus_issns.ernie_source_id
    ON CONFLICT (ernie_source_id, issn, issn_type) DO UPDATE SET issn=excluded.issn,
                                                                 issn_type=excluded.issn_type;

    INSERT INTO scopus_conference_events(conf_code, conf_name, conf_address, conf_city, conf_postal_code,
                                         conf_start_date,
                                         conf_end_date, conf_number, conf_catalog_number)
    select distinct conf_code,
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
    select distinct scopus_sources.ernie_source_id,
                    conf_code,
                    conf_name,
                    proc_part_no,
                    proc_page_range,
                    proc_page_count
    from stg_scopus_conf_proceedings, scopus_sources
    where scopus_sources.ernie_source_id=stg_scopus_conf_proceedings.ernie_source_id
    ON CONFLICT (ernie_source_id, conf_code, conf_name) DO UPDATE SET proc_part_no=excluded.proc_part_no,
                                                                      proc_page_range=excluded.proc_page_range,
                                                                      proc_page_count=excluded.proc_page_count;
-- scopus_conf_editors

    INSERT INTO scopus_conf_editors(ernie_source_id, conf_code, conf_name, indexed_name, role_type,
                                    initials, surname, given_name, degree, suffix)
    select scopus_sources.ernie_source_id,
           conf_code,
           conf_name,
           indexed_name,
           role_type,
           initials,
           surname,
           given_name,
           degree,
           suffix
    from stg_scopus_conf_editors, scopus_sources
    where scopus_sources.ernie_source_id=stg_scopus_conf_editors.ernie_source_id
    ON CONFLICT (ernie_source_id, conf_code, conf_name, indexed_name) DO UPDATE SET role_type=excluded.role_type,
                                                                                    initials=excluded.initials,
                                                                                    surname=excluded.surname,
                                                                                    given_name=excluded.given_name,
                                                                                    degree=excluded.degree,
                                                                                    suffix=excluded.suffix;

END ;
$$;