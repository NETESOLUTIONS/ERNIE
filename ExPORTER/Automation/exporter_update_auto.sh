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
psql ernie -c "INSERT INTO exporter_projects SELECT * from temp_exporter_projects ON CONFLICT ON CONSTRAINT temp_exporter_projects_pk DO UPDATE SET APPLICATION_ID=temp_exporter_projects.APPLICATION_ID, ACTIVITY=temp_exporter_projects.ACTIVITY, ADMINISTERING_IC=temp_exporter_projects.ADMINISTERING_IC, APPLICATION_TYPE=temp_exporter_projects.APPLICATION_TYPE, ARRA_FUNDED=temp_exporter_projects.ARRA_FUNDED, AWARD_NOTICE_DATE=temp_exporter_projects.AWARD_NOTICE_DATE, BUDGET_START=temp_exporter_projects.BUDGET_START, BUDGET_END=temp_exporter_projects.BUDGET_END, CFDA_CODE=temp_exporter_projects.CFDA_CODE, CORE_PROJECT_NUM=temp_exporter_projects.CORE_PROJECT_NUM, ED_INST_TYPE=temp_exporter_projects.ED_INST_TYPE, FOA_NUMBER=temp_exporter_projects.FOA_NUMBER, FULL_PROJECT_NUM=temp_exporter_projects.FULL_PROJECT_NUM, SUBPROJECT_ID=temp_exporter_projects.SUBPROJECT_ID, FUNDING_ICs=temp_exporter_projects.FUNDING_ICs, FY=temp_exporter_projects.FY, IC_NAME=temp_exporter_projects.IC_NAME, NIH_SPENDING_CATS=temp_exporter_projects.NIH_SPENDING_CATS, ORG_CITY=temp_exporter_projects.ORG_CITY, ORG_COUNTRY=temp_exporter_projects.ORG_COUNTRY, ORG_DEPT=temp_exporter_projects.ORG_DEPT, ORG_DISTRICT=temp_exporter_projects.ORG_DISTRICT, ORG_DUNS=temp_exporter_projects.ORG_DUNS, ORG_FIPS=temp_exporter_projects.ORG_FIPS, ORG_NAME=temp_exporter_projects.ORG_NAME, ORG_STATE=temp_exporter_projects.ORG_STATE, ORG_ZIPCODE=temp_exporter_projects.ORG_ZIPCODE, PHR=temp_exporter_projects.PHR, PI_IDS=temp_exporter_projects.PI_IDS, PI_NAMEs=temp_exporter_projects.PI_NAMEs, PROGRAM_OFFICER_NAME=temp_exporter_projects.PROGRAM_OFFICER_NAME, PROJECT_START=temp_exporter_projects.PROJECT_START, PROJECT_END=temp_exporter_projects.PROJECT_END, PROJECT_TERMS=temp_exporter_projects.PROJECT_TERMS, PROJECT_TITLE=temp_exporter_projects.PROJECT_TITLE, SERIAL_NUMBER=temp_exporter_projects.SERIAL_NUMBER, STUDY_SECTION=temp_exporter_projects.STUDY_SECTION, STUDY_SECTION_NAME=temp_exporter_projects.STUDY_SECTION_NAME, SUFFIX=temp_exporter_projects.SUFFIX, SUPPORT_YEAR=temp_exporter_projects.SUPPORT_YEAR, TOTAL_COST=temp_exporter_projects.TOTAL_COST, TOTAL_COST_SUB_PROJECT=temp_exporter_projects.TOTAL_COST_SUB_PROJECT;"

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
