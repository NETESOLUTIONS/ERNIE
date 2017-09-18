#!/bin/sh
#########################################################################################################
# Program Name: dfix_master_loader_wos.sh
# Usage:	sh dfix_master_loader_wos.sh source_xml_dir target_csv_dir wos_script_dir
#    ex: nohup sh dfix_master_loader_wos.sh [source xml] [target csv] [script dir] > log_dfix.out &
# Author:	VJ Davey, Samet Keserci, Shixin Jiang
# Date:		08/07/2017
#########################################################################################################

source_xml_dir=$1
target_csv_dir=$2
wos_script_dir=$3

echo " Processing of the Dupfix is started UTC"
date
process_start=`date +%s`

# 1. change the directory to the source_xml_dir holding the unzipped duplicate editions file
cd $source_xml_dir

# 2. copy the Python codes under WOS_LOADER directories where all scripts placed in.
echo ***Copying python codes...
cp $wos_script_dir/*.py .
FILES_YEAR="dup_fix"

# 3. build script to split the duplicate editions file to 20000 records each.
echo "SPLIT operation is started UTC"
date
split_start=`date +%s`
echo ***Building split script...
ls -ltr *.xml|awk '{if (NR%8!=0) print "echo Splitting file: " $9 "\n" "python xml_split.py " $9 " REC 20000 &"; \
                   else print "echo Splitting file: " $9 "\n" "python xml_split.py " $9 " REC 20000 & \n\nwait\n" ;}' > split_all_xml_files.sh
echo -e "\n\n wait \n" >> split_all_xml_files.sh
# change the permission of the shell script
chmod 755 split_all_xml_files.sh
# run the script to split the xml files
echo ***Splitting files...
sh split_all_xml_files.sh
echo **waiting to split part to be finished.
wait


# 4. create a script to parse each xml and load the corresponding CSV files
echo "PARSING operation is started UTC"
date
parse_start=`date +%s`
echo ***Building parsing and loading script...
wos_csv_dir=${target_csv_dir}${FILES_YEAR}
if [ ! -d $wos_csv_dir ]; then
    mkdir -p $wos_csv_dir
fi
# parsing script is being generated -- changed the script to write wait every 3 rows instead of 8 to be memory safe due to etree creation in the xml_parser.
ls -ltr SPLIT*.xml|awk -v TARGET_DIR=$wos_csv_dir ' { if (NR%3!=0) print "echo Parsing " $9 "\n" "python dfix_wos_xml_parser.py -filename " $9 " -csv_dir " TARGET_DIR "/ & \n"; \
else print "echo Parsing " $9 "\n" "python dfix_wos_xml_parser.py -filename " $9 " -csv_dir " TARGET_DIR "/ & \n\n wait \n"; }' > parse_"$FILES_YEAR"_all.sh
echo -e "\n\n wait \n" >> parse_"$FILES_YEAR"_all.sh
# Parse
sh parse_"$FILES_YEAR"_all.sh
wait

# 5. Load csv data to PostgreSQL 
echo "LOADING operation is started UTC"
date
load_start=`date +%s`
# Load script is being generated
ls -ltr SPLIT*.xml|awk -v TARGET_DIR=$wos_csv_dir ' {split($9,filename,"."); print "echo Loading " $9 "\n" "sh " TARGET_DIR "/" filename[1] "/" filename[1] "_load.sh \n\nwait\n " }' > load_"$FILES_YEAR"_all.sh
# change the permission of the shell script
chmod 755 load_"$FILES_YEAR"_all.sh
echo ***Starting parsing and loading...
# Load
sh load_"$FILES_YEAR"_all.sh
wait

# 6. Wrap up
echo " Processing of the dupfix file is done UTC"
process_finish=`date +%s`
date
echo **DURATION OF EACH BATCH/PARALLEL TASKS**
echo $((parse_start-split_start)) | awk '{print  int($1/60)":"int($1%60) " : SPLITTING DURATION UTC"}'
echo $((load_start-parse_start)) | awk '{print  int($1/60)":"int($1%60) " : PARSING  DURATION UTC"}'
echo $((process_finish-load_start)) | awk '{print  int($1/60)":"int($1%60) " : LOADING DURATION UTC"}'
echo $((process_finish-process_start)) | awk '{print  int($1/60)":"int($1%60) " : TOTAL DURATION UTC"}'
