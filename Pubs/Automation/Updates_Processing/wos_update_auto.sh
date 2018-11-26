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
# * 11/26/2018, VJ Davey
# ** Adjusted to utilize updates for direct XML to PSQL parsing + removal of split and staging operations.

if [[ $1 == "-h" ]]; then
  cat << END
SYNOPSIS
  $0 [working_directory]
  $0 -h: display this help

DESCRIPTION
  This script updates the Web of Science (WOS) tables on an ETL process.
  Specifically:
  1. Get files (WOS*CORE and .del) downloaded but not updated yet;
  2. Unzip .del files and combine WOS ids in these files to a single file;
  3. Decompress the downloaded WOS*CORE files to get XML files;
  4. Parse WOS*CORE XML files and load data to the main WOS tables (wos_*) in PSQL database;
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
rm -rf WOS*CORE
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

if ((file_count == 0)); then
  echo "No new files to process"
  exit 0
fi

# Update WOS_CORE files one by one, in time sequence.
for core_file in $(ls *.tar.gz | sort -n); do
  echo "Processing CORE file: ${core_file}"

  # Unzip update file to a sub-directory.
  echo "***Unzipping update file: ${core_file}"
  tar --extract --file=${core_file} --gzip --verbose *.xml*

  # Extract file name without extension
  xml_update_dir=${core_file%%.*}
  gunzip --force ${xml_update_dir}/*.gz

  # Directly parse and load XML data into database
  for file in $(ls ${xml_update_dir}/*.xml | sort -n); do
    echo "**Parsing update file and writing in database: ${file}"
    parallel_cores=$(parallel --number-of-cores)
    parallel --halt soon,fail=1 --verbose --line-buffer --tagstring '|job#{#} s#{%}|' \
      "/anaconda2/bin/python ${absolute_script_dir}/New_wos_xml_parser -filename ${file} -processes ${parallel_cores} -offset {} \
      -ncommit 1000" ::: $(seq -s ' ' ${parallel_cores})
    echo "Processed file: ${file}"
  done
  echo "WOS update process for ${core_file} completed"

  # language=PostgresPLSQL
  psql -v ON_ERROR_STOP=on \
       -c 'UPDATE update_log_wos SET last_updated = current_timestamp WHERE id = (SELECT max(id) FROM update_log_wos);'

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
  ls WOS*.del | awk '{print $1 ".gz"}' >> finished_filelist.txt
fi

# Update log and print the latest log records
psql -f "${absolute_script_dir}/update_log.sql"
