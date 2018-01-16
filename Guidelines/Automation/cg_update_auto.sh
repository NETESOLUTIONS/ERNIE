#!/usr/bin/env bash
# Author: Lingtian "Lindsay" Wan
# Monitoring : Samet Keserci
# Created: 03/23/2016
# Modified:
# * 05/20/2016, Lindsay Wan, added documentation
# * June 2016, Samet Keserci, added try/except to web request
# * 07/11/2016, Lindsay Wan, added generating check file at the end for CG generation flow.
# * 08/01/2016. Samet Keserci, revised the code for AHRQ's new website.
# * 12/09/2016, Lindsay Wan, download CG data from gateway server.
# * 12/13/2016, Lindsay Wan, move abstract extraction to front.
# * 01/09/2017, Lindsay Wan, convert html characters like &#8211 to text
# * 01/10/2017, Lindsay Wan, fixed bugs in conversion
# * 03/20/2017, Samet Keserci, revised according to migration from dev2 to dev3
# * 01/08/2018, Dmitriy "DK" Korobskiy
# ** enhanced to enable running from any directory
# ** refactored cg_get_abstract_auto.sh to cg_get_abstract_auto.sql

if [[ $1 == "-h" ]]; then
  cat << END
SYNOPSIS
  $0 [working_directory]
  $0 -h: display this help

DESCRIPTION
  This script updates Clinical Guidelines (CG) tables cg_*.

  Specifically:
  1. Downloads a complete list of CGs
  2. Gets the links with CG uids
  3. Scrapes the links to get PMIDs if any
  4. Updates uids and PMIDs in cg_uids, cg_uid_pmid_mapping, update_log_cg.

  Uses the specified working_directory ({script_dir}/build/ by default).
END
  exit 1
fi

set -xe

# Get a script directory, same as by $(dirname $0)
script_dir=${0%/*}
absolute_script_dir=$(cd "${script_dir}" && pwd)
work_dir=${1:-${absolute_script_dir}/build} # $1 with the default
[[ ! -d "$work_dir" ]] && mkdir "$work_dir"
cd "$work_dir"
echo -e "\n## Running under ${USER}@${HOSTNAME} at ${PWD} ##\n"

# Remove stamped times, and stamp new time.
#rm starttime.txt
#rm endtime.txt
#date
#date > starttime.txt

# Remove previous files.
rm -f ngc_complete.xml
rm -f *.csv

${absolute_script_dir}/download.sh

# Convert html characters like &#8211 to text.
mv ngc_complete.xml old_ngc_complete.xml
xmllint old_ngc_complete.xml --format | recode html > ngc_complete.xml
rm -f old_ngc_complete.xml

# Use xmllint to format XMl file;
# use grep to grab lines with string <link>;
# use sed to replace the strings <\link> , <link> and f=rss&amp; with empty;
# use tr -d to remove white spaces in the lines;
# put results in a new file.
echo ***Preparing links and uids...
cat ngc_complete.xml | grep \<link\> > ngc_with_link.csv
cat ngc_with_link.csv | sed 's/<link>//' | sed 's/<\/link>//' | sed 's/f\=rss\&amp;//' | tr -d ' ' > ngc_all_link.csv

# Sort and grab those lines with 'content' in them.
cat ngc_all_link.csv | grep summaries  > ngc_uid_link.csv

# Sort and grab those lines *without* 'content' in them.
cat ngc_all_link.csv | grep -v summaries  > ngc_other_link.csv

# Strip all except the UID at the end of the URL.
grep -o '[[:digit:]]\+' ngc_uid_link.csv > ngc_uid.csv
grep -o '[[:digit:]]\+' ngc_other_link.csv > ngc_other.csv

# Do the same thing for titles.
cat ngc_complete.xml | grep \<title\> > ngc_with_title.txt
cat ngc_with_title.txt | sed 's/<title>//' | sed 's/<\/title>//' | sed 's/^[ \t]*//' > ngc_all_title.txt

# Sort and grab those lines with 'Guideline Summary' in them.
cat ngc_all_title.txt |grep 'Guideline Summary'  > ngc_uid_title.txt

# Combine uids and titles to one file.
paste ngc_uid.csv ngc_uid_title.txt > ngc_combined.txt

# Use Python to grab PMID from UID.
echo ***Grabbing PMIDs from uids...
/anaconda2/bin/python -u ${absolute_script_dir}/cg_pmidextractor.py

# Use SQL to update CG tables.
echo ***Updating tables...
psql -f ${absolute_script_dir}/cg_update_tables.sql -v mapping="${work_dir}/uid_to_pmid.csv" \
     -v combined="${work_dir}/ngc_combined.txt"

#region ERNIE-specific

# Calculate the reference countings.
#echo ***calculating references countings...
#psql -f cg_flow_ref_count.sql

# update cg_ernie_uid_pmid_abstract table
#echo ***Get Abstracts
#sh /erniedev_data1/Guidelines/Automation/cg_get_abstract_auto.sh

# Stamp end time.
#date > endtime.txt
#date

#printf "\n\n"
#echo CG update finished > cg_gen_check_1.txt
#chmod 664 cg_gen_check_1.txt

# Send log to emails.
#psql -c 'select * from update_log_cg;' | mail -s "Clinical Guidelines Weekly Update Log" samet@nete.com george@nete.com avon@nete.com

psql -c 'SELECT * FROM update_log_cg ORDER BY id'
#endregion