#!/usr/bin/env bash
# Author: VJ Davey, based on work by Lingtian "Lindsay" Wan
# Creates: 10/11/2017
# Modified:
# 01/15/2018, Dmitriy "DK" Korobskiy, moved to set -xe

if [[ $1 == "-h" ]]; then
  cat <<END
SYNOPSIS
  $0 working_directory Derwent_user Derwent_password
  $0 -h: display this help

DESCRIPTION
  This script downloads Derwent update files from FTP site, under ug directory and places those files locally into the
  update_files directory.
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

username=$2; pswd=$3

# Stamp current time.
date ; date >> log_derwent_download.txt

# Download a complete filelist from FTP site.
echo ***Getting a list of files from the FTP server...
ftp -inv ftpserver.wila-derwent.com << SCRIPTEND | fgrep -q '226 Directory send OK'
user $username $pswd
lcd $c_dir
binary
cd ug
mls * $c_dir/full_ftp_filelist_ug.txt
quit
SCRIPTEND

# List all the tar and meta files
cat full_ftp_filelist_ug.txt | grep tar > tar_ftp_filelist_ug.txt ; cat full_ftp_filelist_ug.txt | grep meta > meta_ftp_filelist_ug.txt
# Compare current files with file list to determine which files should be downloaded
if ! grep -Fxvf begin_filelist_ug.txt tar_ftp_filelist_ug.txt > derwent_download_list_ug.txt; then
  echo "Nothing to download"
  exit 1
fi
# Compare current meta files with filelist and determine files to be downloaded.
grep -Fxvf begin_filelist_ug_meta.txt meta_ftp_filelist_ug.txt > derwent_download_list_ug_meta.txt

# Write new file names to log.
printf 'New update/delete files:\n' >> log_derwent_download.txt ; cat derwent_download_list_ug.txt >> log_derwent_download.txt
printf 'New update/delete meta files:\n' >> log_derwent_download.txt ; cat derwent_download_list_ug_meta.txt >> log_derwent_download.txt

# Write command to a download batch script for downloading ug files.
echo ***Preparing to download newly-added files...
printf 'ftp -in ftpserver.wila-derwent.com <<SCRIPTEND\n' > group_download_ug.sh
printf 'user '$username' '$pswd'\n' >> group_download_ug.sh
printf 'lcd '$c_dir'update_files/\n' >> group_download_ug.sh
printf 'cd ug\n' >> group_download_ug.sh
printf 'binary\n' >> group_download_ug.sh
cat derwent_download_list_ug.txt | awk '{print "get " $1}' >> group_download_ug.sh
printf 'quit\nSCRIPTEND\n\n' >> group_download_ug.sh

# Write command to a download batch script for downloading ug meta files.
echo ***Preparing to download newly-added files...
printf 'ftp -in ftpserver.wila-derwent.com <<SCRIPTEND\n' > group_download_ug_meta.sh
printf 'user '$username' '$pswd'\n' >> group_download_ug_meta.sh
printf 'lcd '$c_dir'update_files/\n' >> group_download_ug_meta.sh
printf 'cd ug\n' >> group_download_ug_meta.sh
printf 'binary\n' >> group_download_ug_meta.sh
cat derwent_download_list_ug_meta.txt | awk '{print "get " $1}' >> group_download_ug_meta.sh
printf 'quit\nSCRIPTEND\n\n' >> group_download_ug_meta.sh

# Download newly-added files from the FTP server.
echo ***Downloading newly-added files...
sh group_download_ug_meta.sh
sh group_download_ug.sh
echo ***Download finished.

# Check if new files are all downloaded and write to log.
echo ***Checking downloading results...
ls update_files/ -ltr | grep cxml_ug2 | grep tar | awk '{print $9}' > updated_filelist_ug.txt
grep -Fxvf begin_filelist_ug.txt updated_filelist_ug.txt > downloaded_filelist_ug.txt
ls update_files/ -ltr | grep cxml_ug2 | grep meta | awk '{print $9}' > updated_filelist_ug_meta.txt
grep -Fxvf begin_filelist_ug_meta.txt updated_filelist_ug_meta.txt > downloaded_filelist_ug_meta.txt
cat downloaded_filelist_ug.txt >> begin_filelist_ug.txt
cat downloaded_filelist_ug_meta.txt >> begin_filelist_ug_meta.txt
printf 'Downloaded files:\n' >> log_derwent_download.txt
cat downloaded_filelist_ug.txt >> log_derwent_download.txt
cat downloaded_filelist_ug_meta.txt >> log_derwent_download.txt
printf 'Files not downloaded:\n' >> log_derwent_download.txt
grep -Fxvf downloaded_filelist_ug.txt derwent_download_list_ug.txt >> log_derwent_download.txt
grep -Fxvf downloaded_filelist_ug_meta.txt derwent_download_list_ug_meta.txt >> log_derwent_download.txt

# Compare checksum
echo ***Comparing Checksum...
cat downloaded_filelist_ug.txt | awk '{split($1,filename,"."); print "echo $(cat ./update_files/" filename[1] "_meta.xml | grep checksum | sed '\''s/\\(checksum=\\|\"\\|\\t\\| \\)//g'\'') ./update_files/" $1 " | md5sum -c -"}' > derwent_checksum.sh
printf 'Checksum results:\n' >> log_derwent_download.txt ; sh derwent_checksum.sh >> log_derwent_download.txt

# Remove UG and UGLSP files older than 5 weeks to save space.
#echo ***Removing old UG files...
#ls update_files/ | grep cxml_ug | sort -n > current_stored_ug_files.txt
#cnt=$(($(cat current_stored_ug_files.txt | wc -l) - 10))
#if [ $cnt -gt 0 ]
#  then
#    for file in $(cat current_stored_ug_files.txt | head -$cnt)
#    do
#      rm update_files/$file
#    done
#fi

# Write ending time to log.
date ; date >> log_derwent_download.txt ; printf '\n\n' >> log_derwent_download.txt
