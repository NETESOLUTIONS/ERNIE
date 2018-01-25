


-- Author: Samet Keserci
-- Create Date: 06/06/2016
-- Usage: psql -d ernie -f create_index_wos.sql



SET temp_tablespaces='temp';

\echo CREATING INDEX FOR temp_wos_references
create index ssd_ref_sourceid_index on temp_wos_references using hash(source_id) tablespace indexes;
\echo CREATING INDEX FOR temp_wos_publications
create index ssd_wos_pub_source_id_index on temp_wos_publications using hash(source_id) tablespace indexes;
\echo CREATING INDEX FOR temp_wos_authors
create index ssd_wos_auth_source_id_index on temp_wos_authors using hash(source_id) tablespace indexes;
\echo CREATING INDEX FOR temp_wos_abstracts
create index wos_abstracts_sourceid_index on temp_wos_abstracts using hash(source_id) tablespace indexes;
\echo CREATING INDEX FOR temp_wos_document_identifiers
create index wos_dois_sourceid_index on temp_wos_document_identifiers using hash(source_id) tablespace indexes;
\echo CREATING INDEX FOR temp_wos_addresses
create index wos_addresses_sourceid_index on temp_wos_addresses using hash(source_id) tablespace indexes;
\echo CREATING INDEX FOR temp_wos_keywords
create index wos_keywords_sourceid_index on temp_wos_keywords using hash(source_id) tablespace indexes;
\echo CREATING INDEX FOR temp_wos_titles
create index wos_titles_sourceid_index on temp_wos_titles using hash(source_id) tablespace indexes;
\echo CREATING INDEX FOR temp_wos_grants
create index wos_grants_sourceid_index on temp_wos_grants using hash(source_id) tablespace indexes;
\echo Done
