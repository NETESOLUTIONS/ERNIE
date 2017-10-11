########################################################################################################
# Program Name: derwent_process_parallel_auto.sh
# Usage:        derwent_process_parallel_auto.sh update_dir work_dir csv_dir
#           update_dir is the directory holding the xml.gz files, work_dir is a space where the script can do its job, csv_dir is the desired output directory for csv files
# Author:       VJ Davey,  Lingtian "Lindsay" Wan
# Date:         10/11/2017, VJ Davey, created script as an offshoot of derwent update auto
#########################################################################################################

date
# Change to working directory.
update_dir=$1 ; work_dir=$2 ;csv_dir=$3 ; cur_dir=$(pwd)
process_start=`date +%s`
# Determine files for the update, copy the good ones to the local directory for processing
echo ***Getting update files...
ls $update_dir | grep tar > complete_filelist_ug.txt
grep -Fxvf finished_filelist.txt complete_filelist_ug.txt > remain_filelist.txt
cat remain_filelist.txt | awk '{print "cp '$update_dir'/" $1 " '$cur_dir'"}' > cp_files.sh
sh cp_files.sh

# For each update file, parse, load, and update.
for file in $(ls *.tar | sort -n)
do
  # Clear the work dir
  cd $work_dir
  rm -rf $work_dir/*
  # Copy in the python codes
  cp $cur_dir/*.py $work_dir
  # For each file in update source dir, copy that file to the work dir
  cp $cur_dir/$file $work_dir
  cd $work_dir
  # Unzip and prepare files for parsing.
  echo ***Unzipping and renaming file: $file
  tar -xvf $file *.xml* # extract *.xml.gz files
  find . -name '*.xml.gz' -print0 | xargs -0 mv -t . # move them to current directory
  subdir=$(echo "$file" | sed 's/.tar//g')
  subdir=$(echo "$subdir" | sed 's/.*cxml/cxml/g')
  echo 'substring for tar file is '$subdir
  for f in *.xml.gz; do mv $f $subdir$f; done # rename *.xml.gz according to source .tar file
  gunzip *.xml.gz # gunzip
  # Prepare codes for parsing and loading xml files.
  echo ***Preparing parsing and loading script for files from: $file
  ls *.xml | grep -w xml | awk -v store_dir=$csv_dir/$subdir ' {split($1,filename,"."); if(NR%3!=0) print "echo Parsing " $1 "\n" "python derwent_xml_update_parser_parallel.py -filename " $1 " -csv_dir " store_dir "/ & \n";\
else print "echo Parsing " $1 "\n" "python derwent_xml_update_parser_parallel.py -filename " $1 " -csv_dir " store_dir "/ & \n\nwait"; }' > parse_derwent_update.sh
  # Parse xml files.
  echo ***Parsing files from: $file
  sh parse_derwent_update.sh
  # Load xml files.
  echo ***Parsing files from: $file
  for file in $(find $csv_dir/$subdir -name *_load.sh); do
    sh $file
    wait
  done
  # Update Derwent tables.
  echo ***Update Derwent tables for files from: $file
  psql -d pardi -f derwent_update_tables.sql
  # Append finished filename to finished filelist.
  printf $file'\n' >> finished_filelist.txt
done
# Close out the script and log the times
date
process_finish=`date +%s`
echo "TOTAL UPDATE DURATION:"
echo $((process_finish-process_start)) | awk '{print  int($1/60)":"int($1%60) " : TOTAL PROCESS DURATION"}'
# Print the log table to the screen
psql -d ernie -c 'select * from update_log_derwent;'
