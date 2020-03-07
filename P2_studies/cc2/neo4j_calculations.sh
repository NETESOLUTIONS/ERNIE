#!/usr/bin/env bash

declare -ri FATAL_FAILURE_CODE=255
if [[ $1 == "-h" ]]; then
  cat << 'HEREDOC'
NAME

  neo4j_calculations.sh -- To calculate citation distance and time lag measurements in neo4j
  1 parameter i.e file with co-citation pairs is accepted

  example: bash neo4j_calculations.sh input_file.csv

  NOTE: Currently citation distance is taking longer to run, hence commented out

SYNOPSIS
  neo4j_calculations.sh -h: display this help  


EXIT STATUS

    Exits with one of the following values:

    0    Success
    1    An error occurred
    255  fatal failure

HEREDOC
  exit $FATAL_FAILURE_CODE
fi

start_time=`date +%s`

set -e
set -o pipefail
# Initially off: is turned on by `-v -v`
set +x

readonly SCRIPT_DIR=${0%/*}
readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)
readonly WORKING_DIRECTORY=$2
readonly INPUT_FILE=$1
readonly OUTPUT_FILE=$3

readonly CITATION_DISTANCE_FILE=$(echo ${INPUT_FILE} | cut -d '.' -f 1)"_citation_distance.csv"
readonly TIME_LAG_FILE=$(echo ${INPUT_FILE} | cut -d '.' -f 1)"_time_lag.csv"
readonly FREQUENCY_FILE=$(echo ${INPUT_FILE} | cut -d '.' -f 1)"_frequency.csv"
readonly SCOPUS_FREQUENCY_FILE=$(echo ${INPUT_FILE} | cut -d '.' -f 1)"_scopus_frequency.csv"
readonly KINETICS_FILE=$(echo ${INPUT_FILE} | cut -d '.' -f 1)"_kinetics.csv"

echo "Directory is" ${ABSOLUTE_SCRIPT_DIR}

#Creating working directory where split files are stored
readonly work_dir=${WORKING_DIRECTORY}/work_dir
readonly results_dir=${WORKING_DIRECTORY}/results_dir


#Add code for 1st line in output files
# echo "cited_1,cited_1_year,cited_2,cited_2_year,first_cited_year" >> ${ABSOLUTE_SCRIPT_DIR}/${TIME_LAG_FILE}
echo "cited_1,cited_2,co_cited_year,frequency" >> ${ABSOLUTE_SCRIPT_DIR}/${OUTPUT_FILE}
#echo "cited_1,cited_2,frequency,scopus_frequency" >> ${ABSOLUTE_SCRIPT_DIR}/${FREQUENCY_FILE}
#echo "cited_1,cited_2,scopus_frequency" >> ${ABSOLUTE_SCRIPT_DIR}/${SCOPUS_FREQUENCY_FILE}

echo "Working directory is ${work_dir}"
readonly file_prefix="data"
mkdir -p ${work_dir}
mkdir -p ${results_dir}

if [[ -d ${results_dir} ]]
then
    rm -rf ${results_dir}
else
    mkdir ${results_dir}
fi

#Copying input file to working directory
cp ${ABSOLUTE_SCRIPT_DIR}/${INPUT_FILE} ${work_dir}

cd ${work_dir}

#export all variables
export ABSOLUTE_SCRIPT_DIR
export work_dir
export TIME_LAG_FILE
export FREQUENCY_FILE
export SCOPUS_FREQUENCY_FILE
export KINETICS_FILE
export results_dir

#Input file is assumed to be atleast 1000 lines, splitting into chunks of 1000 lines
split -d -l 100 ${work_dir}/${INPUT_FILE} ${file_prefix} --additional-suffix='.csv'


cypher_pairs() {
  local file_name=$(echo $1 | cut -d '/' -f 2)

  local result_file=$(echo ${file_name} | cut -d '.' -f 1)"_results.csv"

  echo "file name is ${file_name}"

  printf "load csv from 'file://${work_dir}/${file_name}' AS csvFile
  MATCH (a:Publication{node_id: toInteger(csvFile[0])})<-[r:CITES]-(p:Publication)-[x:CITES]->(b:Publication {node_id: toInteger(csvFile[1])})
  RETURN a.node_id AS cited_1,a.pub_year AS cited_1_year,b.node_id AS cited_2,b.pub_year AS cited_2_year,
  min(p.pub_year) AS first_cited_year;" | cypher-shell | grep -v 'cited_1' | sed 's/ //g;s/"//g'>> ${results_dir}/${result_file}

}

export -f cypher_pairs


scopus_frequency() {
  local file_name=$(echo $1 | cut -d '/' -f 2)

  local result_file=$(echo ${file_name} | cut -d '.' -f 1)"_results.csv"

  echo "file name is ${file_name}"

  printf "load csv from 'file://${work_dir}/${file_name}' AS csvFile
match (a:Publication{node_id:toInteger(csvFile[0])})<-[r:CITES]-(p:Publication)-[x:CITES]->(b:Publication{node_id:toInteger(csvFile[1])})
return a.node_id AS cited_1,b.node_id AS cited_2,
count(p) AS scopus_frequency;" | cypher-shell | grep -v 'cited_1' | sed 's/ //g;s/"//g' >> ${results_dir}/${result_file}

}
#p.pub_year AS cited_year,
export -f scopus_frequency

kinetics() {
  local file_name=$(echo $1 | cut -d '/' -f 2)

  local result_file=$(echo ${file_name} | cut -d '.' -f 1)"_results.csv"

  echo "file name is ${file_name}"

  printf "load csv from 'file://${work_dir}/${file_name}' AS csvFile
match (a:Publication{node_id:toInteger(csvFile[0])})<-[r:CITES]-(p:Publication)-[x:CITES]->(b:Publication{node_id:toInteger(csvFile[1])})
return a.node_id AS cited_1,b.node_id AS cited_2,p.pub_year AS co_cited_year,
count(p) AS frequency;" | cypher-shell | grep -v 'cited_1' | sed 's/ //g;s/"//g'>> ${results_dir}/${result_file}


}

export -f kinetics


set +e

#Find all files with perfix and pass it parallel
find . -name ${file_prefix}'*' -type f -print0 | parallel -0 --halt soon,fail=1 -j 8 \
        --line-buffer --tagstring '|job#{#}/{= $_=total_jobs() =} s#{%}|' kinetics "{}"

set -e

#Code to clean up working directory
rm -rf ${work_dir}

#Adding data back into main file
for file in $(ls ${results_dir})
do
    echo "Merging file $file"
    cat ${results_dir}/$file >> ${ABSOLUTE_SCRIPT_DIR}/${OUTPUT_FILE}
done

cp ${ABSOLUTE_SCRIPT_DIR}/${OUTPUT_FILE} ${WORKING_DIRECTORY}

end=`date +%s`
runtime=$((end-start))

echo "Total runtime ${runtime}"