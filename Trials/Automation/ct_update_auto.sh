 ernie #!/bin/sh
# This script downloads Clinical Trial data from its website and processes
# them to the ernie database. Specifically:
# 1. Create a set of new tables: new_ct_*.
# 2. Download data source from website.
# 3. Unzip to get XML files.
# 4. Run in parallel with 4 jobs: parse each XML to csv and load to tables:
#    new_ct_*.
# 5. Update tables.
# 6. Write to log.

#
# Author: Samet Keserci, part of this code is developed by (Lingtian "Lindsay" Wan, Shixin Jiang)
# Create Date: 09/18/2017
# Usage: sh /erniedev_data1/ERNIE/Trials/Automation/ct_update_auto.sh /erniedev_data1/CTupdate/ >> /erniedev_data1/CTupdate/log_ct_update_auto.out &


# Change to working directory.
c_dir=$1
cd $c_dir


# Stamp new time.
date
process_start=`date +%s`

# Remove previous NCT xml files, directories, and other related files.
echo ***Removing previous NCT files...
rm -rf ./nct_files/
rm nctload*
# Create brand new nct_files directory
mkdir nct_files

# Create new CT tables.
date
echo ***Creating CT tables...
psql -d ernie -f createtable_new_ct_tables.sql

# download: directly from website
wget -r 'https://clinicaltrials.gov/ct2/results/download?term=&down_fmt=xml&down_typ=results&down_stds=all' -O CT_all.zip
mv CT_all.zip ./nct_files

# Unzip the XML files.
echo ***Unzipping CT data...
unzip ./nct_files/CT_all.zip -d ./nct_files

echo ***Processing loading files...
# Write a load file.
ls nct_files/ |grep NCT | grep xml | awk -v store_dir=$c_dir '{split($1,filename,".");print "python /erniedev_data1/ERNIE/Trials/Automation/ct_xml_update_parser.py -filename " $1 " -csv_dir " store_dir "nct_files/\n" "psql ernie < " store_dir "nct_files/" filename[1] "/" filename[1] "_load.pg" }' > load_nct_all.sh
chmod 755 load_nct_all.sh

echo ***Splitting to small loading files...
# Split load file to seperate files for parallel running.
split -l $(($(wc -l < load_nct_all.sh)/2/4*2)) load_nct_all.sh nctload
chmod 775 nctload*

# Run load files in parallel.
echo ***Loading files...
for i in $(ls ./nctload*); do
  sh $i &
done
wait

# Upload database.
echo ***Uploading database tables...
psql -d ernie -f /erniedev_data1/ERNIE/Trials/Automation/ct_update_tables.sql


# Send log to emails.
psql -d ernie -c 'select * from update_log_ct;' | mail -s "ERNIE NOTICE :: Clinical Trial  Weekly Update Log" samet@nete.com george@nete.com avon@nete.com

# Stamp end time.
date

process_end=`date +%s`
echo $((process_end-process_start)) |  awk '{print int($1/3600) " hour : " int(($1/60)%60) " min : " int($1%60) " sec :: UPDATE PROCESS END-to-END  DURATION UTC"}'
echo -e "\n\n"
