#!/usr/bin/env bash
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME

   exporter_weekly_update.sh -- download ExPORTER project and abstract CSVs from exporter.nih.gov
                         and update in the PostgreSQL databased

SYNOPSIS

   exporter_weekly_update.sh [ -w data_directory ] 

   exporter_weekly_update.sh -h: display this help

DESCRIPTION

   Download zip files into the working directory and update the database
   The following option(s) is available:

    -w  work_dir          parent directory of directory where the ZIP files are stored
    
HEREDOC
  exit 1
fi

if [[ ! -f /anaconda3/bin/python ]]; then
    echo "/anaconda3/bin/python does not exist."
    exit 1
fi

set -e
set -o pipefail

while (( $# > 0 )); do
  echo "Using CLI arg '$1'"
  case "$1" in
    -w)
      shift
      WORK_DIR=$1
      ;;
    *)
      break
  esac
  shift
done

cd ${WORK_DIR}
echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##"

# Download Zip files in a local storage directory

mkdir -p RePORTER_downloads
cd RePORTER_downloads
# Download the weekly RePORTER file and uncompress it
echo "Downloading..."

last_week=$(cat ../counter)
last_week=$( echo $last_week | sed 's/_/_10#/g') #added a prepending on the week to get past octal errors
declare -i year=${last_week%_*}
declare -i week=${last_week#*_}

wget -q "https://exporter.nih.gov/CSVs/final/RePORTER_PRJ_C_FY${year}_$(printf "%03d" $week).zip" --no-check-certificate
if [ $? -ne 0 ]; then
  echo "No CSV Download Available for year_week : ${year}_$(printf "%03d" $week)";
  echo "Additional files may be available for download next week."
  echo "OR"
  echo "Please perform a manual check of the Exporter website and manually update counter file if necessary"
  break
  exit 1;
fi
wget -q "https://exporter.nih.gov/CSVs/final/RePORTER_PRJABS_C_FY${year}_$(printf "%03d" $week).zip" --no-check-certificate

for file in $(ls *.zip); do unzip $file ; done

# pass the download to the python script to extract the proper columns, then copy the data into the temp table
file=$(ls RePORTER_PRJ_C*.csv)
python ../column_extractor.py $file; file_extract=$(echo $file | sed s/.csv/_EXTRACTED.csv/g); file_extract=${WORK_DIR}"/"RePORTER_downloads"/"${file_extract}
# truncate the temp project table: temp_exporter_projects. Then update the table with data from the extract
psql ernie -c "TRUNCATE TABLE temp_exporter_projects;"
psql ernie -c "COPY temp_exporter_projects from '${file_extract}' delimiter ',' CSV HEADER;"
# merge the temp table into the main table, update old records with new records based on pk match
# insert on conflict update
psql ernie -c "INSERT INTO exporter_projects SELECT * from temp_exporter_projects ON CONFLICT ON CONSTRAINT exporter_projects_pk DO UPDATE SET APPLICATION_ID=excluded.APPLICATION_ID, ACTIVITY=excluded.ACTIVITY, ADMINISTERING_IC=excluded.ADMINISTERING_IC, APPLICATION_TYPE=excluded.APPLICATION_TYPE, ARRA_FUNDED=excluded.ARRA_FUNDED, AWARD_NOTICE_DATE=excluded.AWARD_NOTICE_DATE, BUDGET_START=excluded.BUDGET_START, BUDGET_END=excluded.BUDGET_END, CFDA_CODE=excluded.CFDA_CODE, CORE_PROJECT_NUM=excluded.CORE_PROJECT_NUM, ED_INST_TYPE=excluded.ED_INST_TYPE, FOA_NUMBER=excluded.FOA_NUMBER, FULL_PROJECT_NUM=excluded.FULL_PROJECT_NUM, SUBPROJECT_ID=excluded.SUBPROJECT_ID, FUNDING_ICs=excluded.FUNDING_ICs, FY=excluded.FY, IC_NAME=excluded.IC_NAME, NIH_SPENDING_CATS=excluded.NIH_SPENDING_CATS, ORG_CITY=excluded.ORG_CITY, ORG_COUNTRY=excluded.ORG_COUNTRY, ORG_DEPT=excluded.ORG_DEPT, ORG_DISTRICT=excluded.ORG_DISTRICT, ORG_DUNS=excluded.ORG_DUNS, ORG_FIPS=excluded.ORG_FIPS, ORG_NAME=excluded.ORG_NAME, ORG_STATE=excluded.ORG_STATE, ORG_ZIPCODE=excluded.ORG_ZIPCODE, PHR=excluded.PHR, PI_IDS=excluded.PI_IDS, PI_NAMEs=excluded.PI_NAMEs, PROGRAM_OFFICER_NAME=excluded.PROGRAM_OFFICER_NAME, PROJECT_START=excluded.PROJECT_START, PROJECT_END=excluded.PROJECT_END, PROJECT_TERMS=excluded.PROJECT_TERMS, PROJECT_TITLE=excluded.PROJECT_TITLE, SERIAL_NUMBER=excluded.SERIAL_NUMBER, STUDY_SECTION=excluded.STUDY_SECTION, STUDY_SECTION_NAME=excluded.STUDY_SECTION_NAME, SUFFIX=excluded.SUFFIX, SUPPORT_YEAR=excluded.SUPPORT_YEAR, TOTAL_COST=excluded.TOTAL_COST, TOTAL_COST_SUB_PROJECT=excluded.TOTAL_COST_SUB_PROJECT;"

#update the abstracts table
file=$(ls RePORTER_PRJABS_C*.csv); file=${WORK_DIR}"/"RePORTER_downloads"/"${file}
psql ernie -c "TRUNCATE TABLE temp_exporter_project_abstracts;"
psql ernie -c "COPY temp_exporter_project_abstracts from '${file}' delimiter ',' CSV HEADER encoding 'latin1';"
psql ernie -c "INSERT INTO exporter_project_abstracts SELECT * from temp_exporter_project_abstracts ON CONFLICT ON CONSTRAINT exporter_project_abstracts_pk DO UPDATE SET APPLICATION_ID=excluded.APPLICATION_ID, ABSTRACT_TEXT=excluded.ABSTRACT_TEXT;"

#move the CSV files into storage and clean zip files out
[ -d ../csv_files ] || mkdir -p ../csv_files
mv $file_extract ../csv_files; mv $file ../csv_files; rm *.csv ; rm *.zip

## update the exporter log

psql -f ../exporter_update_log.sql

week=week+1
if (( week == 53 )); then
  year=year+1
  week=1
fi
#increment the counter file so we know where to start next time.
echo "${year}_$(printf "%03d" $week)" > ../counter


echo "Update complete."




