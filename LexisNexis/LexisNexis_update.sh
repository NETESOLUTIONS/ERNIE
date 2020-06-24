#!/usr/bin/env bash
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME

   LexisNexis_update.sh -- update LexisNexis data in a PostgreSQL database using zipped (*.zip)
                           LexisNexis XMLs downloaded via the IPDD API
                           Note that clean mode is NOT available with this script.

SYNOPSIS

   LexisNexis_update.sh [ -e max_errors ] [ -f failed_files_dir ] [ -p processed_log ] [ -s subset_SP ]
                        [ -t tmp_dir ] [ -v ] [ -v ] [ -w work_dir ]

   LexisNexis_update.sh -h: display this help

DESCRIPTION

   Extract all ZIP files from the `{work_dir}/API_downloads/` (`./API_downloads/` by default) into the `{tmp_dir}/`.aaaa12345
   Process extracted ZIPs one-by-one.
   Produce an error log in `{tmp_dir}/errors.log`.

   The following options are available:

    -w work_dir         directory where IPDD data is stored
    -s subset_SP        parse a subset of data via the specified subset parsing Stored Procedure (SP)
    -t tmp_dir          defaults to `{work_dir}/tmp` or `{work_dir}/tmp-{SP_name}` for subsets
                        WARNING: be aware that `{tmp_dir}` is removed before processing and on success.
    -p processed_log    record file for successfully completed data ZIPs, defaults to `{work_dir}/processed.log`
    -e max_errors       stop when the error number reaches this threshold, 101 by default
    -f failed_files_dir set directory where failed files should be stored, defaults to `{work_dir}/failed/`
    -v                  verbose output: print processed XML files
    -v -v               extra-verbose output: print all lines (`set -x`)

    To stop process gracefully after the current ZIP is processed, create a `{working_dir}/.stop` signal file.
    This file is automatically removed

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
    -e)
      shift
      declare -ri MAX_ERRORS=$1
      (( MAX_ERRORS > 0 )) && readonly PARALLEL_HALT_OPTION="--halt soon,fail=${MAX_ERRORS}"
      readonly STOP_ON_THE_FIRST_ERROR=true
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
      if [[ "$VERBOSE" == "true" ]]; then
        set -x
      else
        declare -rx VERBOSE=true
      fi
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

mkdir -p "${FAILED_FILES_DIR}"
parse_xml() {
  local xml="$1"
  [[ $2 ]] && local subset_option="-v subset_sp=$2"
  [[ ${VERBOSE} == "true" ]] && echo "Processing $xml ..."
  #Identify whether it's US file or EP file
  if [[ ${xml} == *"US"* ]]; then
    file_identification="-v file_name=US"
  else
    file_identification="-v file_name=EP"
  fi

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

declare -i num_zips=$(find . -name "*.zip" -type f | wc -l)
declare -i failed_xml_counter=0 failed_xml_counter_total=0 processed_xml_counter=0 processed_xml_counter_total=0
declare -i process_start_time i=0 start_time stop_time delta delta_s delta_m della_h elapsed=0 est_total eta
process_start_time=$(date '+%s')

for zip in API_downloads/*.zip; do
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

    # Process XML files using GNU parallel
    export failed_files_dir="$(realpath "${FAILED_FILES_DIR}")/$(basename ${zip%.zip})"
    cd ${tmp}
    rm -f "${ERROR_LOG}"
    if ! find -name '*.xml' | parallel ${PARALLEL_HALT_OPTION} --joblog ${PARALLEL_LOG} --line-buffer \
        --tagstring '|job#{#} s#{%}|' parse_xml "{}" ${SUBSET_SP}; then
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
    cd - >/dev/null
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

echo -e "\nUPDATE SUMMARY:"
echo "SUCCESSFULLY PARSED ${processed_xml_counter_total} XML FILES"
if ((failed_xml_counter_total == 0)); then
  echo "ALL IS WELL"
else
  echo "FAILED PARSING ${failed_xml_counter_total} XML FILES"
fi


cd "${FAILED_FILES_DIR}"
check_errors # Exits here if errors occurred
cd


declare -i days_to_keep_zip_files=90
echo "Removing files older than ${days_to_keep_zip_files} days ..."
find ${WORK_DIR}/API_downloads/ -type f -mtime +$((days_to_keep_zip_files - 1)) -print -delete

exit 0
