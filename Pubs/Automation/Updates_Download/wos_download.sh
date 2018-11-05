#!/usr/bin/env bash
# Author: Lingtian "Lindsay" Wan
# Created: 12/14/2016
# Modified:
# 01/05/2017, Lindsay Wan, hide password
# 02/08/2017, Lindsay Wan, added documentation
# 02/22/2017, Lindsay Wan, change username from lindsay to samet
# 02/13/2018, Dmitriy "DK" Korobskiy
# * Refactored to fail early
# * Got rid of unnecessary logging

if [[ $1 == "-h" ]]; then
  cat << END
SYNOPSIS
  $0 [working_directory]
  $0 -h: display this help

DESCRIPTION
  The default working_directory is {absolute script dir}/build/
  This script downloads newly added files from the WoS FTP server to {working_directory}/update_files/

  Two types of files are downloaded:
  1. Update/new files: WOS_RAW_*.tar.gz
  2. Delete files: WOS*.del.gz

ENVIRONMENT
  Required environment variable:
  * WOS_USER_NAME         a WOS subscription FTP user name
  * WOS_PASSWORD          a WOS subscription FTP password
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

[[ ! "${WOS_USER_NAME}" ]] && echo "Please set WOS_USER_NAME" && exit 1
[[ ! "${WOS_PASSWORD}" ]] && echo "Please set WOS_PASSWORD" && exit 1

# Remove previous files.
#rm -f new_filelist_full.txt
rm -f wos_download_list.txt
rm -f new_filelist_wos.txt
rm -f group_download.sh
rm -f updated_filelist.txt
rm -f downloaded_filelist.txt

# Get a list of files to download: *WOS* on the WoS FTP server.
echo ***Getting a list of files from the FTP server...
ftp -inv ftp.webofscience.com << SCRIPTEND
user ${WOS_USER_NAME} ${WOS_PASSWORD}
hash 100M
binary
mls *WOS* new_filelist_wos.txt
quit
SCRIPTEND

# Determine delta to download
grep -F --line-regexp --invert-match --file=begin_filelist.txt new_filelist_wos.txt | grep -v 'ESCI' > wos_download_list.txt

# Write a script to get only newly-added filenames to download.
echo ***Preparing to download newly-added files...
printf 'ftp -inv ftp.webofscience.com <<SCRIPTEND\n' > group_download.sh
echo "user ${WOS_USER_NAME} ${WOS_PASSWORD}" >> group_download.sh
printf 'hash 100M\n' >> group_download.sh
printf 'lcd update_files/\n' >> group_download.sh
printf 'binary\n' >> group_download.sh
cat wos_download_list.txt | awk '{print "get " $1}' >> group_download.sh
printf 'quit\nSCRIPTEND\n\n' >> group_download.sh

# Download newly-added files from the FTP server and push to dev2.
echo ***Downloading newly-added files...
bash -xe group_download.sh
echo ***Download finished.

${absolute_script_dir}/push_files.sh

# Check if new files are all downloaded
echo ***Checking downloading results...
ls update_files/ -ltr | grep WOS | awk '{print $9}' > updated_filelist.txt
grep -F --line-regexp --invert-match --file=begin_filelist.txt updated_filelist.txt > downloaded_filelist.txt
cat downloaded_filelist.txt >> begin_filelist.txt

printf 'Downloaded files:\n'
cat downloaded_filelist.txt
printf 'Files not downloaded:\n'
grep -F --line-regexp --invert-match --file=downloaded_filelist.txt wos_download_list.txt || :

# Remove RAW_CORE and RAW_ESCI files older than 5 weeks to save space.
echo ***Removing old files...
ls update_files/ | grep RAW | sort -n > current_stored_raw_files.txt
declare -i cnt=$(($(cat current_stored_raw_files.txt | wc -l) - 10))
if ((cnt > 0)); then
  for line in $(cat current_stored_raw_files.txt | head -${cnt}); do
    rm update_files/${line}
  done
fi
