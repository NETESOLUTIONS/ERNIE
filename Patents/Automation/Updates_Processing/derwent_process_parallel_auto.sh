#!/usr/bin/env bash
# Author:       VJ Davey,  Lingtian "Lindsay" Wan
# Date:         10/11/2017, VJ Davey, created script as an offshoot of derwent update auto
# Modified:
# * 01/20/2018, Dmitriy "DK" Korobskiy, miscellaneous refactorings and simplifications, moving to use GNU Parallel

if [[ $1 == "-h" ]]; then
  cat <<END
SYNOPSIS
  $0 [working_directory]
  $0 -h: display this help

DESCRIPTION
  Processes Derwent updates.
  Uses the specified working_directory ({script_dir}/build/ by default).
END
  exit 1
fi

set -xe

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

if ! which parallel >/dev/null; then
  echo "Please install GNU Parallel"
  exit 1
fi

update_dir="${work_dir}/update_files"
xml_dir="${work_dir}/xml_files"

#process_start=`date +%s`
# Determine files for the update, copy the good ones to the local directory for processing
echo ***Getting update files...
ls ${update_dir} | grep tar > complete_filelist_ug.txt

cd ${xml_dir}
# For each update file, parse, load, and update.
for file in $(grep -Fxvf "${work_dir}/finished_filelist.txt" "${work_dir}/complete_filelist_ug.txt" | sort -n); do
  # Clear the xml_dir
  rm -rf *

  echo ***Unzipping and renaming file: ${file}
  # extract *.xml.gz files
  # --strip-components=NUMBER strip NUMBER leading components from file names on extraction
  tar --strip=3 -xvf "${update_dir}/${file}" *.xml*
  # Extract base name of this .tar
  base_name=$(echo "${file%.*}" | sed 's/.*cxml/cxml/g')
  # Prefix *.xml.gz with the base name
  for f in *.xml.gz; do
    mv ${f} ${base_name}${f};
  done
  gunzip *.xml.gz

  echo "***Preparing parsing and loading script for files from: ${file}"
  # Reduce amount of logging
  set +x
  ls *.xml | grep -w xml | parallel --halt soon,fail=1 "echo 'Job @ slot {%} for {}'
    /anaconda2/bin/python ${absolute_script_dir}/derwent_xml_update_parser_parallel.py -filename {} -csv_dir ${xml_dir}/
    bash -e {.}/{.}_load.sh"
  set -x

  # Update Derwent tables.
  echo '***Update Derwent tables for files'
  psql -f "${absolute_script_dir}/derwent_update_tables.sql"

  # Append finished filename to finished filelist.
  printf ${file}'\n' >> "${work_dir}/finished_filelist.txt"
done

# Close out the script and log the times
#date
#process_finish=`date +%s`
#echo "TOTAL UPDATE DURATION:"
#echo $((process_finish-process_start)) | awk '{print  int($1/60)":"int($1%60) " : TOTAL PROCESS DURATION"}'

# Print the log table to the screen
psql -c 'SELECT * FROM update_log_derwent ORDER BY id DESC FETCH FIRST 10 ROWS ONLY;'