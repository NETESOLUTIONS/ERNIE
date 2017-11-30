#!/bin/sh
# This script updates the FDA Orange Book data files in three tables:
# fda_patents, fda_products, fda_exclusivities.
# Specifically, it does the following:
# 1. Download data files to local directory;
# 2. Unzip and reformat files to .csv files.
# 3. Update data in database.

# Usage: sh fda_update_auto.sh work_dir/
#        where work_dir specifies working directory.

# Author: Lingtian "Lindsay" Wan
# Monitoring: Samet Keserci
# Create Date: 03/07/2016
# Modified: 05/19/2016, Lindsay Wan, added documentation
#           03/16/2017, Samet Keserci, updates are set for ernie_admin

# Change to working directory
c_dir=$1
cd $c_dir

# copy all the updated codes into working directory
cp /erniedev_data1/ERNIE/Registered_Products/Automation/*  ./

# Remove stamped times and stamp new time.
rm starttime.txt
rm endtime.txt
date > starttime.txt
date

# Remove previous files.
echo ***Removing previous FDA files...
rm fda_files.zip
rm *atent*
rm products*
rm exclusivity*


# Download new FDA data files. Orange Book.
echo ***Downloading FDA data files...
wget -r http://www.fda.gov/downloads/Drugs/InformationOnDrugs/UCM163762.zip \
-O fda_files.zip


# Unzip and reformat data files.
echo ***Unzipping and reformatting...
unzip fda_files.zip
cat exclusivity*.txt > exclusivity.csv
cat Patent*.txt > patent.csv
cat patent*.txt >> patent.csv
cat products*.txt > products.csv

# Load data to database.
echo ***Loading data to database...
psql -d ernie -f createtable_new_fda.sql
psql -d ernie -f load_fda_data.sql \
-v exclusivity="'"$c_dir"/exclusivity.csv'" \
-v patent="'"$c_dir"/patent.csv'" \
-v products="'"$c_dir"/products.csv'"

# Update data to database.
echo ***Updating database...
psql -d ernie -f fda_update_tables.sql

# Stamp end time.
date > endtime.txt
date

# Send log file to emails.
psql -d ernie -c 'select * from update_log_fda;' | mail -s "FDA Monthly Update Log" george@nete.com avon@nete.com samet@nete.com

printf '\n\n'
