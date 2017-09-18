#!/bin/sh
#########################################################################################################
# Script Name  : master_loader_wos.sh (parallel process upto 5x faster)
# Old versions : process_wos_year_data.sh (serial process)
# Usage        : sh master_loader_wos.sh zipped_year_file source_xml_dir target_csv_dir wos_script_dir
# Author       : Samet Keserci - inspired by previous work of Shixin Jiang
# Date         : 07/25/2017
# Aim          : This script is the master script to parse and load annual Web of Science (WOS) data into postgres DB.
#########################################################################################################




zipped_year_file=$1 # zipped source file name (in years)
source_xml_dir=$2 # main directory of the source xml files
target_csv_dir=$3 # main directory of csv files
wos_script_dir=$4 # main directory of scripts

echo " Processing of the file $zipped_year_file is started UTC"
date
process_start=`date +%s`

# 1. change the directory to the source_xml_dir
cd $source_xml_dir

# Get the file name without extension
xml_file_dir=${zipped_year_file%.*}

# 2. create a subdirectory xml_file_dir to hold the year xml files
echo ***Creating subdirectory...
if [ ! -d $xml_file_dir ]; then
  mkdir $xml_file_dir
fi

mv $zipped_year_file ${zipped_year_file%.*}

cd ${zipped_year_file%.*}
# 3. uncompress the zipped year file
echo ***Unzipping files...

echo "UNZIP operation is started UTC"
date
unzip_start=`date +%s`

unzip $zipped_year_file

# 4. move the source file back to the original directory
echo ***Moving sourcefile back...
mv $zipped_year_file ../.

# 5. copy the Python codes under WOS_LOADER directories where all scripts placed in.
echo ***Copying python codes...
cp $wos_script_dir/*.py .

# 6. uncompress all gzipped xml files
echo ***Unzipping xml.gz files...
gunzip *.xml.gz
FILES_YEAR=${xml_file_dir:0:4}

# 7. build script to split xml files to 20000 records each.
echo "SPLIT operation is started UTC"
date
split_start=`date +%s`


echo ***Building split script...
ls -ltr *.xml|awk '{if (NR%8!=0) print "echo Splitting file: " $9 "\n" "python xml_split.py " $9 " REC 20000 &"; \
                   else print "echo Splitting file: " $9 "\n" "python xml_split.py " $9 " REC 20000 & \n\nwait\n" ;}' > split_all_xml_files.sh

echo -e "\n\n wait \n" >> split_all_xml_files.sh

# 8. change the permission of the shell script

chmod 755 split_all_xml_files.sh

# 9. run the script to split the xml files
echo ***Splitting files...
sh split_all_xml_files.sh

echo **waiting to split part to be finished.
wait

echo "PARSING operation is started UTC"
date
parse_start=`date +%s`

# 10. create a script to parse each xml and load the corresponding CSV files
echo ***Building parsing and loading script...
wos_csv_dir=${target_csv_dir}${FILES_YEAR}
if [ ! -d $wos_csv_dir ]; then
    mkdir -p $wos_csv_dir
fi

# parsing script is being generated
ls -ltr SPLIT*.xml|awk -v TARGET_DIR=$wos_csv_dir ' { if (NR%8!=0) print "echo Parsing " $9 "\n" "python wos_xml_parser_parallel.py -filename " $9 " -csv_dir " TARGET_DIR "/ & \n"; \
else print "echo Parsing " $9 "\n" "python wos_xml_parser_parallel.py -filename " $9 " -csv_dir " TARGET_DIR "/ & \n\n wait \n"; }' > parse_"$FILES_YEAR"_all.sh

echo -e "\n\n wait \n" >> parse_"$FILES_YEAR"_all.sh

# run the parsing script
sh parse_"$FILES_YEAR"_all.sh

wait

# 11. create a script to load the csv files into postgres DB

echo "LOADING operation is started UTC"
date
load_start=`date +%s`


# Load script is being generated
ls -ltr SPLIT*.xml|awk -v TARGET_DIR=$wos_csv_dir ' {split($9,filename,"."); print "echo Loading " $9 "\n" "sh " TARGET_DIR "/" filename[1] "/" filename[1] "_load.sh \n\nwait\n " }' > load_"$FILES_YEAR"_all.sh


chmod 755 load_"$FILES_YEAR"_all.sh

# run the load script to load csv data to PostgreSQL
echo ***Starting parsing and loading...
sh load_"$FILES_YEAR"_all.sh

wait

echo " Processing of the file $zipped_year_file is done UTC"
process_finish=`date +%s`
date

echo **DURATION OF EACH BATCH/PARALLEL TASKS**
echo $((split_start-unzip_start)) | awk '{print  int($1/60)":"int($1%60)  " : UNZIPPING DURATION UTC" }'
echo $((parse_start-split_start)) | awk '{print  int($1/60)":"int($1%60) " : SPLITTING DURATION UTC"}'
echo $((load_start-parse_start)) | awk '{print  int($1/60)":"int($1%60) " : PARSING  DURATION UTC"}'
echo $((process_finish-load_start)) | awk '{print  int($1/60)":"int($1%60) " : LOADING DURATION UTC"}'
echo $((process_finish-process_start)) | awk '{print  int($1/60)":"int($1%60) " : TOTAL DURATION UTC"}'
