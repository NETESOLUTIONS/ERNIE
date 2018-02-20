-- Author: Samet Keserci
-- Create Date: 08/14/2017
\set ON_ERROR_STOP on
\set ECHO all

\echo analyzing wos_abstracts
ANALYZE wos_abstracts;
\echo analyzing wos_addresses
ANALYZE wos_addresses;
\echo analyzing wos_authors
ANALYZE wos_authors;
\echo analyzing wos_document_identifiers
ANALYZE wos_document_identifiers;
\echo analyzing wos_grants
ANALYZE wos_grants;
\echo analyzing wos_keywords
ANALYZE wos_keywords;
\echo analyzing wos_publications
ANALYZE wos_publications;
\echo analyzing wos_titles
ANALYZE wos_titles;
\echo analyzing wos_references
ANALYZE wos_references;