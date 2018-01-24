#!/usr/bin/env bash
# Author: Lingtian "Lindsay" Wan, George Chacko, Shixin Jiang
# Created: 05/01/2016
# Modified:
# * 05/19/2016, Lindsay Wan, added documentation
# * 11/04/2016, Lindsay Wan, added import ct_clinical_studies to IRDB database
# * 12/09/2016, Lindsay Wan, download CT file from gateway server
# * 03/29/2017, Samet Keserci, revision wrt dev2 to dev3 migration
# * 01/05/2018, Dmitriy "DK" Korobskiy, enabled running from any directory
# * 01/10/2018, Dmitriy "DK" Korobskiy, refactored parallel loop to use GNU Parallels
# * 01/23/2018, Dmitriy "DK" Korobskiy, minor refactorings

if [[ $1 == "-h" ]]; then
  cat << END
SYNOPSIS
  $0 [working_directory]
  $0 -h: display this help

DESCRIPTION
  This script downloads Clinical Trial data from its website and processes them to the pardi database. Specifically:
  1. Create a set of new tables: new_ct_*.
  2. Download data source from website.
  3. Unzip to get XML files.
  4. Run in parallel with 4 jobs: parse each XML to csv and load to tables: new_ct_*.
  5. Update tables.
  6. Write to log.

  Uses the specified working_directory ({script_dir}/build/ by default).

ENVIRONMENT
  Required environment variable:
  * IRDBPRD_PASSWORD          a LINK_OD_PARDI password
END
  exit 1
fi

set -xe
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

if ! which parallel >/dev/null; then
  echo "Please install GNU Parallel"
  exit 1
fi

echo ***Removing previous NCT files, directories, and other related files...
rm -rf ./nct_files/
rm -rf nctload*
mkdir nct_files
chmod g+w nct_files

# TODO Refactor to use upsert_file() function

echo ***Creating CT tables...
psql -f "${absolute_script_dir}/createtable_new_ct_clinical_studies.sql"
psql -f "${absolute_script_dir}/createtable_new_ct_subs.sql"

cd nct_files
${absolute_script_dir}/download_updates.sh

echo ***Unzipping CT data...
unzip -q CT_all.zip

echo ***Loading files in parallel...
# >ls NCT*.xml causes "Argument list too long" error
# Quiet down output to reduce the large log size (up to 140 M)
# psql -q specifies that psql should do its work quietly
ls | fgrep 'NCT' | fgrep 'xml' | parallel --halt soon,fail=1 "echo 'Job [s {%}]: {}'
  /anaconda2/bin/python ${absolute_script_dir}/ct_xml_update_parser.py -filename {} -csv_dir ${work_dir}/nct_files/
  psql -f {.}/{.}_load.pg -v ON_ERROR_STOP=on -q"

# De-duplication an PK ing process for new_ct_* tables.
echo ***De-duplication of new_ct_* database tables...
psql -f "${absolute_script_dir}/new_ct_De-Duplication.sql"

# Upload database.
echo ***Uploading database tables...
psql -f "${absolute_script_dir}/ct_update_tables.sql"
cd ..

rm -rf ct_clinical_studies.csv

psql -c 'select * from update_log_ct;'

# Send log to emails.
#psql -c 'select * from update_log_ct;' | mail -s "Clinical Trial  Weekly Update Log" samet@nete.com
# george@nete.com avon@nete.com