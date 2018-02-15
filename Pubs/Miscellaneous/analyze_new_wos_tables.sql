-- Author: Samet Keserci
-- Create Date: 08/14/2017

\set ON_ERROR_STOP on
\set ECHO all


\echo analyzing new_wos_abstracts
ANALYZE new_wos_abstracts;
\echo analyzing new_wos_addresses
ANALYZE new_wos_addresses;
\echo analyzing new_wos_authors
ANALYZE new_wos_authors;
\echo analyzing new_wos_document_identifiers
ANALYZE new_wos_document_identifiers;
\echo analyzing new_wos_grants
ANALYZE new_wos_grants;
\echo analyzing new_wos_keywords
ANALYZE new_wos_keywords;
\echo analyzing new_wos_publications
ANALYZE new_wos_publications;
\echo analyzing new_wos_titles
ANALYZE new_wos_titles;
\echo analyzing new_wos_references
ANALYZE new_wos_references;