# reporter_smokeload.sh
# Author: VJ Davey
# This is a program to load all the RePORTER csv data into the ernie database
# Date 09/26/2017

link_files=$1
proj_files=$2
cur_dir=$3
work_dir=$4
echo 'STARTED'; date
#create tables
psql ernie -f create_reporter_tables.sql
#unzip link_files and push into database
cd $work_dir; for file in $(ls $link_files/*.zip); do unzip $file; done
for file in $(ls $work_dir*.csv);do
  echo 'Working on file' $file
  psql ernie -c "copy reporter_publink from '$file' delimiter ',' CSV HEADER;" ; wait ;
done; rm $work_dir*.csv
#unzip proj_files, convert, and push into database
cd $work_dir; for file in $(ls $proj_files/*.zip); do unzip $file; done
for file in $(ls $work_dir*.csv);do
  echo 'Working on file' $file
  python $cur_dir/column_extractor.py $file; file_extract=$(echo $file | sed s/.csv/_EXTRACTED.csv/g)
  psql ernie -c "copy reporter_projects from '$file_extract' delimiter ',' CSV HEADER;" ; wait ;
done; rm $work_dir*.csv
echo 'FINISHED'; date
