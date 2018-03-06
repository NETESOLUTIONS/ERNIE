# Author: VJ Davey
# This script will be used to generalize analysis and produce reference generation for the desired drugs given:
# the baseline reference generation sql script, the drug name, and two files holding review and seedset PMIDs

# Collect input w/ getopts
#baseline_sql=$1; drug_name=$2; seedset_pmids=$3; review_pmids=$4; seedset_wos_ids=$5; iters=$6
while getopts "b:f:u:d:s:r:w:i:y:a:" opt; do
  case $opt in
    b) baseline_sql=$OPTARG ;;
    f) baseline_sql_forward=$OPTARG ;;
    u) baseline_sql_union=$OPTARG ;;
    d) drug_name=$OPTARG ;;
    s) seedset_pmids=$OPTARG ;;
    r) review_pmids=$OPTARG ;;
    w) seedset_wos_ids=$OPTARG ;;
    i) iters=$OPTARG ;;
    y) year_cutoff=$OPTARG ;;
    a) analysis=$OPTARG ;;
  esac
done
# drop any lines in place on the seedset and review files that may hinder our script
sed -i '/^\s*$/d' $seedset_pmids; sed -i '/^\s*$/d' $review_pmids; sed -i '/^\s*$/d' $seedset_wos_ids;
# populate pmid seedset base, wos seedset base, and pmid review tables
psql ernie -c "DROP TABLE IF EXISTS case_"$drug_name"_review_set;"
psql ernie -c "CREATE TABLE case_"$drug_name"_review_set(pmid integer);"
[[ ! $review_pmids ]] && echo 'review pmids not given' || psql ernie -c "COPY case_"$drug_name"_review_set FROM '"$review_pmids"';"

psql ernie -c "DROP TABLE IF EXISTS case_"$drug_name"_seed_set;"
psql ernie -c "CREATE TABLE case_"$drug_name"_seed_set(pmid integer);"
[[ ! $seedset_pmids ]] && echo 'seed pmids not given' || psql ernie -c "COPY case_"$drug_name"_seed_set FROM '"$seedset_pmids"';"

psql ernie -c "DROP TABLE IF EXISTS case_"$drug_name"_wos_supplement_set;"
psql ernie -c "CREATE TABLE case_"$drug_name"_wos_supplement_set(source_id character varying(30));"
[[ ! $seedset_wos_ids ]] && echo 'supplementary wos ids not given' || psql ernie -c "COPY case_"$drug_name"_wos_supplement_set FROM '"$seedset_wos_ids"';"
# Run baseline sql scripts through sed, then execute the appropriate action
echo "year cutoff is ${year_cutoff}" ; echo "num iters is ${iters}"
cat $baseline_sql | sed 's/DRUG_NAME_HERE/'$drug_name'/g'| sed 's/INSERT_DESIRED_NUMBER_OF_ITERATIONS_HERE/'$iters'/g' | sed 's/YEAR_CUTOFF_HERE/'$year_cutoff'/g'  > $drug_name'_reference_generation.sql'
cat $baseline_sql_forward | sed 's/DRUG_NAME_HERE/'$drug_name'/g'| sed 's/INSERT_DESIRED_NUMBER_OF_ITERATIONS_HERE/'$iters'/g' | sed 's/YEAR_CUTOFF_HERE/'$year_cutoff'/g'  > $drug_name'_reference_generation_forward.sql'
cat $baseline_sql_union | sed 's/DRUG_NAME_HERE/'$drug_name'/g'| sed 's/INSERT_DESIRED_NUMBER_OF_ITERATIONS_HERE/'$iters'/g' | sed 's/YEAR_CUTOFF_HERE/'$year_cutoff'/g'  > $drug_name'_reference_generation_union.sql'


if [ "${analysis}" == "backward" ]; then
  psql ernie -f  $drug_name'_reference_generation.sql'
elif [ "${analysis}" == "forward" ]; then
  psql ernie -f  $drug_name'_reference_generation_forward.sql'
elif [ "${analysis}" == "both" ]; then
  psql ernie -f  $drug_name'_reference_generation_forward.sql'
  psql ernie -f  $drug_name'_reference_generation.sql'
elif [ "${analysis}" == "both+network_union"  ]; then
  psql ernie -f  $drug_name'_reference_generation_forward.sql'
  psql ernie -f  $drug_name'_reference_generation.sql'
  psql ernie -f  $drug_name'_reference_generation_union.sql'
else
  echo "Invalid selection. Please set analysis option and specify the type of analyis as one of the following: <forward> | <backward> | <both>"
  exit 1
fi
