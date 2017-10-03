########################################################################################################
# Program Name: ftp_process_parallel.sh
# Usage:        ftp_process_parallel.sh source_dir work_dir csv_dir
#           source_dir is the directory holding the xml.gz files, work_dir is a space where the script can do its job, csv_dir is the desired output directory for csv files
# Author:       VJ Davey,  Lingtian "Lindsay" Wan
# Date:         08/18/2017, VJ Davey, created script as an offshoot of derwent update auto
#########################################################################################################

# Change to working directory.
source_dir=$1
work_dir=$2
csv_dir=$3
cur_dir=$(pwd)
process_start=`date +%s`

# For each update file, parse, load, and update.
for file in $(ls $source_dir/*.tar | sort -n)
do
  # Clear the work dir
  cd $work_dir
  rm -rf $work_dir/*
  # Copy in the python codes
  cp $cur_dir/*.py $work_dir
  # For each file in update source dir, copy that file to the work dir
  cd $source_dir
  cp $file $work_dir
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
  ls *.xml | grep -w xml | awk -v store_dir=$csv_dir/$subdir ' {split($1,filename,"."); if(NR%4!=0) print "echo Parsing " $1 "\n" "python derwent_xml_update_parser_parallel.py -filename " $1 " -csv_dir " store_dir "/ & \n";\
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
done
process_finish=`date +%s`
echo "TOTAL UPDATE DURATION:"
echo $((process_finish-process_start)) | awk '{print  int($1/60)":"int($1%60) " : TOTAL PROCESS DURATION"}'
