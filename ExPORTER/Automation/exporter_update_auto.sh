#RePORTER Project weekly updates

# Author: VJ Davey
# Date: 12/08/17

# download the weekly RePORTER file and uncompress it
c_dir=$1
cd $c_dir

last_week=$(cat $c_dir/counter)
declare -i year=${last_week%_*}
declare -i week=${last_week#*_}
wget -q "https://exporter.nih.gov/CSVs/final/RePORTER_PRJ_C_FY${year}_$(printf "%03d" $week).zip" --no-check-certificate
if [ $? -ne 0 ]; then
  echo "Error: No CSV Download Available for year_week : ${year}_$(printf "%03d" $week)";
  echo "Please perform a manual check of the Exporter website and manually update counter file if necessary"
  exit 1;
fi
unzip $c_dir/*.zip; rm $c_dir/*.zip

# pass the download to the python script to extract the proper columns, then copy the data into the temp table
file=$(ls *.csv)
python $c_dir/column_extractor.py $file; file_extract=$(echo $file | sed s/.csv/_EXTRACTED.csv/g); file_extract=${c_dir}"/"${file_extract}
# truncate the temp project table: temp_exporter_projects. Then update the table with data from the extract
psql ernie -c "TRUNCATE TABLE temp_exporter_projects;"
psql ernie -c "COPY temp_exporter_projects from '${file_extract}' delimiter ',' CSV HEADER;"
# merge the temp table into the main table, update old records with new records based on pk match
# insert on conflict update
psql ernie -c "INSERT INTO temp_exporter_projects SELECT * from temp_exporter_projects ON CONFLICT ON CONSTRAINT exporter_projects_pk DO UPDATE SET APPLICATION_ID=excluded.APPLICATION_ID, ACTIVITY=excluded.ACTIVITY, ADMINISTERING_IC=excluded.ADMINISTERING_IC, APPLICATION_TYPE=excluded.APPLICATION_TYPE, ARRA_FUNDED=excluded.ARRA_FUNDED, AWARD_NOTICE_DATE=excluded.AWARD_NOTICE_DATE, BUDGET_START=excluded.BUDGET_START, BUDGET_END=excluded.BUDGET_END, CFDA_CODE=excluded.CFDA_CODE, CORE_PROJECT_NUM=excluded.CORE_PROJECT_NUM, ED_INST_TYPE=excluded.ED_INST_TYPE, FOA_NUMBER=excluded.FOA_NUMBER, FULL_PROJECT_NUM=excluded.FULL_PROJECT_NUM, SUBPROJECT_ID=excluded.SUBPROJECT_ID, FUNDING_ICs=excluded.FUNDING_ICs, FY=excluded.FY, IC_NAME=excluded.IC_NAME, NIH_SPENDING_CATS=excluded.NIH_SPENDING_CATS, ORG_CITY=excluded.ORG_CITY, ORG_COUNTRY=excluded.ORG_COUNTRY, ORG_DEPT=excluded.ORG_DEPT, ORG_DISTRICT=excluded.ORG_DISTRICT, ORG_DUNS=excluded.ORG_DUNS, ORG_FIPS=excluded.ORG_FIPS, ORG_NAME=excluded.ORG_NAME, ORG_STATE=excluded.ORG_STATE, ORG_ZIPCODE=excluded.ORG_ZIPCODE, PHR=excluded.PHR, PI_IDS=excluded.PI_IDS, PI_NAMEs=excluded.PI_NAMEs, PROGRAM_OFFICER_NAME=excluded.PROGRAM_OFFICER_NAME, PROJECT_START=excluded.PROJECT_START, PROJECT_END=excluded.PROJECT_END, PROJECT_TERMS=excluded.PROJECT_TERMS, PROJECT_TITLE=excluded.PROJECT_TITLE, SERIAL_NUMBER=excluded.SERIAL_NUMBER, STUDY_SECTION=excluded.STUDY_SECTION, STUDY_SECTION_NAME=excluded.STUDY_SECTION_NAME, SUFFIX=excluded.SUFFIX, SUPPORT_YEAR=excluded.SUPPORT_YEAR, TOTAL_COST=excluded.TOTAL_COST, TOTAL_COST_SUB_PROJECT=excluded.TOTAL_COST_SUB_PROJECT;"

#increment the counter file so we know where to start next time.
week=week+1
if (( week == 53 )); then
  year=year+1
  week=1
fi
echo "${year}_$(printf "%03d" $week)" > $c_dir/counter

#move the CSV files into storage
[ -d $c_dir/csv_files ] || mkdir -p $c_dir/csv_files
mv $file_extract $c_dir/csv_files; rm $c_dir/*.csv
