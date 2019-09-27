\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE stg_scopus_merge_pub_details_subjects_and_classes()
    LANGUAGE plpgsql AS
$$
BEGIN
    INSERT INTO scopus_source_publication_details(scp, issue, volume, first_page, last_page, publication_year,
                                                  publication_date, indexed_terms, conf_code, conf_name)

    SELECT DISTINCT scp,
                    issue,
                    volume,
                    first_page,
                    last_page,
                    publication_year,
                    publication_date,
                    indexed_terms,
                    conf_code,
                    conf_name
    FROM stg_scopus_source_publication_details
    ON CONFLICT (scp) DO UPDATE SET issue=excluded.issue,
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
    SELECT DISTINCT scp, subj_abbr
    FROM stg_scopus_subjects
    ON CONFLICT (scp, subj_abbr) DO UPDATE SET subj_abbr=excluded.subj_abbr;

    INSERT INTO scopus_subject_keywords
        (scp, subject)
    SELECT DISTINCT scp, subject
    FROM stg_scopus_subject_keywords
    ON CONFLICT (scp, subject) DO UPDATE SET subject=excluded.subject;

    INSERT INTO scopus_classes(scp, class_type, class_code)
    SELECT DISTINCT scp, class_type, class_code
    FROM stg_scopus_classes
    ON CONFLICT (scp, class_code) DO UPDATE SET class_type=excluded.class_type, class_code=excluded.class_code;

    INSERT INTO scopus_classification_lookup(class_type, class_code, description)
    SELECT DISTINCT class_type, class_code, description
    FROM stg_scopus_classification_lookup
    ON CONFLICT (class_type, class_code) DO UPDATE SET description=excluded.description;
END
$$;