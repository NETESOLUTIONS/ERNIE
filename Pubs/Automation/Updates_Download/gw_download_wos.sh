#!/bin/sh

# This script downloads new-added files on the Thomson Reuters FTP server.
# Two types of files are downloaded:
#   1. Update/new files: WOS_RAW_*.tar.gz
#   2. Delete files: WOS*.del.gz

# Usage: sh gw_download_wos.sh work_dir/ user pswd update_dir/
#        where work_dir specifies your working directory, user specifies username, pswd specifies password to connect to FTP site, and update_dir specifies the location on the system that will contain the update files.

# Author: VJ Davey, Lingtian "Lindsay" Wan
# Create Date: 10/03/2017
# Modified: 10/03/2017, VJ Davey, ERNIE repurpose, added username parameter for FTP login, removed SCP step since we currently only have one server for ERNIE

# Change to working directory
c_dir=$1; user=$2; pswd=$3; update_dir=$4
cd $c_dir

# Write starting time to log.
date >> log_ftp_download.txt

# Remove previous files.
rm new_filelist_full.txt
rm wos_download_list.txt
rm new_filelist_wos.txt
rm group_download.sh
rm updated_filelist.txt
rm downloaded_filelist.txt

# Get a complete list of files in the FTP server.
echo ***Getting a list of files from the FTP server...
ftp -in ftp.webofscience.com << SCRIPTEND
user $user $pswd
lcd $c_dir
binary
mls * $c_dir/new_filelist_full.txt
quit
SCRIPTEND

# Get a list of files to download: WOS*.
cat new_filelist_full.txt | grep WOS > new_filelist_wos.txt
grep -Fxvf begin_filelist.txt new_filelist_wos.txt > wos_download_list.txt

# Write new filenames to log.
printf 'New update/delete files:\n' >> log_ftp_download.txt
cat wos_download_list.txt >> log_ftp_download.txt

## Write a script to get only newly-added filenames to download.
echo ***Preparing to download newly-added files...
printf 'ftp -in ftp.webofscience.com <<SCRIPTEND\n' > group_download.sh
echo "user $user $pswd">> group_download.sh
printf 'lcd '$update_dir'\n' >> group_download.sh
printf 'binary\n' >> group_download.sh
cat wos_download_list.txt | awk '{print "get " $1}' >> group_download.sh
printf 'quit\nSCRIPTEND\n\n' >> group_download.sh
#cat wos_download_list.txt | awk '{print "scp ./update_files/" $1 " pardi_admin@10.253.56.4:/pardidata1/WOSupdate/update_files/"}' >> group_download.sh

## Download newly-added files from the FTP server and push to dev2.
echo ***Downloading newly-added files...
sh group_download.sh
echo ***Download finished.

## Check if new files are all downloaded and write to log.
echo ***Checking downloading results...
ls $update_dir -ltr | grep WOS | awk '{print $9}' > updated_filelist.txt
grep -Fxvf begin_filelist.txt updated_filelist.txt > downloaded_filelist.txt
cat downloaded_filelist.txt >> begin_filelist.txt
printf 'Downloaded files:\n' >> log_ftp_download.txt
cat downloaded_filelist.txt >> log_ftp_download.txt
printf 'Files not downloaded:\n' >> log_ftp_download.txt
grep -Fxvf downloaded_filelist.txt wos_download_list.txt >> log_ftp_download.txt

# Remove RAW_CORE and RAW_ESCI files older than 5 weeks to save space.
echo ***Removing old files...
ls $update_dir | grep RAW | sort -n > current_stored_raw_files.txt
cnt=$(($(cat current_stored_raw_files.txt | wc -l) - 10))
if [ $cnt -gt 0 ]
  then
    for file in $(cat current_stored_raw_files.txt | head -$cnt)
    do
      rm $update_dir/$file
    done
fi

## Get a list of all current files.
ls $update_dir > all_stored_files.txt

# Write ending time to log.
date >> log_ftp_download.txt
printf '\n\n' >> log_ftp_download.txt
