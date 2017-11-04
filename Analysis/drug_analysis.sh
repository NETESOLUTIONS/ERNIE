# Author: VJ Davey
# This script will be used to generalize analysis and produce reference generation for the desired drugs given:
# the baseline reference generation sql script, the drug name, and two files holding review and seedset PMIDs

# Collect input
baseline_sql=$1; drug_name=$2; seedset_pmids=$3; review_pmids=$4; iters=$5
# drop any lines in place on the seedset and review files that may hinder our script
sed -i '/^\s*$/d' $seedset_pmids; sed -i '/^\s*$/d' $review_pmids; 
# populate seedset and review pmid tables
psql ernie -c "DROP TABLE IF EXISTS case_"$drug_name"_review_set;"
psql ernie -c "CREATE TABLE case_"$drug_name"_review_set(pmid integer);"
psql ernie -c "COPY case_"$drug_name"_review_set FROM '"$review_pmids"';"

psql ernie -c "DROP TABLE IF EXISTS case_"$drug_name"_seed_set;"
psql ernie -c "CREATE TABLE case_"$drug_name"_seed_set(pmid integer);"
psql ernie -c "COPY case_"$drug_name"_seed_set FROM '"$seedset_pmids"';"
# Run baseline through sed, then execute
cat $baseline_sql | sed 's/DRUG_NAME_HERE/'$drug_name'/g'| sed 's/INSERT_DESIRED_NUMBER_OF_ITERATIONS_HERE/'$iters'/g'  > $drug_name'_reference_generation.sql'
psql ernie -f  $drug_name'_reference_generation.sql'
