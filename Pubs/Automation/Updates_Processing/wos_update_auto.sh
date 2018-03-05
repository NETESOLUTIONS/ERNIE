#!/usr/bin/env bash

# Author: Lingtian "Lindsay" Wan
# Created: 02/24/2016
# Modified:
# * 06/07/2016, Lindsay Wan, divided wos_references update to loops of small chunks
# * 11/17/2016, Lindsay Wan, added command to prepare a file list of parsed csv directories for production server
# * 11/28/2016, Lindsay Wan, added list del wos files to a txt for prod server.
# * 01/26/2018, Dmitriy "DK" Korobskiy
# ** Enabled running from any directory
# ** Simplified
# * 03/05/2018, Dmitriy "DK" Korobskiy
# ** Refactored background jobs with wait to GNU parallel to handle errors correctly
# ** Truncating staging tables before loading of each core file

if [[ $1 == "-h" ]]; then
  cat << END
SYNOPSIS
  $0 [working_directory]
  $0 -h: display this help

DESCRIPTION
  This script updates the Web of Science (WOS) tables on an ETL process.
  Specifically:
  1. Get files (WOS_CORE and .del) downloaded but not updated yet;
  2. Unzip .del files and combine WOS ids in these files to a single file;
  3. Unzip WOS_CORE files to get XML files;
  4. Split XML files to smaller files, so that Python parser can handle;
  5. For each small file, parse to CSV and load CSV to database new tables:
    new_wos_*;
  6. Update the main WOS tables (wos_*) with records in new tables (new_wos_*);
  7. Delete records from the main WOS tables (wos_*) with WOS id in .del files;
  8. Update log file.

  Uses the specified working_directory ({script_dir}/build/ by default).

  Designed to:
  * Fail early on the first error. Temporary files and data are left behind to examine.
  * Use limited parallelism to the extent process can handle it.
  * Clean temporary files and data *before* processing.
END
  exit 1
fi

set -xe
set -o pipefail

# Get a script directory, same as by $(dirname $0)
script_dir=${0%/*}
# Exporting variable for use in the parallel function
export absolute_script_dir=$(cd "${script_dir}" && pwd)
work_dir=${1:-${absolute_script_dir}/build} # $1 with the default
if [[ ! -d "${work_dir}" ]]; then
  mkdir "${work_dir}"
  chmod g+w "${work_dir}"
fi
cd "${work_dir}"
echo -e "\n## Running under ${USER}@${HOSTNAME} at ${PWD} ##\n"

update_file_dir=update_files/

if ! which parallel > /dev/null; then
  echo "Please install GNU Parallel"
  exit 1
fi

# Remove leftover files if any
rm -f complete_filelist.txt
rm -rf xml_files_splitted/*
rm -f table_split/*
rm -f del_wosid.csv
rm -f *.del
#rm -rf WOS*CORE
#rm -rf WOS*ESCI
rm -f *.tar.gz

echo ***Comparing file list...
# delete lines with ESCI files
ls ${update_file_dir} | sed '/ESCI/d' > complete_filelist.txt

# Copy from ./update_files/ to current directory the WOS_CORE and .del files that have not been updated.
declare -i file_count=0
for core_file in $(grep -F --line-regexp --invert-match --file=finished_filelist.txt complete_filelist.txt); do
  cp -rf ${update_file_dir}${core_file} .
  ((++file_count))
done
#rm -f complete_filelist.txt

if ((file_count == 0)); then
  echo "No new files to process"
  exit 1
fi

process_ref_chunks() {
  set -e
  for table_chunk in $(cat ./table_split/split_tablename.txt); do
    echo "***Processing ${table_chunk} chunk"
    /usr/bin/time --format='\nThis chunk has been processed in %E\n' \
      psql -f "${absolute_script_dir}/wos_process_new_ref_chunk.sql" -v new_ref_chunk=${table_chunk}
  done
  # Auto-vacuum takes care of table analyses
  #psql -c 'VACUUM ANALYZE wos_references;' -v ON_ERROR_STOP=on
}
export -f process_ref_chunks

# Update WOS_CORE files one by one, in time sequence.
for core_file in $(ls *.tar.gz | sort -n); do
  echo "Processing CORE file: ${core_file}"

  # Unzip update file to a sub-directory.
  echo "***Unzipping update file: ${core_file}"
  tar --extract --file=${core_file} --gzip --verbose *.xml*

  # Extract file name without extension
  xml_update_dir=${core_file%%.*}
  gunzip --force ${xml_update_dir}/*.gz

  # Split update xml file to small pieces and move to ./xml_files_splitted/.
  echo "***Splitting update file: ${core_file}"
  find ${xml_update_dir}/ -name '*.xml' | sort | parallel --halt soon,fail=1 --line-buffer \
 "echo 'Job @ slot #{%}: {}' &&
    /anaconda2/bin/python -u '${absolute_script_dir}/new_xml_split.py' {} REC 20000"

  find ${xml_update_dir}/ -name '*SPLIT*' -print0 | xargs -0 mv --target-directory=xml_files_splitted

  echo "***Parsing ${core_file} and loading data to staging tables"
  parallel --halt soon,fail=1 --line-buffer ::: \
    "psql -v ON_ERROR_STOP=on --echo-all -c 'TRUNCATE TABLE new_wos_abstracts;'" \
    "psql -v ON_ERROR_STOP=on --echo-all -c 'TRUNCATE TABLE new_wos_addresses;'" \
    "psql -v ON_ERROR_STOP=on --echo-all -c 'TRUNCATE TABLE new_wos_authors;'" \
    "psql -v ON_ERROR_STOP=on --echo-all -c 'TRUNCATE TABLE new_wos_document_identifiers;'" \
    "psql -v ON_ERROR_STOP=on --echo-all -c 'TRUNCATE TABLE new_wos_grants;'" \
    "psql -v ON_ERROR_STOP=on --echo-all -c 'TRUNCATE TABLE new_wos_keywords;'" \
    "psql -v ON_ERROR_STOP=on --echo-all -c 'TRUNCATE TABLE new_wos_publications;'" \
    "psql -v ON_ERROR_STOP=on --echo-all -c 'TRUNCATE TABLE new_wos_titles;'" \
    "psql -v ON_ERROR_STOP=on --echo-all -c 'TRUNCATE TABLE new_wos_references;'"

  cd xml_files_splitted
  # `ls *.xml` might cause an "Argument list too long" error
  # psql --quiet reduces a very large log size
  # Limit parallelism for now. Job slots > 2 can cause 1) wos_xml_update_parser.py or 2) Postgres to crash.
  MAX_JOB_SLOTS=2
  ls | fgrep '.xml' | parallel -j ${MAX_JOB_SLOTS} --halt soon,fail=1 --line-buffer "set -e
    echo 'Job @ slot #{%}: {}'
    /anaconda2/bin/python -u '${absolute_script_dir}/wos_xml_parser.py' -filename {} -csv_dir ./
    psql -f {.}/{.}_load.sql -v ON_ERROR_STOP=on --quiet"
#  rm -rf *
  cd ..

  # De-duplication of new_wos_* tables except wos_references
  psql -f "${absolute_script_dir}/de_duplicate_new_wos_tables.sql"

  echo "***Updating WOS tables"
  # Start with splitting the New WOS references tables
  /anaconda2/bin/python -u "${absolute_script_dir}/wos_split_db_table.py" -tablename new_wos_references \
                        -rowcount 10000 -csv_dir "${work_dir}/table_split/"
  psql -f table_split/load_csv_table.sql -v ON_ERROR_STOP=on

  # Run the updates for the other 8 tables in parallel with references.
  # Using GNU parallel rather than background jobs for correct error processing
  parallel --halt soon,fail=1 --line-buffer ::: "psql -f ${absolute_script_dir}/wos_process_new_data.sql" \
           process_ref_chunks
  echo "WOS update process for ${core_file} completed"

  # language=PostgresPLSQL
  psql -v ON_ERROR_STOP=on \
       -c 'UPDATE update_log_wos SET last_updated = current_timestamp WHERE id = (SELECT max(id) FROM update_log_wos);'

#  cd table_split
#  rm -f load_csv_table.sql split_tablename.txt *.csv
#  cd ..

  printf $core_file'\n' >> finished_filelist.txt
done

# Process unfinished delete file(s)
if compgen -G "WOS*.del.gz" > /dev/null; then
  # Get WOS IDs from .del files.
  echo ***Extracting WOS IDs from .del files...
  # Unzip delete files.
  gunzip WOS*.del.gz
  # Save delete WOS IDs to a delete records file.
  cat WOS*.del | awk '{split($1,filename,",");print "WOS:" filename[2]}' > del_wosid.csv

  # Delete table records with delete wos_ids
  psql -f "${absolute_script_dir}/wos_process_deletions.sql"
#  rm -f del_wosid.csv
  ls WOS*.del | awk '{print $1 ".gz"}' >> finished_filelist.txt
#  rm -f *.del
fi

# Delete update files.
#rm -rf WOS*CORE
#rm -rf WOS*ESCI
#rm -f WOS*tar.gz

# Print update log
# language=PostgresPLSQL
psql -v ON_ERROR_STOP=on -c "\
SELECT *
FROM update_log_wos
ORDER BY id DESC
FETCH FIRST 10 ROWS ONLY;"