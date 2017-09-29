SET temp_tablespaces='temp';

\echo CREATING INDEX FOR wos_references
create index ssd_ref_sourceid_index on wos_references using hash(source_id) tablespace ernie_index_tbs;

\echo CREATING INDEX FOR wos_publications
create index ssd_wos_pub_source_id_index on wos_publications using hash(source_id) tablespace ernie_index_tbs;

\echo CREATING INDEX FOR wos_authors
create index ssd_wos_auth_source_id_index on wos_authors using hash(source_id) tablespace ernie_index_tbs;

\echo CREATING INDEX FOR wos_abstracts
create index wos_abstracts_sourceid_index on wos_abstracts using hash(source_id) tablespace ernie_index_tbs;

\echo CREATING INDEX FOR wos_document_identifiers
create index wos_dois_sourceid_index on wos_document_identifiers using hash(source_id) tablespace ernie_index_tbs;

\echo CREATING INDEX FOR wos_addresses
create index wos_addresses_sourceid_index on wos_addresses using hash(source_id) tablespace ernie_index_tbs;

\echo CREATING INDEX FOR wos_keywords
create index wos_keywords_sourceid_index on wos_keywords using hash(source_id) tablespace ernie_index_tbs;

\echo CREATING INDEX FOR wos_titles
create index wos_titles_sourceid_index on wos_titles using hash(source_id) tablespace ernie_index_tbs;

\echo CREATING INDEX FOR wos_grants
create index wos_grants_sourceid_index on wos_grants using hash(source_id) tablespace ernie_index_tbs;
\echo Done
