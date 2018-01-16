#!/usr/bin/env bash
# Author: Lingtian "Lindsay" Wan
# Created: 12/13/2016
# Modified:
#   01/17/2017, Lindsay Wan, delete "-d" in pg_dump to comply with pg_dump 9.2 version
#   01/25/2017, Lindsay Wan, change truncate to drop tables to ensure sequence number consistency
#   02/17/2017, Lindsay Wan, change username from lindsay to samet
#   03/16/2017, Samet Keserci, updates are set for pardi_admin
#   11/30/2017, Samet Keserci, revised according to server process switchovers.
#   12/22/2017, Dmitriy "DK" Korobskiy
#     * Made working directory optional

if [[ $1 == "-h" ]]; then
  cat <<END
SYNOPSIS
  $0 [working_directory]
  $0 -h: display this help

DESCRIPTION
  Updates FDA data.
  Uses the specified working_directory ({script_dir}/build/ by default).
END
  exit 1
fi

set -xe

# Get a script directory, same as by $(dirname $0)
script_dir=${0%/*}
absolute_script_dir=$(cd "${script_dir}" && pwd)
work_dir=${1:-${absolute_script_dir}/build} # $1 with the default
[[ ! -d "$work_dir" ]] && mkdir "$work_dir"
cd "$work_dir"
echo -e "\n## Running under ${USER}@${HOSTNAME} at ${PWD} ##\n"

# Remove stamped times and stamp new time.
#rm starttime.txt
#rm endtime.txt
#date > starttime.txt
#date

# Remove previous files.
echo ***Removing previous FDA files...
# -f, --force ignore nonexistent files and arguments
rm -f fda_files.zip
rm -f *atent*
rm -f products*
rm -f exclusivity*

${absolute_script_dir}/download.sh

# Unzip and reformat data files.
echo ***Unzipping and reformatting...
unzip fda_files.zip
cat exclusivity*.txt > exclusivity.csv
compgen -G "Patent*.txt" >/dev/null && cat Patent*.txt > patent.csv
cat patent*.txt >> patent.csv
cat products*.txt > products.csv

# Load data to database.
echo ***Loading data to database...
psql -f "${absolute_script_dir}/load_fda_data.sql" -v "work_dir=${work_dir}"

# Stamp end time.
#date > endtime.txt
#date

# Query log
psql -c 'SELECT * FROM update_log_fda ORDER BY id;'