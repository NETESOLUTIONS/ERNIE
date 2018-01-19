#!/usr/bin/env bash
# Author:       VJ Davey,  Lingtian "Lindsay" Wan
# Date:         10/11/2017, VJ Davey, created script as an offshoot of derwent update auto
# Modified:
# * 01/19/2018, Dmitriy "DK" Korobskiy, simplified

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

#date
# Change to working directory and clear the appropriate files
update_dir="${work_dir}/update_files"; w_dir="${work_dir}/work"; csv_dir="${work_dir}/xml_files";

#process_start=`date +%s`
rm -f *.tar
# Determine files for the update, copy the good ones to the local directory for processing
echo ***Getting update files...
ls $update_dir | grep tar > complete_filelist_ug.txt
for file in $(grep -Fxvf finished_filelist.txt complete_filelist_ug.txt); do
 cp -v "${update_dir}/${file}" .
done

# For each update file, parse, load, and update.
for file in $(ls *.tar | sort -n); do
  # Clear the work dir
  rm -rf ${w_dir}/*
  # Copy in the python codes and update sql file
  #cp $cur_dir/*.py $work_dir
  #cp $cur_dir/*.sql $work_dir
  # For each file in update source dir, copy that file to the work dir
  cp $file ${w_dir}/
  cd ${w_dir}
  # Unzip and prepare files for parsing.
  echo ***Unzipping and renaming file: $file
  tar -xvf $file *.xml* # extract *.xml.gz files
  find . -name '*.xml.gz' -print0 | xargs -0 mv -t . # move them to current directory
  subdir=$(echo "$file" | sed 's/.tar//g')
  subdir=$(echo "$subdir" | sed 's/.*cxml/cxml/g')
  echo 'substring for tar file is '$subdir
  for f in *.xml.gz; do
    mv $f $subdir$f;
  done # rename *.xml.gz according to source .tar file
  gunzip *.xml.gz # gunzip

  echo ***Preparing parsing and loading script for files from: $file
  ls *.xml | grep -w xml | parallel --halt soon,fail=1 "echo 'Job [s {%}]: {}'
    /anaconda2/bin/python ${absolute_script_dir}/derwent_xml_update_parser_parallel.py -filename {} -csv_dir "${csv_dir}/${subdir}"
    bash -e ${csv_dir}/${subdir}/{.}_load.sh"
  cd ..

  # Update Derwent tables.
  echo '***Update Derwent tables for files'
  psql -f "${absolute_script_dir}/derwent_update_tables.sql"
  # Append finished filename to finished filelist.
  printf $file'\n' >> finished_filelist.txt
done

# Close out the script and log the times
#date
#process_finish=`date +%s`
#echo "TOTAL UPDATE DURATION:"
#echo $((process_finish-process_start)) | awk '{print  int($1/60)":"int($1%60) " : TOTAL PROCESS DURATION"}'

# Print the log table to the screen
psql -c 'SELECT * FROM update_log_derwent;'