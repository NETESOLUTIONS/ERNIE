DO
$block$
    BEGIN
        call ernie.jenkins.stg_scopus_merge_abstracts_and_titles();
        call ernie.jenkins.stg_scopus_merge_authors_and_affiliations();
        call ernie.jenkins.stg_scopus_merge_chemical_groups();
        call ernie.jenkins.stg_scopus_merge_grants();
        call ernie.jenkins.stg_scopus_merge_keywords();
        call ernie.jenkins.stg_scopus_merge_pub_details_subjects_and_classes();
        call ernie.jenkins.stg_scopus_merge_publication_and_group();
        call ernie.jenkins.stg_scopus_merge_publication_identifiers();
        call ernie.jenkins.stg_scopus_merge_scopus_references();
        call ernie.jenkins.stg_scopus_merge_source_and_conferences();
    END
$block$;
