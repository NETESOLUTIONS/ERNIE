#!/bin/sh

# This script updates Clinical Guidelines (CG) tables cg_*.
# Specifically:
# 1. Download a complete list of CG from website;
# 2. Get the links with CG uids.
# 3. Use Python to scrape the links to get PMIDs if there's any.
# 4. Update uids and PMIDs to cg tables cg_*.

# Tables updated: cg_uids, cg_uid_pmid_mapping, update_log_cg.

# Usage: sh cg_update_auto.sh work_dir/
# where work_dir specifies working directory.

# Author: Lingtian "Lindsay" Wan
# Monitoring : Samet Keserci
# Date: 03/23/2016
# Modified: 05/20/2016, Lindsay Wan, added documentation
#           June/2016, Samet Keserci, added try/except to web request
#           07/11/2016, Lindsay Wan, added generating check file at the end for CG generation flow.
#           8/1/2016. Samet Keserci, revised the code for AHRQ's new website.
#           12/09/2016, Lindsay Wan, download CG data from gateway server.
#           12/13/2016, Lindsay Wan, move abstract extraction to front.
#           01/09/2017, Lindsay Wan, convert html characters like &#8211 to text
#           01/10/2017, Lindsay Wan, fixed bugs in conversion
#           03/20/2017, Samet Keserci, revised according to migration from dev2 to dev3


process_start=`date +%s`

# Edit path as appropriate.
c_dir=$1
cd $c_dir


# Copy all codes from repo to working directory
cp /erniedev_data1/ERNIE/Guidelines/Automation/* $c_dir

# Remove stamped times, and stamp new time.
rm starttime.txt
rm endtime.txt
date
date > starttime.txt

# Remove previous files.
rm *.csv
rm ngc_complete.xml*

# Download new CG data files.
echo ***Downloading CG data files...
wget http://www.guideline.gov/rssFiles/ngc_complete.xml

# Convert html characters like &#8211 to text.
mv ngc_complete.xml old_ngc_complete.xml
xmllint old_ngc_complete.xml --format | recode html > ngc_complete.xml
rm old_ngc_complete.xml

# Use xmllint to format XMl file;
# use grep to grab lines with string <link>;
# use sed to replace the strings <\link> , <link> and f=rss&amp; with empty;
# use tr -d to remove white spaces in the lines;
# put results in a new file.
echo ***Preparing links and uids...
cat ngc_complete.xml | grep \<link\> > ngc_with_link.csv
cat ngc_with_link.csv | sed 's/<link>//' | sed 's/<\/link>//' | \
sed 's/f\=rss\&amp;//' | tr -d ' ' > ngc_all_link.csv

# Sort and grab those lines with 'content' in them.
cat ngc_all_link.csv | grep summaries  > ngc_uid_link.csv

# Sort and grab those lines *without* 'content' in them.
cat ngc_all_link.csv | grep -v summaries  > ngc_other_link.csv

# Strip all except the UID at the end of the URL.
grep -o '[[:digit:]]\+' ngc_uid_link.csv > ngc_uid.csv
grep -o '[[:digit:]]\+' ngc_other_link.csv > ngc_other.csv

# Do the same thing for titles.
cat ngc_complete.xml | grep \<title\> > ngc_with_title.txt
cat ngc_with_title.txt | sed 's/<title>//' | sed 's/<\/title>//' | \
sed 's/^[ \t]*//' > ngc_all_title.txt

# Sort and grab those lines with 'Guideline Summary' in them.
cat ngc_all_title.txt |grep 'Guideline Summary'  > ngc_uid_title.txt

# Combine uids and titles to one file.
paste ngc_uid.csv ngc_uid_title.txt > ngc_combined.txt

# Use Python to grab PMID from UID.
echo ***Grabbing PMIDs from uids...
python -u cg_pmidextractor.py

# Use SQL to update CG tables.
echo ***Updating tables...
psql -d ernie -f cg_update_tables.sql \
-v mapping="'"$c_dir"/uid_to_pmid.csv'" \
-v combined="'"$c_dir"/ngc_combined.txt'"


# ************** CG FLOW PART *****************************

# Calculate the reference countings.
#echo ***calculating references countings...
#psql -d ernie -f cg_flow_ref_count.sql

# update cg_ernie_uid_pmid_abstract table
#echo ***Get Abstracts
#sh /erniedev_data1/Guidelines/Automation/cg_get_abstract_auto.sh

# Stamp end time.
#date > endtime.txt
#date

#printf "\n\n"
#echo CG update finished > cg_gen_check_1.txt
#chmod 664 cg_gen_check_1.txt

#**************************************************************

# Send log to emails.
#psql -d ernie -c 'select * from update_log_cg; select * from cg_ref_counts;' | mail -s "Clinical Guidelines Weekly Update Log" george@nete.com samet@nete.com
psql -d ernie -c 'select * from update_log_cg;' | mail -s "Clinical Guidelines Weekly Update Log" samet@nete.com george@nete.com avon@nete.com


process_end=`date +%s`
echo $((process_end-process_start)) |  awk '{print int($1/3600) " hour : " int(($1/60)%60) " min : " int($1%60) " sec :: UPDATE PROCESS END-to-END  DURATION UTC"}'
echo -e "\n\n"
