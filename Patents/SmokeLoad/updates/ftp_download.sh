#!/bin/sh
# This script downloads Derwent update files from FTP site under ug and uglsp based on week number -- repurposed

# Usage: ftp_download.sh work_dir/ user pswd
#        where work_dir specifies working directory, user specifies FTP username,  and pswd specifies password to connect to data FTP site.

# Author: VJ Davey
# Create Date: 10/03/2017

# Change to working directory, make this the place on ERNIE where we want the data to be loaded into
c_dir=$1; user=$2; pswd=$3
cd $c_dir

# Stamp current time.
date >> log_derwent_download.txt

# Download all metadata files from FTP site.
echo ***Getting a list of files from the FTP server...
ftp -in ftpserver.wila-derwent.com << SCRIPTEND
user $user $pswd
lcd $c_dir
binary
cd ug
mget *_meta.xml
cd ../uglsp
mget *_meta.xml
quit
SCRIPTEND
#keep only those XML files which meet the week specifications we want to have met by the end of the HDD push
for i in *; do egrep -E -q "updateWeek=\"2017([3-4][0-9])\"" $i && true || rm $i ; done
#for those leftover files, download their corresponding tar files to the gateway
for i in $(ls | sed 's/_meta.*/.tar/g'); do
  if echo $i | grep -q "uglsp" ; then
    echo "Downloading uglsp file $i"
    ftp -in ftpserver.wila-derwent.com << SCRIPTEND
    user nih $pswd
    lcd $c_dir
    binary
    cd uglsp
    get $i
    quit
SCRIPTEND
  else
    echo "Downloading ug file: $i"
    ftp -in ftpserver.wila-derwent.com << SCRIPTEND
    user nih $pswd
    lcd $c_dir
    binary
    cd ug
    get $i
    quit
SCRIPTEND
  fi
done
