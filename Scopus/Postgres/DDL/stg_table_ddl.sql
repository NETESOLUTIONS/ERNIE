\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE TABLE IF NOT EXISTS stg_scopus_publication_groups
(
    sgr      BIGINT,
    pub_year SMALLINT
);

CREATE TABLE IF NOT EXISTS stg_scopus_sources
(
    ernie_source_id     INT,
    source_id           TEXT,
    issn_main           TEXT,
    isbn_main           TEXT,
    source_type         TEXT,
    source_title        TEXT,
    coden_code          TEXT,
    website             TEXT,
    publisher_name      TEXT,
    publisher_e_address TEXT,
    pub_date            DATE

);


CREATE TABLE IF NOT EXISTS stg_scopus_isbns
(
    ernie_source_id INT,
    isbn            TEXT,
    isbn_length     TEXT,
    isbn_type       TEXT,
    isbn_level      TEXT

);


CREATE TABLE IF NOT EXISTS stg_scopus_issns
(
    ernie_source_id INT,
    issn            TEXT,
    issn_type       TEXT

);


CREATE TABLE IF NOT EXISTS stg_scopus_conference_events
(
    conf_code           TEXT,
    conf_name           TEXT,
    conf_address        TEXT,
    conf_city           TEXT,
    conf_postal_code    TEXT,
    conf_start_date     DATE,
    conf_end_date       DATE,
    conf_number         TEXT,
    conf_catalog_number TEXT,
    conf_sponsor        TEXT

);


CREATE TABLE IF NOT EXISTS stg_scopus_publications
(
    scp                                BIGINT,
    sgr                                BIGINT,
    correspondence_person_indexed_name TEXT,
    correspondence_orgs                TEXT,
    correspondence_city                TEXT,
    correspondence_country             TEXT,
    correspondence_e_address           TEXT,
    pub_type                           TEXT,
    citation_type                      TEXT,
    citation_language                  TEXT,
    process_stage                      TEXT,
    state                              TEXT,
    ernie_source_id                    INT,
    date_sort                          DATE
);

CREATE TABLE IF NOT EXISTS stg_scopus_authors
(
    scp                 BIGINT,
    author_seq          SMALLINT,
    auid                BIGINT,
    author_indexed_name TEXT,
    author_surname      TEXT,
    author_given_name   TEXT,
    author_initials     TEXT,
    author_e_address    TEXT,
    author_rank         TEXT

);

CREATE TABLE IF NOT EXISTS stg_scopus_affiliations
(
    scp            BIGINT,
    affiliation_no SMALLINT,
    afid           BIGINT,
    dptid          BIGINT,
    organization   TEXT,
    city_group     TEXT,
    state          TEXT,
    postal_code    TEXT,
    country_code   TEXT,
    country        TEXT

);

CREATE TABLE IF NOT EXISTS stg_scopus_author_affiliations
(
    scp            BIGINT,
    author_seq     SMALLINT,
    affiliation_no SMALLINT

);

CREATE TABLE IF NOT EXISTS stg_scopus_source_publication_details
(
    scp              BIGINT,
    issue            TEXT,
    volume           TEXT,
    first_page       TEXT,
    last_page        TEXT,
    publication_year SMALLINT,
    publication_date DATE,
    indexed_terms    TEXT,
    conf_code        TEXT,
    conf_name        TEXT
);

CREATE TABLE IF NOT EXISTS stg_scopus_subjects
(
    scp       BIGINT,
    subj_abbr SCOPUS_SUBJECT_ABBRE_TYPE

);

CREATE TABLE IF NOT EXISTS stg_scopus_subject_keywords
(
    scp     BIGINT,
    subject TEXT

);

CREATE TABLE IF NOT EXISTS stg_scopus_classification_lookup
(
    class_type  TEXT,
    class_code  TEXT,
    description TEXT

);

CREATE TABLE IF NOT EXISTS stg_scopus_classes
(
    scp        BIGINT,
    class_type TEXT,
    class_code TEXT

);

CREATE TABLE IF NOT EXISTS stg_scopus_conf_proceedings
(
    ernie_source_id INT,
    conf_code       TEXT,
    conf_name       TEXT,
    proc_part_no    TEXT,
    proc_page_range TEXT,
    proc_page_count SMALLINT

);

CREATE TABLE IF NOT EXISTS stg_scopus_conf_editors
(
    ernie_source_id INT,
    conf_code       TEXT,
    conf_name       TEXT,
    indexed_name    TEXT,
    role_type       TEXT,
    initials        TEXT,
    surname         TEXT,
    given_name      TEXT,
    degree          TEXT,
    suffix          TEXT,
    address         TEXT,
    organization    TEXT

);

CREATE TABLE IF NOT EXISTS stg_scopus_references
(
    scp           BIGINT,
    ref_sgr       BIGINT,
    citation_text TEXT
);

CREATE TABLE IF NOT EXISTS stg_scopus_publication_identifiers
(
    scp              BIGINT,
    document_id      TEXT NOT NULL,
    document_id_type TEXT NOT NULL

);

CREATE TABLE IF NOT EXISTS stg_scopus_abstracts
(
    scp               BIGINT,
    abstract_text     TEXT,
    abstract_language TEXT NOT NULL,
    abstract_source   TEXT

);

CREATE TABLE IF NOT EXISTS stg_scopus_titles
(
    scp      BIGINT,
    title    TEXT NOT NULL,
    language TEXT NOT NULL

);

CREATE TABLE IF NOT EXISTS stg_scopus_keywords
(
    scp     BIGINT,
    keyword TEXT NOT NULL

);

CREATE TABLE IF NOT EXISTS stg_scopus_chemical_groups
(
    scp                 BIGINT,
    chemicals_source    TEXT                   NOT NULL,
    chemical_name       TEXT                   NOT NULL,
    cas_registry_number TEXT DEFAULT ' '::TEXT NOT NULL

);

CREATE TABLE IF NOT EXISTS stg_scopus_grants
(
    scp                        BIGINT,
    grant_id                   TEXT,
    grantor_acronym            TEXT,
    grantor                    TEXT NOT NULL,
    grantor_country_code       CHAR(3),
    grantor_funder_registry_id TEXT

);

CREATE TABLE IF NOT EXISTS stg_scopus_grant_acknowledgements
(
    scp        BIGINT,
    grant_text TEXT

);

