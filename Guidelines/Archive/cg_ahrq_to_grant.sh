#!/bin/sh
# This bash script processes Clinical Guidelines (CG) data from AHRQ to Grant.
# Specifically:
# 1. Download source ngc_complete.xml file from the AHRQ;
# 2. Grab uids from the XML file and to a .csv file;
# 3. Use uids to find related PMIDs if existing (Python).
# 4. Use PMIDs to find grant numbers for cited references (SQL).

# Usage: sh cg_ahrq_to_grant.sh work_dir
# where work_dir specifies working directory storing the Python and SQL files.

# Author: George Chacko, Lingtian "Lindsay" Wan, Avis
# Date: 02/16/2016

# Edit path as appropriate.
c_dir=$1
cd $c_dir

rm starttime.txt
rm endtime.txt
date > starttime.txt

# Remove previous files.
rm ngc_complete.xml
rm *.csv

# Download XML file.
curl http://www.guideline.gov/rssFiles/ngc_complete.xml > ./ngc_complete.xml

# Use xmllint to format XMl file;
# use grep to grab lines with string <link>;
# use sed to replace the strings <\link> , <link> and f=rss&amp; with empty;
# use tr -d to remove white spaces in the lines;
# put results in a new file.
xmllint ngc_complete.xml --format | grep \<link\> > ngc_with_link.csv
cat ngc_with_link.csv | sed 's/<link>//' | sed 's/<\/link>//' | \
sed 's/f\=rss\&amp;//' | tr -d ' ' > ngc_all_link.csv

# Sort and grab those lines with 'content' in them.
cat ngc_all_link.csv | sort |grep content  > ngc_uid_link.csv
num_uid=$(wc -l < ngc_uid_link.csv)

# Sort and grab those lines *without* 'content' in them.
cat ngc_all_link.csv | sort |grep -v content  > ngc_other_link.csv

# Strip all except the UID at the end of the URL.
cat ngc_uid_link.csv | sed -n -e 's/^.*=//p' > ngc_uid.csv
cat ngc_other_link.csv | sed -n -e 's/^.*=//p' > ngc_other.csv

# Use Python to grab PMID from UID.
python cg_pmidextractor.py

# Use SQL to transfer PMID to Grant #.
psql -d pardi -f cg_pmid_to_grant.sql \
-v source_dir="'"$c_dir"/uid_to_pmid.csv'" \
-v sql_num_uid=$num_uid
