#!/usr/bin/env bash
if [[ "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    process_data_directory.sh -- process a directory of Scopus data for either update or smokeload job

SYNOPSIS

    process_data_directory.sh -u|-k [-e] [-v] [-v] [-s subset_SP] [-t tmp_dir] [-f failed_files_dir] [working_dir]
    process_data_directory.sh -h: display this help

DESCRIPTION

    Extract all source Scopus ZIP files from the working_dir (`.` by default) into the tmp_dir.
    Process extracted ZIPs one-by-one. Parse all XMLs and update data in the DB in parallel.
    Produce an error log in `{tmp_dir}/errors.log`.
    Produce output with reduced verbosity to reduce the log volume.

    The following options are available:

    -u    update job: specifies that the job is an update versus smokeload

    -k    smokeload job : specificies that the job is a smokeload versus update

    -n    number of jobs, n=1 then serial, n > 1 parallel

    -e    stop on the first error. Parsing and other SQL errors don't stop the script unless `-e` is specified.

    -p    create a process log which is used as part of the update job

    -v    verbose output: print processed XML files and error details as errors occur

    -v -v extra-verbose output: print all lines (`set -x`)

    -s subset_SP: parse a subset of data via the specified subset parsing Stored Procedure (SP)

    -t tmp_dir: relative to working_dir, `tmp` or `tmp-{SP_name}` (for subsets) by default
          WARNING: be aware that tmp_dir is removed before processing and on success

    -f failed_files_dir: move failed XML files to failed_files_dir: relative to working_dir, `../failed/` by default
          WARNING: be aware that failed_files_dir is cleaned before processing

    To stop process gracefully after the current ZIP is processed, create a `{working_dir}/.stop` signal file.

ENVIRONMENT

    * PGHOST/PGDATABASE/PGUSER  default Postgres connection parameters


EXAMPLES

    To run in verbose mode and stop on the first error:

      $ ./process_directory.sh -e -v /erniedev_data3/Scopus-testing

    To run a parser subset and stop on the first error:

      ll ../failed$ ./process_directory.sh -s scopus_parse_grants -e /erniedev_data3/Scopus-testing

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
declare  NUM_JOBS=8


FAILED_FILES_DIR="../failed"
PROCESSED_LOG="../processed.log"

echo -e "\nprocess_data_directory.sh ..."

while (($# > 0)); do
  echo "Using CLI arg '$1'"
  case "$1" in
  -u)
    readonly UPDATE_JOB=true
    ;;
  -k)
    readonly SMOKELOAD_JOB=true
    ;;
  -n)
    shift
    echo "Using CLI arg '$1'"
    NUM_JOBS="$1"
    ;;
  -e)
    readonly STOP_ON_THE_FIRST_ERROR=true
    ;;
  -p)
    shift
    echo "Using CLI arg '$1'"
    readonly PROCESSED_LOG="$1"
    ;;
  -f)
    shift
    echo "Using CLI arg '$1'"
    readonly FAILED_FILES_DIR="$1"
    ;;
  -s)
    shift
    echo "Using CLI arg '$1'"
    readonly SUBSET_SP=$1
    ;;
  -t)
    shift
    readonly TMP_DIR=$1
    ;;
  -v)
    # Second "-v" = extra verbose?
    if [[ "$VERBOSE" == "true" ]]; then
      set -x
    else
      declare -rx VERBOSE=true
    fi
    ;;
  *)
    cd "$1"
    ;;
  esac
  shift
done

if [[ ! ${TMP_DIR} ]]; then
  if [[ ${SUBSET_SP} ]]; then
    readonly TMP_DIR="tmp-${SUBSET_SP}"
  else
    readonly TMP_DIR="tmp"
  fi
fi

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##"

if ! which parallel >/dev/null; then
  echo "Please install GNU Parallel"
  exit 1
fi

# Set counter and ETA variables
declare -i num_zips=$(ls *.zip | wc -l)
declare -i failed_xml_counter=0 failed_xml_counter_total=0 processed_xml_counter=0 processed_xml_counter_total=0
declare -i process_start_time i=0 start_time stop_time delta delta_s delta_m della_h elapsed=0 est_total eta


parse_xml() {
  local xml="$1"
  [[ $2 ]] && local subset_option="-v subset_sp=$2"
  [[ ${VERBOSE} == "true" ]] && echo "Processing $xml ..."
  if psql -q -f ${ABSOLUTE_SCRIPT_DIR}/scopus_stg_parser.sql -v "xml_file=$PWD/$xml" ${subset_option} 2>>"${ERROR_LOG}"; then
    [[ ${VERBOSE} == "true" ]] && echo "$xml: SUCCESSFULLY PARSED."
    return 0
  else
    [[ ${VERBOSE} == "true" ]] && echo "$xml parsing FAILED.\n"
    echo -e "$xml parsing FAILED.\n" >>"${ERROR_LOG}"

    local full_xml_path=$(realpath ${xml})
    local full_error_log_path=$(realpath ${ERROR_LOG})
    cd ..
    [[ ! -d "${failed_files_dir}" ]] && mkdir -p "${failed_files_dir}"
    mv -f $full_xml_path "${failed_files_dir}/"
    cp $full_error_log_path "${failed_files_dir}/"
    cd "${TMP_DIR}"
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
    exit 1
  fi
}

# Create an empty file if it does not exist to simplify check condition below
touch "${PROCESSED_LOG}"
[[ ${STOP_ON_THE_FIRST_ERROR} == "true" ]] && readonly PARALLEL_HALT_OPTION="--halt soon,fail=1"
process_start_time=$(date '+%s')
for scopus_data_archive in *.zip; do
  start_time=$(date '+%s')
  if grep -q "^${scopus_data_archive}$" "${PROCESSED_LOG}"; then
    echo "Skipping file ${scopus_data_archive} ( .zip file #$((++i)) out of ${num_zips} ). It is already marked as completed."
  else
    echo -e "\nProcessing ${scopus_data_archive} ( .zip file #$((++i)) out of ${num_zips} )..."
    # Reduced verbosity
    # -u extracting files that are newer and files that do not already exist on disk
    # -q perform operations quietly
    unzip -u -q "${scopus_data_archive}" -d "${TMP_DIR}"

    export failed_files_dir="${FAILED_FILES_DIR}/${scopus_data_archive}"
    cd "${TMP_DIR}"
    rm -f "${ERROR_LOG}"

    if
      ! find -name '2*.xml' | parallel ${PARALLEL_HALT_OPTION} -j ${NUM_JOBS}  --joblog ${PARALLEL_LOG} --line-buffer \
      --tagstring '|job#{#} s#{%}|' parse_xml "{}" ${SUBSET_SP}
    then
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
    rm -rf ${TMP_DIR}

    # sql script that inserts from staging table into scopus
    echo -e "\nMERGING INTO SCOPUS STAGING TABLES..."
    psql -f "${ABSOLUTE_SCRIPT_DIR}/stg_scopus_merge.sql"
    echo -e "MERGING FINISHED"
    #echo -e "TRUNCATING STAGING TABLES..."
    ## calling a procedure that truncates the staging tables
    #psql -f "${ABSOLUTE_SCRIPT_DIR}/truncate_stg_table.sql"
    #echo -e "\nTRUNCATING FINISHED"

    echo "SUMMARY FOR ${scopus_data_archive}:"
    echo "SUCCESSFULLY PARSED ${processed_xml_counter} XML FILES"
    if ((failed_xml_counter == 0)); then
      echo "ALL IS WELL"
      echo "${scopus_data_archive}" >>"${PROCESSED_LOG}"
    else
      echo "FAILED PARSING ${failed_xml_counter} XML FILES"
    fi

    ((failed_xml_counter_total += failed_xml_counter)) || :
    failed_xml_counter=0
    ((processed_xml_counter_total += processed_xml_counter)) || :
    processed_xml_counter=0

    if [[ -f "${STOP_FILE}" ]]; then
      echo -e "\nFound the stop signal file. Gracefully stopping..."
      break
    fi

    stop_time=$(date '+%s')
    ((delta = stop_time - start_time + 1)) || :
    ((delta_s = delta % 60)) || :
    ((delta_m = (delta / 60) % 60)) || :
    ((della_h = delta / 3600)) || :
    printf "$(TZ=America/New_York date) :  Done with ${scopus_data_archive} archive in %dh:%02dm:%02ds\n" ${della_h} \
    ${delta_m} ${delta_s}
    if ((i < num_zips)); then
      ((elapsed = elapsed + delta))
      ((est_total = num_zips * elapsed / i)) || :
      ((eta = process_start_time + est_total))
      echo "ETA for completion of the current directory: $(TZ=America/New_York date --date=@${eta})"
    fi
  fi
done

echo -e "\nDIRECTORY SUMMARY:"
echo "SUCCESSFULLY PARSED ${processed_xml_counter_total} XML FILES"
if ((failed_xml_counter_total == 0)); then
  echo "ALL IS WELL"
else
  echo "FAILED PARSING ${failed_xml_counter_total} XML FILES"
fi

if [[ -d "${TMP_DIR}" ]]; then
  cd "${TMP_DIR}"
  check_errors # Exits here if errors occurred
  cd
  rm -rf "${TMP_DIR}"
fi

exit 0
