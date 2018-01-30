#!/usr/bin/env bash
# Author: Samet Keserci, Lingtian "Lindsay" Wan
# Create Date: 02/24/2016
# Modified:
# * 06/07/2016, Lindsay Wan, divided wos_references update to loops of small chunks
# * 11/17/2016, Lindsay Wan, added command to prepare a file list of parsed csv directories for production server
# * 11/28/2016, Lindsay Wan, added list del wos files to a txt for prod server.
# * 08/07/2017, Samet Keserci, revised it for smokeload and added a parameter for update file dir
# * 08/07/2017, Samet Keserci, added timestamp log and debug points.
# * 08/07/2017, Samet Keserci, added more timestamp and log and debug points, revised to update in parallel.
# * 08/18/2017, Samet Keserci, added more timestamp and log and debug points, improved the parallel process.
# * 01/26/2018, Dmitriy "DK" Korobskiy
# ** Enabled running from any directory
# ** Simplified

if [[ $1 == "-h" ]]; then
  cat <<END
SYNOPSIS
  $0 [working_directory]
  $0 -h: display this help

DESCRIPTION
  This script updates the Web of Science (WOS) tables on an ETL process.
  Specifically:
  1. Get files (WOS_CORE and .del) downloaded but not updated yet;
  2. Unzip .del files and combine WOS ids in these files to a single file;
  3. Unzip WOS_CORE files to get XML files;
  4. Split XML files to smaller files, so that Python parser can handle;
  5. For each small file, parse to CSV and load CSV to database new tables:
    new_wos_*;
  6. Update the main WOS tables (wos_*) with records in new tables (new_wos_*);
  7. Delete records from the main WOS tables (wos_*) with WOS id in .del files;
  8. Update log file.

  Uses the specified working_directory ({script_dir}/build/ by default).
END
  exit 1
fi

set -x
#set -xe
#set -o pipefail

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

#process_start=`date +%s`
update_file_dir=update_files/

process_start=`date +%s`


# Change to working directory
c_dir=$work_dir
#cd $c_dir

#update_file_dir=$2

# Remove previous timestamp and stamp the current time.
rm starttime.txt
rm endtime.txt
date
date > starttime.txt

# Remove previous files.
rm complete_filelist.txt
rm todo_filelist.txt
rm split_all_xml_files.sh
rm load_wos_update.sh
rm cp_file.sh
rm del_wosid.csv
rm unzip_all.sh
rm ./xml_files_splitted/*.xml

# Copy from update_file_dir to current directory the WOS_CORE and .del files
# that have not been updated.
echo ***Comparing file list...
ls $update_file_dir > complete_filelist.txt
sed -i '/ESCI/d' complete_filelist.txt # delete lines with ESCI files
grep -Fxvf finished_filelist.txt complete_filelist.txt > todo_filelist.txt
cat todo_filelist.txt | awk -v upd_file_dir=$update_file_dir '{print "cp " upd_file_dir $1 " ."}' > cp_file.sh
sh cp_file.sh

# Get WOS IDs from .del files.
echo ***Extracting WOS IDs from .del files...
# Unzip delete files.
gunzip WOS*.del.gz
# Save delete WOS IDs to a delete records file.
cat WOS*.del | awk '{split($1,filename,",");print "WOS:" filename[2]}' > del_wosid.csv

# before starting update, analyze tables
#psql -d ernie -f analyze_wos_tables.sql


# Update WOS_CORE files one by one, in time sequence.
for file in $(ls *.tar.gz | sort -n)
do
  tar_gz_process_start=`date +%s`

  echo -e "\n\n" >> time_keeper.txt
  echo "processing CORE file (UTC): "$file >> time_keeper.txt
  date >> time_keeper.txt
  # Unzip update file to a sub-directory.
  echo ***Unzipping update file: $file
  # if the format is tar.gz
   tar -zxvf $file *.xml*
  # if the format is tar only
  # tar -xvf $file *.xml*

  gunzip ${file%%.*}/*
  # Split update xml file to small pieces and move to ./xml_files_splitted/.
  echo ***Splitting update file: $file
  find ./${file%%.*} -name '*.xml' | sort | awk '{print "echo Splitting " $1 "\n" "python new_xml_split.py " $1 " REC 20000"}' > split_all_xml_files.sh
  sh split_all_xml_files.sh
  find ./${file%%.*} -name '*SPLIT*' -print0 | xargs -0 mv -t ./xml_files_splitted
  # Write update file loading commands to a script.
  echo ***Preparing load update file: $file
  ls xml_files_splitted | grep .xml | awk -v store_dir=$c_dir ' {split($1,filename,".");print "echo Parsing " $1 "\n" "python wos_xml_update_parser.py -filename " $1 " -csv_dir " store_dir "xml_files_splitted/\n" "echo Loading " $1 "\n" "psql ernie < " store_dir "xml_files_splitted/" filename[1] "/" filename[1] "_load.pg" }' > load_wos_update.sh
  # Parse and load update file to the database.
  echo ***Parsing and loading update file to database: $file
  sh load_wos_update.sh

  # before starting update, analyze new wos tables
  psql -d ernie -f analyze_new_wos_tables.sql

  # Update the WOS tables.
  echo ***Updating WOS tables
  echo "Updating CORE file in DB is started (UTC): " >> time_keeper.txt
  date >> time_keeper.txt

  wos_update_process_in_db_started=`date +%s`

  # Update wos tables other than wos_referneces.
  echo "Pre-Process started (UTC): " >> time_keeper.txt
  date >> time_keeper.txt
  psql -d ernie -f wos_parallel_update_preprocess.sql

  echo "Indexation started (UTC): " >> time_keeper.txt
  date >> time_keeper.txt
  sh wos_parallel_update_create_index.sh

  wait


  # Update wos_reference table.
  echo "wos_tables UPDATE is started (UTC): " >> time_keeper.txt
  date >> time_keeper.txt
  wos_ref_update_process_start=`date +%s`


  echo -e "\n\n" >> log_wos_nonref.out
  echo "wos_update_nonref_parallel.sh script is started (UTC) for core file"$file >> log_wos_nonref.out
  date >> log_wos_nonref.out
  nohup sh  wos_update_nonref_parallel.sh  >> log_wos_nonref.out &

  chmod 777 -R $c_dir/table_split/
  python wos_update_split_db_table.py -tablename new_wos_references -rowcount 10000 -csv_dir $c_dir/table_split/
  chmod 777 -R $c_dir/table_split/
  psql -d ernie -f ./table_split/load_csv_table.sql


  for table_chunk in $(cat ./table_split/split_tablename.txt)
  do
    echo $table_chunk
    chunk_start_date=`date +%s`
    psql -d ernie -f wos_update_ref_tables.sql -v new_ref_chunk=$table_chunk
    chunk_end_date=`date +%s`
    echo $((chunk_end_date-chunk_start_date)) |  awk '{print int($1/3600) " hour : " int(($1/60)%60) " min : " int($1%60) " sec ::  This Chunk Update Duration" }'
  done


  wos_ref_update_process_end=`date +%s`

  # wait to all 9-table update task is finished
  wait

  echo "wos UPDATE is done, cleaning is started (UTC): " >> time_keeper.txt
  date >> time_keeper.txt;

  psql -d ernie -c 'truncate table new_wos_references;'
  psql -d ernie -c 'update update_log_wos set last_updated = current_timestamp where id = (select max(id) from update_log_wos);'
  rm -f table_split/*.csv
  rm xml_files_splitted/*.xml
  rm table_split/load_csv_table.sql
  rm table_split/split_tablename.txt
  printf $file'\n' >> finished_filelist.txt

  tar_gz_process_end=`date +%s`



  # keep elapsed time for each tar.gz. file
  echo $((wos_update_process_in_db_started-tar_gz_process_start)) |  awk '{print int($1/3600) " hour : " int(($1/60)%60) " min : " int($1%60) " sec ::  Single CORE File Split-Parse-Load-Preparation Duration UTC" }' >> time_keeper.txt
  echo $((wos_ref_update_process_end-wos_ref_update_process_start)) |  awk '{print int($1/3600) " hour : " int(($1/60)%60) " min : " int($1%60) " sec ::  Single CORE File wos_ref processing Duration UTC" }' >> time_keeper.txt
  echo $((tar_gz_process_end-tar_gz_process_start)) |  awk '{print int($1/3600) " hour : " int(($1/60)%60) " min : " int($1%60) " sec ::  Single CORE File TOTAL processing Duration UTC" }' >> time_keeper.txt

 echo -e "\n\n"

done


# Delete table records with delete wos_ids.
echo "Delete operation is started UTC"
date
delete_process_start=`date +%s`
echo "Delete operation started UTC" >> time_keeper.txt
date >> time_keeper.txt



psql -d ernie -f wos_delete_tables_preprocess.sql -v delete_csv="'"$c_dir"del_wosid.csv'"

wait

psql -d ernie -f wos_delete_abstracts.sql &
psql -d ernie -f wos_delete_addresses.sql &
psql -d ernie -f wos_delete_authors.sql &
psql -d ernie -f wos_delete_doc_iden.sql &
psql -d ernie -f wos_delete_grants.sql &
psql -d ernie -f wos_delete_keywords.sql &
psql -d ernie -f wos_delete_publications.sql &
psql -d ernie -f wos_delete_references.sql &
psql -d ernie -f wos_delete_titles.sql &

wait

echo "Delete operation is finished UTC"
date
echo "Delete operation is finished UTC" >> time_keeper.txt
date >> time_keeper.txt
delete_process_end=`date +%s`


psql -d ernie -c "update update_log_wos set last_updated = current_timestamp, num_wos = (select count(1) from wos_publications) where id = (select max(id) from update_log_wos);"

echo $((delete_process_end-delete_process_start)) |  awk '{print int($1/3600) " hour : " int(($1/60)%60) " min : " int($1%60) " sec ::  All Delete File processing Duration UTC" }' >> time_keeper.txt



ls WOS*.del | awk '{print $1 ".gz"}' >> finished_filelist.txt

# Delete update and .del files.
rm *.del
rm -rf WOS*CORE
rm -rf WOS*ESCI
rm WOS*tar.gz

# Prepare csv directory list for Production server.
#ls ./xml_files_splitted/ | grep WOS_RAW > parsed_csv_dir.txt
#ls $update_file_dir | grep del.gz > del_wosid_filelist.txt

# Stamp the time.
date > endtime.txt

echo "All cleanings are done" >> time_keeper.txt
date >> time_keeper.txt
date

# Send log via email.
psql -d ernie -c 'select * from update_log_wos order by id;' | mail -s "WOS Weekly Update Log" avon@nete.com

process_end=`date +%s`
echo $((process_end-process_start)) |  awk '{print int($1/3600) " hour : " int(($1/60)%60) " min : " int($1%60) " sec :: UPDATE PROCESS END-to-END  DURATION UTC"}' >> time_keeper.txt



printf "\n\n"
