DO
$block$
    BEGIN
        CALL jenkins.stg_scopus_merge_publication_and_group();
        CALL jenkins.stg_scopus_merge_source_and_conferences();
        CALL jenkins.stg_scopus_merge_pub_details_subjects_and_classes();
        CALL jenkins.stg_scopus_merge_authors_and_affiliations();
        CALL jenkins.stg_scopus_merge_chemical_groups();
        CALL jenkins.stg_scopus_merge_abstracts_and_titles();
        CALL jenkins.stg_scopus_merge_keywords();
        CALL jenkins.stg_scopus_merge_publication_identifiers();
        CALL jenkins.stg_scopus_merge_grants();
        CALL jenkins.stg_scopus_merge_references();
    END
$block$;

