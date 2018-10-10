-- Author: Samet Keserci
-- Create Date: 06/06/2016
-- Usage: psql -d ernie -f create_index_wos.sql

\set ON_ERROR_STOP on
\set ECHO all

\echo CREATING INDEX FOR temp_wos_references
CREATE INDEX ssd_ref_sourceid_index
  ON temp_wos_references USING HASH (source_id) TABLESPACE index_tbs;
\echo CREATING INDEX FOR temp_wos_publications
CREATE INDEX ssd_wos_pub_source_id_index
  ON temp_wos_publications USING HASH (source_id) TABLESPACE index_tbs;
\echo CREATING INDEX FOR temp_wos_authors
CREATE INDEX ssd_wos_auth_source_id_index
  ON temp_wos_authors USING HASH (source_id) TABLESPACE index_tbs;
\echo CREATING INDEX FOR temp_wos_abstracts
CREATE INDEX wos_abstracts_sourceid_index
  ON temp_wos_abstracts USING HASH (source_id) TABLESPACE index_tbs;
\echo CREATING INDEX FOR temp_wos_document_identifiers
CREATE INDEX wos_dois_sourceid_index
  ON temp_wos_document_identifiers USING HASH (source_id) TABLESPACE index_tbs;
\echo CREATING INDEX FOR temp_wos_addresses
CREATE INDEX wos_addresses_sourceid_index
  ON temp_wos_addresses USING HASH (source_id) TABLESPACE index_tbs;
\echo CREATING INDEX FOR temp_wos_keywords
CREATE INDEX wos_keywords_sourceid_index
  ON temp_wos_keywords USING HASH (source_id) TABLESPACE index_tbs;
\echo CREATING INDEX FOR temp_wos_titles
CREATE INDEX wos_titles_sourceid_index
  ON temp_wos_titles USING HASH (source_id) TABLESPACE index_tbs;
\echo CREATING INDEX FOR temp_wos_grants
CREATE INDEX wos_grants_sourceid_index
  ON temp_wos_grants USING HASH (source_id) TABLESPACE index_tbs;
\echo Done