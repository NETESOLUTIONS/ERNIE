#!/bin/bash
#########################################################################################################
# Program Name: process_uspto_xml_year_data.sh
# Usage:        process_uspto_xml_year_data.sh source_dir work_dir csv_dir
#           source_dir is the directory holding the xml.gz files, work_dir is a space where the script can do its job, csv_dir is the desired output directory for csv files
# Author:       VJ Davey, Shixin Jiang
# Date:         01/14/2016
# Change:       08/18/2017, VJ Davey, updated for speed, remodeled to handle patent data in decade batches
#########################################################################################################
source_dir=$1
work_dir=$2
csv_dir=$3
cur_dir=$(pwd)
process_start=`date +%s`

# 1. Set up: make variable to perform regex matching on files by decade, create empty psql tables in the appropriate tablespace. Remove csv directory if it exists and create a fresh one
START=183
psql -d ernie -f create_derwent_tables.sql
[ -d "$csv_dir" ] && rm -rf $csv_dir || true
mkdir $csv_dir

# 2. For every file which fits within the current ten year chunk period defined via regex, run the following loop
for i in $(seq 201 -1 $START); do

  # a. Let the user know which decade we are currently working on
  echo "Working on files from the "$i"0's"
  unzip_start=`date +%s`

  # b. Delete the work directory if it exists and make a new one
  [ -d "$work_dir" ] && rm -rf $work_dir|| true
  mkdir $work_dir

  # b. Move xml.gz files from the source directory to the work directory that matches the current decade regex.
  cd $source_dir
  ls $source_dir | grep -q "_$i.*xml.gz" &&  cp $(ls $source_dir | grep "_$i.*xml") $work_dir ||  echo "No XML files for this decade exist in the source directory $source_dir"
  cd $cur_dir

  # c. unzip xml.gz files, change permissions, copy any useful source code to the working directory (if the directory isnt empty. Otherwise continue to next decade.)
  [ "$(ls -A $work_dir)" ] && gunzip $work_dir/US*.xml.gz || continue
  chmod 750 $work_dir/*.xml
  cp $cur_dir/*.py $work_dir

  # d. Generate CSV subdirectories according to decade in master CSV directory. Use awk to generate scripts that parse XML files in parallel and generate CSV files and SQL loader scripts
  parse_start=`date +%s`
  ending='0s'

  ls -ltr $work_dir | grep '_A_\|_A1_\|_P_\|_P1_\|_S_\|_S1_\|_E_\|_E1_' | awk -v source_dir=$csv_dir/$i$ending '{split($9,filename,"."); split(filename[1],foo,"_");\
  if(substr(foo[4],1,4) <= 2000){\
    if(NR%3!=0) print "echo Parsing " $9 "\n" "python derwent_xml_update_parser_parallel.py -filename " $9 " -csv_dir " source_dir "/ & \n";\
  else print "echo Parsing " $9 "\n" "python derwent_xml_update_parser_parallel.py -filename " $9 " -csv_dir " source_dir "/ & \n\nwait";\
    }\
  }' >> $work_dir/parse_all_xml.sh
  ls -ltr $work_dir | grep '_B1_\|_B2_\|_P2_\|_P3_\|_S_\|_S1_\|_E_\|_E1_' | awk -v source_dir=$csv_dir/$i$ending '{split($9,filename,"."); split(filename[1],foo,"_");\
  if(substr(foo[4],1,4) > 2000){\
    if(NR%3!=0) print "echo Parsing " $9 "\n" "python derwent_xml_update_parser_parallel.py -filename " $9 " -csv_dir " source_dir "/ & \n";\
  else print "echo Parsing " $9 "\n" "python derwent_xml_update_parser_parallel.py -filename " $9 " -csv_dir " source_dir "/ & \n\nwait";\
    }\
  }' >> $work_dir/parse_all_xml.sh
  tail -2 $work_dir/parse_all_xml.sh | grep -q wait && true || echo "wait" >> $work_dir/parse_all_xml.sh
  chmod 750 $work_dir/parse_all_xml.sh

  # e. Run the parse all script!
  cd $work_dir
  sh parse_all_xml.sh
  wait
  cd $cur_dir

  #f. change to CSV subdirectory and run the PostgreSQL loading script
  load_start=`date +%s`
  for file in $(find $csv_dir/$i$ending -name *_load.sh); do
    sh $file
    wait
  done

  #g. Report times for Unzipping and Parsing by decade
  decade_finish=`date +%s`
  echo "TASK DURATION FOR THE "$i"0's:"
  echo $((parse_start-unzip_start)) | awk '{print  int($1/60)":"int($1%60)  " : UNZIPPING DURATION" }'
  echo $((load_start-parse_start)) | awk '{print  int($1/60)":"int($1%60) " : PARSING DURATION"}'
  echo $((decade_finish-load_start)) | awk '{print  int($1/60)":"int($1%60) " : LOADING DURATION"}'
  echo $((decade_finish-unzip_start)) | awk '{print  int($1/60)":"int($1%60) " : TOTAL DECADE DURATION"}'
done

#3. Create Indices on the psql tables in the appropriate index tablespaces
index_start=`date +%s`
psql -d ernie -f create_derwent_indexes.sql

# 4. Report time taken to complete work for all files
process_finish=`date +%s`
echo $((process_finish-index_start)) | awk '{print  int($1/60)":"int($1%60) " : INDEX CREATION DURATION"}'
echo "TOTAL SMOKELOAD DURATION:"
echo $((process_finish-process_start)) | awk '{print  int($1/60)":"int($1%60) " : TOTAL PROCESS DURATION"}'

