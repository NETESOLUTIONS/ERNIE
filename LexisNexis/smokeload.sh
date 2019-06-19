#!/usr/bin/env bash
if [[ "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    lexis_nexis_smokeload.sh -- process a directory of Lexis Nexis XML data

SYNOPSIS

    lexis_nexis_smokeload.sh [-c] [-e] [-v] [-v] [-s subset_SP] [-t tmp_dir] [-f failed_files_dir] [working_dir]
    lexis_nexis_smokeload.sh -h: display this help

    This script is largely based on the process_directory.sh script from ERNIE Scopus

DESCRIPTION

    Decompress in the target directories
    Parse all XMLs available in each subdirectory in parallel and upsert data into the DB.
    Produce an error log in `{tmp_dir}/errors.log`.
    Produce output with reduced verbosity to reduce the log volume.

    The following options are available:

    -c    clean load: truncate data. WARNING: be aware that you'll lose all loaded data!

    -e    stop on the first error. Parsing and other SQL errors don't fail the build unless `-e` is specified.

    -v    verbose output: print processed XML files and error details as errors occur

    -v -v extra-verbose output: print all lines (`set -x`)

    -s subset_SP: parse a subset of data via the specified subset parsing Stored Procedure (SP)

    -t tmp_dir: relative to working_dir, `tmp` or `tmp-{SP_name}` (for subsets) by default
          WARNING: be aware that tmp_dir is removed before processing and on success

    -f failed_files_dir: move failed XML files to failed_files_dir: relative to working_dir, `../failed/` by default
          WARNING: be aware that failed_files_dir is cleaned before processing

    To stop process gracefully after the current zip file is processed, create a `{working_dir}/.stop` signal file.

ENVIRONMENT

    * PGHOST/PGDATABASE/PGUSER  default Postgres connection parameters


EXAMPLES

    To run in verbose mode and stop on the first error:

      $ ./lexis_nexis_smokeload.sh -e -v /erniedev_data4/IPDD/LNU5554/??/Xml/*/*.zip

    To run in verbose mode and only parse US 1970 data:

      $ ./lexis_nexis_smokeload.sh -e -v /erniedev_data4/IPDD/LNU5554/US/Xml/197*/*.zip

    To run a parser subset and stop on the first error:

      ll ../failed$ ./lexis_nexis_smokeload.sh -s LexisNexis_parse_history -e  /pardidata3/LexisNexis/LexisNexis-API-2.0_xml_10_2018.tar.gz

HEREDOC
  exit 1
fi

set -e
set -o pipefail

readonly STOP_FILE=".stop"
# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
declare -rx ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)
declare -rx ERROR_LOG=error.log
declare -rx PARALLEL_LOG=parallel.log
PROCESSED_LOG="processed.log"
FAILED_FILES_DIR="failed"

while (( $# > 0 )); do
  echo "Using CLI arg '$1'"
  case "$1" in
    -c)
      readonly CLEAN_MODE=true
      ;;
    -e)
      readonly STOP_ON_THE_FIRST_ERROR=true
      ;;
    -r)
      readonly SORT_ORDER="--reverse"
      ;;
    -f)
      shift
      echo "Using CLI arg '$1'"
      readonly FAILED_FILES_DIR="$1"
      ;;
    -p)
      shift
      echo "Using CLI arg '$1'"
      readonly PROCESSED_LOG="$1"
      ;;
    -s)
      shift
      echo "Using CLI arg '$1'"
      readonly SUBSET_SP=$1
      ;;
    -t)
      shift
      tmp=$1
      ;;
    -v)
      # Second "-v" = extra verbose?
      if [[ "$VERBOSE" == "true" ]]; then
        set -x
      else
        declare -rx VERBOSE=true
      fi
      ;;
    -z)
      shift
      tmp=$1
      ;;
    -w)
      shift
      WORK_DIR=$1
      ;;
    *)
      break
  esac
  shift
done

arg_array=( "$@" )
echo "${arg_array[*]}"
# Courtesy of https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash
IFS=$'\n' sorted_args=($(sort ${SORT_ORDER} <<<"${arg_array[*]}")); unset IFS

cd ${WORK_DIR}
if [[ ! ${tmp} ]]; then
  if [[ ${SUBSET_SP} ]]; then
    tmp="tmp-${SUBSET_SP}"
  else
    tmp="tmp"
  fi
fi

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##"

if ! which parallel >/dev/null; then
  echo "Please install GNU Parallel"
  exit 1
fi

parse_xml() {
  local xml="$1"
  [[ $2 ]] && local subset_option="-v subset_sp=$2"
  local file_identification="-v file_name=$2"
  echo ${file_identification}
  [[ ${VERBOSE} == "true" ]] && echo "Processing $xml ..."
  if psql -q -f ${ABSOLUTE_SCRIPT_DIR}/Postgres/parser.sql -v "xml_file=$PWD/$xml" ${subset_option} ${file_identification} 2>>"${ERROR_LOG}"; then
    [[ ${VERBOSE} == "true" ]] && echo "$xml: SUCCESSFULLY PARSED."
    return 0
  else
    local full_xml_path=$(realpath ${xml})
    local full_error_log_path=$(realpath ${ERROR_LOG})
    cd ${tmp}
    [[ ! -d "${failed_files_dir}" ]] && mkdir -p "${failed_files_dir}"
    mv -f $full_xml_path "${failed_files_dir}/"
    cp $full_error_log_path "${failed_files_dir}/"
    [[ ${VERBOSE} == "true" ]] && echo "$xml: FAILED DURING PARSING."
    return 1
  fi
}
export -f parse_xml

check_errors() {
  # Errors occurred? Does the error log have a size greater than zero?
  if [[ -s "${ERROR_LOG}" ]]; then
    if [[ ${VERBOSE} == "true" ]]; then
      cat <<HEREDOC
Error(s) occurred during processing of ${PWD}.
=====
HEREDOC
      cat "${ERROR_LOG}"
      echo "====="
    fi
    cd ..
    chmod -R g+w "${FAILED_FILES_DIR}"
    exit 1
  fi
}

if [[ ${CLEAN_MODE} == "true" ]]; then
  echo "IN CLEAN MODE. TRUNCATING ALL DATA AND REFRESHING WORKSPACE..."
  psql -f ${ABSOLUTE_SCRIPT_DIR}/Postgres/clean_data.sql
  rm -rf "${FAILED_FILES_DIR}"
  rm -rf ${tmp}
  mkdir "${FAILED_FILES_DIR}"
fi

declare -i num_zips=${#sorted_args[@]}
declare -i failed_xml_counter=0 failed_xml_counter_total=0 processed_xml_counter=0 processed_xml_counter_total=0
declare -i process_start_time i=0 start_time stop_time delta delta_s delta_m della_h elapsed=0 est_total eta

for zip in "${sorted_args[@]}" ; do
  start_time=$(date '+%s')
  if grep -q "^${zip}$" "${PROCESSED_LOG}"; then
    echo "Skipping file ${zip} ( zip file #$((++i)) out of ${num_zips} ). It is already marked as completed."
  else
    echo -e "\nProcessing ${zip} ( zip file #$((++i)) out of ${num_zips} )..."

    # Unzip data into relative tmp directory
    unzip -u -q ${zip} -d ${tmp}

    # Preprocess files in ${tmp} due to BOM present in shared files
    # NOTE: BOM is visible via $cat -A ${XML_FILE} . Should be three characters that mess up the Postgres parser
    sed -i '1s/^\xEF\xBB\xBF//' ${tmp}/*.xml

    #Identify whether it's US file or EP file
    if [[ ${zip} == *"US"* ]]; then
      file_name="US"
    else
      file_name="EP"
    fi

    # Process XML files using GNU parallel
    export failed_files_dir="$(realpath "${FAILED_FILES_DIR}")/$(basename ${zip%.zip})"
    cd ${tmp}
    rm -f "${ERROR_LOG}"
    if ! find -name '*.xml' | parallel ${PARALLEL_HALT_OPTION} --joblog ${PARALLEL_LOG} --line-buffer \
        --tagstring '|job#{#} s#{%}|' parse_xml "{}" ${SUBSET_SP} ${file_name}; then
      [[ ${STOP_ON_THE_FIRST_ERROR} == "true" ]] && check_errors # Exits here if errors occurred
    fi
    while read -r line; do
      if echo $line | grep -q "1"; then
        ((++failed_xml_counter))
      else
        ((++processed_xml_counter))
      fi
    done < <(awk 'NR>1{print $7}' "${PARALLEL_LOG}")
    rm -rf "${PARALLEL_LOG}"
    cd ../
    rm -rf ${tmp}

    # Status report
    echo "SUMMARY FOR ${zip}:"
    echo "SUCCESSFULLY PARSED ${processed_xml_counter} XML FILES"
    if ((failed_xml_counter == 0)); then
      echo "ALL IS WELL"
    else
      echo "FAILED PARSING ${failed_xml_counter} XML FILES"
    fi
    ((failed_xml_counter_total += failed_xml_counter)) || :
    failed_xml_counter=0
    ((processed_xml_counter_total += processed_xml_counter)) || :
    processed_xml_counter=0
    # Add if condition to only add zip to processed log when zero errors occured
    echo "${zip}" >> "${PROCESSED_LOG}"

    if [[ -f "${STOP_FILE}" ]]; then
      echo -e "\nFound the stop signal file. Gracefully stopping..."
      break
    fi

    stop_time=$(date '+%s')
    ((delta = stop_time - start_time + 1)) || :
    ((delta_s = delta % 60)) || :
    ((delta_m = (delta / 60) % 60)) || :
    ((della_h = delta / 3600)) || :
    printf "$(TZ=America/New_York date) :  Done with ${zip} file in %dh:%02dm:%02ds\n" ${della_h} \
           ${delta_m} ${delta_s}
    if (( i < num_zips )); then
      ((elapsed = elapsed + delta))
      ((est_total = num_zips * elapsed / i)) || :
      ((eta = process_start_time + est_total))
      echo "ETA for job completion: $(TZ=America/New_York date --date=@${eta})"
    fi
  fi
done

echo -e "\nSMOKELOAD SUMMARY:"
echo "SUCCESSFULLY PARSED ${processed_xml_counter_total} XML FILES"
if ((failed_xml_counter_total == 0)); then
  echo "ALL IS WELL"
else
  echo "FAILED PARSING ${failed_xml_counter_total} XML FILES"
fi

for directory in "${FAILED_FILES_DIR}"; do
  cd $directory
  check_errors # Exits here if errors occurred
  cd
done

exit 0
