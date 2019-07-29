\set ON_ERROR_STOP on
\set ECHO all

\if :{?schema}
SET search_path = :schema;
\endif

\include_relative scopus_enums.sql
\include_relative scopus_tables.sql
\include_relative scopus_triggers.sql
\include_relative scopus_grant_ddl.sql

\include_relative ../../../Postgres/DDL/Functions/udf_try_parse.sql

\include_relative Procedures/scopus_parse_abstracts_and_titles.sql
\include_relative Procedures/scopus_parse_authors_and_affiliations.sql
\include_relative Procedures/scopus_parse_chemical_groups.sql
\include_relative Procedures/scopus_parse_grants.sql
\include_relative Procedures/scopus_parse_keywords.sql
\include_relative Procedures/scopus_parse_pub_details_subjects_and_classes.sql
\include_relative Procedures/scopus_parse_publication_and_group.sql
\include_relative Procedures/scopus_parse_publication_identifiers.sql
\include_relative Procedures/scopus_parse_references.sql
\include_relative Procedures/scopus_parse_source_and_conferences.sql