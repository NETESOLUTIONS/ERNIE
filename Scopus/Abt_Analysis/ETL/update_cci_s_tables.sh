# Make sure csv files to be loaded exist in the script directory under a subdirectory titled 'cascade_output'
script_dir=$1
declare -a arr=("author_search_results" "affiliations" "documents" "authors" "author_affiliation_mappings" "author_document_mappings" "document_affiliation_mappings" "documents_citations")
cd $script_dir
for tbl in "${arr[@]}"; do
  psql -c "DROP TABLE IF EXISTS cci_s_${tbl}_staging;"
  psql -c "SELECT * INTO cci_s_${tbl}_staging FROM cci_s_${tbl} LIMIT 0;"
  columns=$(psql -c "COPY (select column_name from information_schema.columns where table_name='cci_s_${tbl}') TO STDOUT" | sed '$! s/$/,/')
  psql -c "ALTER TABLE cci_s_${tbl}_staging ADD COLUMN table_id SERIAL PRIMARY KEY;"
  psql -c "COPY cci_s_${tbl}_staging($columns) FROM '${script_dir}/cascade_output/${tbl}.csv' CSV HEADER;"
done
psql -f update_cci_s_tables.sql
