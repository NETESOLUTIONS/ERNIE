#!/usr/bin/env bash
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME
  ct_update.sh -- download Clinical Trial data from its website and process it

SYNOPSIS
  ct_update.sh [working_directory]
  ct_update.sh -h: display this help

DESCRIPTION
  1. Download data source from website.
  2. Unzip to get XML files.
  3. Run in parallel with 4 jobs: parse each XML and directly load into main tables.
  4. Update tables.
  5. Write to log.

  Uses the specified working_directory ({script_dir}/build/ by default).
HEREDOC
  exit 1
fi

set -ex
set -o pipefail

# Get a script directory, same as by $(dirname $0)
script_dir=${0%/*}
absolute_script_dir=$(cd "${script_dir}" && pwd)
work_dir=${1:-${absolute_script_dir}/build} # $1 with the default
if [[ ! -d "${work_dir}" ]]; then
  mkdir "${work_dir}"
  chmod g+w "${work_dir}"
fi
cd "${work_dir}"
echo -e "\n## Running under ${USER}@${HOSTNAME} at ${PWD} ##\n"

# Script output is quieted down to reduce the large log size (could be up to 140 M)
# echo "Removing previous NCT files, directories, and other related files ..."
# rm -rf ${work_dir}/nct_files
# mkdir nct_files
# chmod g+w nct_files

# # Download and decompress the CT data
# echo "Collecting CT data ..."
# cd nct_files
# ${absolute_script_dir}/download_updates.sh

# echo "Unzipping CT data ..."
# unzip -q CT_all.zip

# Process the data - multiprocessing library used in python along with shared memory objects to allow for creation of SQL upsert strings based on multiple XML files
echo "Loading files in parallel from work dir: ${work_dir}..."
/anaconda3/bin/python ${absolute_script_dir}/ct_xml_update_parser.py  <\(find ${work_dir}/nct_files/ | grep 'nct_files/NCT.*\.xml'\)

# Update the log table
echo "***UPDATING LOG TABLE"
psql -c "INSERT INTO update_log_ct (last_updated, num_nct)\
  SELECT current_timestamp,count(1)\
  FROM ct_clinical_studies;"

# language=PostgresPLSQL
psql -v ON_ERROR_STOP=on --echo-all <<'HEREDOC'
SELECT *
FROM update_log_ct
ORDER BY id DESC
FETCH FIRST 10 ROWS ONLY;
HEREDOC

# Clean the uploaded files out
rm -rf ${work_dir}/nct_files
