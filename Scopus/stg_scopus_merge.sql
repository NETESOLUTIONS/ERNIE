\set ON_ERROR_STOP on
-- Reduce verbosity
-- \set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- region sources and conferences
DO $block$
  DECLARE single_row RECORD;
  BEGIN
    FOR single_row IN (
      SELECT
        ernie_source_id, source_id, issn_main, isbn_main, source_type, source_title, coden_code, website,
        publisher_name, publisher_e_address, pub_date
        FROM stg_scopus_sources
    ) LOOP
      INSERT INTO scopus_sources(ernie_source_id, source_id, issn_main, isbn_main, source_type,
                                 source_title,
                                 coden_code, website, publisher_name, publisher_e_address, pub_date)
      VALUES
        (single_row.ernie_source_id, single_row.source_id, single_row.issn_main,
         single_row.isbn_main, single_row.source_type,
         single_row.source_title,
         single_row.coden_code, single_row.website, single_row.publisher_name,
         single_row.publisher_e_address,
         single_row.pub_date)
          ON CONFLICT (source_id, issn_main, isbn_main) DO UPDATE SET --
            source_type = excluded.source_type,
            source_title = excluded.source_title,
            coden_code = excluded.coden_code,
            website =excluded.website,
            publisher_name = excluded.publisher_name,
            publisher_e_address = excluded.publisher_e_address,
            pub_date = excluded.pub_date;
    END LOOP;
  END $block$;

INSERT INTO scopus_isbns
  (ernie_source_id, isbn, isbn_length, isbn_type, isbn_level)
SELECT ernie_source_id, isbn, max(isbn_length), isbn_type, max(isbn_level)
  FROM stg_scopus_isbns
 GROUP BY ernie_source_id, isbn, isbn_type
    ON CONFLICT (ernie_source_id, isbn, isbn_type) DO UPDATE SET isbn_length=excluded.isbn_length, isbn_level=excluded.isbn_level;
--
INSERT INTO scopus_issns(ernie_source_id, issn, issn_type)
SELECT ernie_source_id, issn, issn_type
  FROM stg_scopus_issns
    ON CONFLICT (ernie_source_id, issn, issn_type) DO UPDATE SET issn=excluded.issn, issn_type=excluded.issn_type;

INSERT INTO scopus_conference_events(conf_code, conf_name, conf_address, conf_city, conf_postal_code,
                                     conf_start_date,
                                     conf_end_date, conf_number, conf_catalog_number, conf_sponsor)
SELECT
  conf_code, conf_name, max(conf_address) AS conf_address, string_agg(DISTINCT conf_city, ',') AS conf_city,
  max(conf_postal_code) AS conf_postal_code, max(conf_start_date) AS conf_start_date,
  max(conf_end_date) AS conf_start_date, max(conf_number) AS conf_number,
  max(conf_catalog_number) AS conf_catalog_number, max(conf_sponsor) AS conf_sponsor
  FROM stg_scopus_conference_events
 GROUP BY conf_code, conf_name
    ON CONFLICT (conf_code, conf_name) DO UPDATE SET --
      conf_address=excluded.conf_address,
      conf_city=excluded.conf_city,
      conf_postal_code=excluded.conf_postal_code,
      conf_start_date=excluded.conf_start_date,
      conf_end_date=excluded.conf_end_date,
      conf_number=excluded.conf_number,
      conf_catalog_number=excluded.conf_catalog_number,
      conf_sponsor=excluded.conf_sponsor;

INSERT INTO scopus_conf_proceedings(ernie_source_id, conf_code, conf_name, proc_part_no, proc_page_range,
                                    proc_page_count)
SELECT
  ernie_source_id, conf_code, conf_name, string_agg(DISTINCT proc_part_no, ','), max(proc_page_range),
  max(proc_page_count)
  FROM stg_scopus_conf_proceedings
 GROUP BY ernie_source_id, conf_code, conf_name
    ON CONFLICT (ernie_source_id, conf_code, conf_name) DO UPDATE SET --
      proc_part_no=excluded.proc_part_no,
      proc_page_range=excluded.proc_page_range,
      proc_page_count=excluded.proc_page_count;

INSERT INTO scopus_conf_editors(ernie_source_id, conf_code, conf_name, indexed_name,
                                surname, degree, address, organization)
SELECT ernie_source_id, conf_code, conf_name, indexed_name, surname, degree, address, organization
  FROM stg_scopus_conf_editors
    ON CONFLICT (ernie_source_id, conf_code, conf_name, indexed_name) DO UPDATE SET --
      surname=excluded.surname,
      degree=excluded.degree,
      address=excluded.address,
      organization=excluded.organization;
-- endregion

-- region publication and group
INSERT INTO scopus_publication_groups(sgr, pub_year)
SELECT sgr, pub_year
  FROM stg_scopus_publication_groups
    ON CONFLICT (sgr) DO UPDATE SET pub_year=excluded.pub_year;

DELETE
  FROM scopus_publications scp USING stg_scopus_publications stg
 WHERE scp.scp = stg.scp;

INSERT INTO scopus_publications(scp, sgr, correspondence_person_indexed_name, correspondence_orgs,
                                correspondence_city,
                                correspondence_country, correspondence_e_address, pub_type, citation_type,
                                citation_language, process_stage, state, date_sort, ernie_source_id)

SELECT
  stg_scopus_publications.scp, max(sgr) AS sgr,
  max(correspondence_person_indexed_name) AS correspondence_person_indexed_name,
  max(correspondence_orgs) AS correspondence_orgs, max(correspondence_city) AS correspondence_city,
  max(correspondence_country) AS correspondence_country, max(correspondence_e_address) AS correspondence_e_address,
  max(pub_type) AS pub_type, max(citation_type) AS citation_type,
  max(regexp_replace(citation_language, '([a-z])([A-Z])', '\1,\2', 'g')) AS citation_language,
  max(process_stage) AS process_stage, max(state) AS state, max(date_sort) AS date_sort, ernie_source_id
  FROM stg_scopus_publications
 GROUP BY scp, ernie_source_id
    ON CONFLICT (scp) DO UPDATE SET --
      sgr=excluded.sgr,
      correspondence_person_indexed_name=excluded.correspondence_person_indexed_name,
      correspondence_orgs=excluded.correspondence_orgs,
      correspondence_city=excluded.correspondence_city,
      correspondence_country=excluded.correspondence_country,
      correspondence_e_address=excluded.correspondence_e_address,
      pub_type= excluded.pub_type,
      citation_type=excluded.citation_type,
      citation_language=excluded.citation_language,
      ernie_source_id=excluded.ernie_source_id;
-- endregion

-- region pub details, subjects and classes
INSERT INTO scopus_source_publication_details(scp, issue, volume, first_page, last_page, publication_year,
                                              publication_date, indexed_terms, conf_code, conf_name)

SELECT
  scp, issue, volume, first_page, last_page, publication_year, publication_date, indexed_terms, conf_code, conf_name
  FROM stg_scopus_source_publication_details
    ON CONFLICT (scp) DO UPDATE SET --
      issue=excluded.issue,
      volume=excluded.volume,
      first_page=excluded.first_page,
      last_page=excluded.last_page,
      publication_year=excluded.publication_year,
      publication_date=excluded.publication_date,
      indexed_terms=excluded.indexed_terms,
      conf_code = excluded.conf_code,
      conf_name = excluded.conf_name;

INSERT INTO scopus_subjects
  (scp, subj_abbr)
SELECT scp, subj_abbr
  FROM stg_scopus_subjects
    ON CONFLICT (scp, subj_abbr) DO UPDATE SET --
      subj_abbr=excluded.subj_abbr;

INSERT INTO scopus_subject_keywords
  (scp, subject)
SELECT scp, subject
  FROM stg_scopus_subject_keywords
    ON CONFLICT (scp, subject) DO UPDATE SET --
      subject=excluded.subject;

INSERT INTO scopus_classes(scp, class_type, class_code)
SELECT scp, class_type, class_code
  FROM stg_scopus_classes
    ON CONFLICT (scp, class_type, class_code) DO UPDATE SET --
      class_type=excluded.class_type,
      class_code=excluded.class_code;

INSERT INTO scopus_classification_lookup(class_type, class_code, description)
SELECT DISTINCT class_type, class_code, description
  FROM stg_scopus_classification_lookup
    ON CONFLICT (class_type, class_code) DO UPDATE SET --
      description=excluded.description;
-- endregion

-- region authors and affiliations
INSERT INTO scopus_authors(scp, author_seq, auid, author_indexed_name, author_surname, author_given_name,
                           author_initials, author_e_address, author_rank)
SELECT
  scp, author_seq, auid, author_indexed_name, max(author_surname) AS author_surname,
  max(author_given_name) AS author_given_name, max(author_initials) AS author_initials,
  max(author_e_address) AS author_e_address,
      ROW_NUMBER() OVER (PARTITION BY scp ORDER BY author_seq, author_indexed_name) AS author_rank
  FROM stg_scopus_authors stg
 GROUP BY scp, author_seq, auid, author_indexed_name
    ON CONFLICT (scp, author_seq) DO UPDATE SET --
      auid=excluded.auid,
      author_surname=excluded.author_surname,
      author_given_name=excluded.author_given_name,
      author_indexed_name=excluded.author_indexed_name,
      author_initials=excluded.author_initials,
      author_e_address=excluded.author_e_address,
      author_rank=excluded.author_rank;

INSERT INTO scopus_affiliations(scp, affiliation_no, afid, dptid, organization, city_group, state, postal_code,
                                country_code,
                                country)
SELECT scp, affiliation_no, afid, dptid, organization, city_group, state, postal_code, country_code, country
  FROM stg_scopus_affiliations
    ON CONFLICT (scp, affiliation_no) DO UPDATE SET --
      afid=excluded.afid,
      dptid=excluded.dptid,
      city_group=excluded.city_group,
      organization=excluded.organization,
      state=excluded.state,
      postal_code=excluded.postal_code,
      country_code=excluded.country_code,
      country=excluded.country;

INSERT INTO scopus_author_affiliations(scp, author_seq, affiliation_no)
SELECT scp, stg_scopus_author_affiliations.author_seq, stg_scopus_author_affiliations.affiliation_no
  FROM stg_scopus_author_affiliations
    ON CONFLICT (scp, author_seq, affiliation_no) DO UPDATE SET --
      author_seq=excluded.author_seq,
      affiliation_no=excluded.affiliation_no;
-- endregion

-- region chemical groups
INSERT INTO scopus_chemical_groups(scp, chemicals_source, chemical_name, cas_registry_number)
SELECT scp, chemicals_source, chemical_name, cas_registry_number
  FROM stg_scopus_chemical_groups
    ON CONFLICT (scp, chemical_name, cas_registry_number) DO UPDATE --
      SET chemicals_source=excluded.chemicals_source;
-- endregion

-- region abstracts and titles
INSERT INTO scopus_abstracts(scp, abstract_language, abstract_text)
SELECT scp, abstract_language, abstract_text
  FROM stg_scopus_abstracts
    ON CONFLICT (scp, abstract_language) DO UPDATE SET --
      abstract_text=excluded.abstract_text;

INSERT INTO scopus_titles(scp, language, title)
  -- SELECT scp, language, max(title) AS title
SELECT scp, language, title AS title
  FROM
    stg_scopus_titles stg
    --  GROUP BY scp, language
    ON CONFLICT (scp, language) DO UPDATE SET --
      title=excluded.title;
-- endregion

-- region keywords
INSERT INTO scopus_keywords(scp, keyword)
SELECT scp, keyword
  FROM stg_scopus_keywords
    ON CONFLICT (scp, keyword) DO UPDATE SET --
      keyword=excluded.keyword;
-- endregion

-- region publication identifiers
INSERT INTO scopus_publication_identifiers(scp, document_id, document_id_type)
SELECT DISTINCT scp, document_id, document_id_type
  FROM stg_scopus_publication_identifiers
    ON CONFLICT (scp, document_id, document_id_type) DO UPDATE SET --
      document_id=excluded.document_id,
      document_id_type=excluded.document_id_type;
-- endregion

-- region grants
INSERT INTO scopus_grants(scp, grant_id, grantor_acronym, grantor,
                          grantor_country_code, grantor_funder_registry_id)
SELECT
  scp, grant_id, max(grantor_acronym) AS grantor_acronym, grantor, max(grantor_country_code) AS grantor_country_code,
  max(grantor_funder_registry_id) AS grantor_funder_registry_id
  FROM stg_scopus_grants
 GROUP BY scp, grant_id, grantor
    ON CONFLICT (scp, grant_id, grantor) DO UPDATE SET --
      grantor_acronym=excluded.grantor_acronym,
      grantor_country_code=excluded.grantor_country_code,
      grantor_funder_registry_id=excluded.grantor_funder_registry_id;

INSERT INTO scopus_grant_acknowledgments(scp, grant_text)
SELECT scp, grant_text
  FROM stg_scopus_grant_acknowledgments
    ON CONFLICT (scp) DO UPDATE SET --
      grant_text=excluded.grant_text;
-- endregion

-- region references
INSERT INTO scopus_references(scp, ref_sgr, citation_text)
SELECT scp, ref_sgr, max(citation_text) AS citation_text
  FROM stg_scopus_references
 GROUP BY scp, ref_sgr
    ON CONFLICT (scp, ref_sgr) DO UPDATE SET --
      citation_text=excluded.citation_text;
-- endregion
