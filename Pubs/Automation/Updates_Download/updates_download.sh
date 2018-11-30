#!/usr/bin/env bash
#** Pattern comments for "Download data files"

#** Change history is maintained via commit log and comments providing more detailed info than keeping it in a script

#** Usage notes are incorporated into online help (-h). The format mimics a manual page.
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME
  wos_download.sh -- download newly added files from the WoS FTP server to {working_directory}/update_files/

SYNOPSIS
  wos_download.sh [working_directory]
  wos_download.sh -h: display this help

DESCRIPTION
  Two types of files are downloaded:
  1. Update/new files: WOS_RAW_*.tar.gz
  2. Delete files: WOS*.del.gz

  Uses the specified working_directory ({script_dir}/build/ by default).

ENVIRONMENT
  Required environment variable:
  * WOS_PASSWORD          a WOS subscription FTP password
HEREDOC
  exit 1
fi

#** Failing the script on the first error (-e + -o pipefail)
#** Echoing lines (-x)
set -ex
set -o pipefail

#** Standard script prologue makins use of an optional `working_directory` parameter
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

#** Checking required parameters / environment variables
#** Passing credentials via environment:
#** a) removes them from code stored in a VCS
#** b) centralizes them and simplifies their management and masking e.g. in Jenkins
[[ ! "${WOS_PASSWORD}" ]] && echo "Please set WOS_PASSWORD" && exit 1

#** Cleaning run artifacts. They are left over at the end of runs to investigate if needed.
#** All artifacts are clobbered, hence cleaning could be skipped, but it's useful to do anyway for
#** troubleshooting of failed (partially complete) runs.
#** -f doesn't fail `rm` if a file is not present
rm -f wos_ftp_filelist.txt group_download.sh

echo "Getting a list of files from the WoS FTP server..."
# ESCI files are not downloaded
#** mls command requires specifying a local temporary file
lftp -u nete,${WOS_PASSWORD} ftp.webofscience.com <<HEREDOC
nlist WOS_RAW_*_CORE.tar.gz >> wos_ftp_filelist.txt 
nlist WOS*.del.gz >> wos_ftp_filelist.txt
quit
HEREDOC

cat >group_download.sh <<HEREDOC
lftp -u nete,${WOS_PASSWORD} ftp.webofscience.com <<SCRIPTEND
lcd update_files/
HEREDOC

# Determine the delta to download
#** Using awk is unnecessary if all you need is the entire input line
grep -F --line-regexp --invert-match --file=processed_filelist.txt wos_ftp_filelist.txt | \
     sed 's/.*/mirror -v --use-pget -i &/' >>group_download.sh || { echo "Nothing to download" && exit 0; }

cat >>group_download.sh <<HEREDOC
quit
SCRIPTEND

HEREDOC

echo "Downloading from WoS ..."
#** `bash -xe` is shorter than 1) adding `set -xe`, 2) `chmod ug+x group_download.sh` then `./group_download.sh`
bash -xe group_download.sh
echo "Download finished."

echo "Recording downloaded files ..."
# -t --reverse: list in a modification timestamp order
#** It's better to avoid creating single-use temporary files. Use piping instead.
ls -t --reverse update_files/ | grep -F --line-regexp --invert-match \
                                     --file=processed_filelist.txt >>processed_filelist.txt

declare -i days_to_keep=365
echo "Removing files older than ${days_to_keep} days ..."
find update_files/ -type f -mtime +$((days_to_keep - 1)) -print -delete
