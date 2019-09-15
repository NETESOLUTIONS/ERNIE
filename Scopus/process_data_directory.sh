#!/usr/bin/env bash
if [[ "$1" == "-h" ]]; then
  cat << 'HEREDOC'
NAME

    process_data_directory.sh -- process a directory of Scopus data for either update or smokeload job

SYNOPSIS

    process_data_directory.sh -u|-k [-n parallel_jobs] [-e max_errors] [-v] [-v] [-s subset_SP] [-t tmp_dir]
      [-f failed_files_dir] [working_dir]

    process_data_directory.sh -h: display this help

DESCRIPTION

    Extract all source Scopus ZIP files from the working_dir (`.` by default) into the tmp_dir.
    Process extracted ZIPs one-by-one. Parse all XMLs and update data in the DB in parallel.
    Produce an error log in `{tmp_dir}/errors.log`.
    Produce output with reduced verbosity to reduce the log volume.

    The following options are available:

    -u    update job: specifies that the job is an update versus smokeload

    -k    smokeload job : specificies that the job is a smokeload versus update

    -n    maximum number of jobs to run in parallel, defaults to # of CPU cores

    -e    stop when the error # reaches the max_errors threshold. Defaults to 101.

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
declare -rx PARALLEL_LOG=/tmp/ERNIE-Scopus-process_data_directory.out
declare -i MAX_ERRORS=101

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
      PARALLEL_JOBSLOTS_OPTION="-j $1"
      ;;
    -e)
      shift
      declare -ri MAX_ERRORS=$1
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

readonly TOTAL_JOB_PROCESSOR="tail -1 | pcregrep -o1 'job#\d+/(\d+)' >${PARALLEL_LOG}"
if [[ "$VERBOSE" == "true" ]]; then
  readonly OUTPUT_PROCESSOR="eval tee >(${TOTAL_JOB_PROCESSOR})"
else
  readonly OUTPUT_PROCESSOR="eval ${TOTAL_JOB_PROCESSOR}"
fi

if [[ ! ${TMP_DIR} ]]; then
  if [[ ${SUBSET_SP} ]]; then
    readonly TMP_DIR="tmp-${SUBSET_SP}"
  else
    readonly TMP_DIR="tmp"
  fi
fi

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##"

if ! which parallel > /dev/null; then
  echo "Please install GNU Parallel"
  exit 1
fi

# Set counter and ETA variables
declare -i num_zips=$(ls *.zip | wc -l)
declare -i total_failures=0 processed_pubs total_processed_pubs=0
declare -i process_start_time i=0 start_time stop_time delta delta_s delta_m della_h elapsed=0 est_total eta

parse_xml() {
  local xml="$1"
  [[ $2 ]] && local subset_option="-v subset_sp=$2"

  [[ ${VERBOSE} == "true" ]] && echo "Processing $xml ..."
  # Always produce minimum output below even when not verbose to get stats via the OUTPUT_PROCESSOR
  # Extra output is discarded in non-verbose mode by the OUTPUT_PROCESSOR
  # Using Staging
  if psql -q -f ${ABSOLUTE_SCRIPT_DIR}/parser_test.sql -v "xml_file=$PWD/$xml" ${subset_option} 2>> "${ERROR_LOG}"; then
    echo "$xml: SUCCESSFULLY PARSED."
    return 0
  else
    echo -e "$xml parsing FAILED.\n" | tee -a "${ERROR_LOG}"

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

exit_on_errors() {
  # Errors occurred? Does the error log have a size greater than zero?
  if [[ -s "${ERROR_LOG}" ]]; then
    if [[ ${VERBOSE} == "true" ]]; then
      cat << HEREDOC
Error(s) occurred during processing of ${PWD}.
=====
HEREDOC
      cat "${ERROR_LOG}"
      echo "====="
    fi
    exit 1
  fi
}

# Drop indexes for staging table method
#psql -c "call scopus_disable_indexes();"
# Create an empty file if it does not exist to simplify check condition below
touch "${PROCESSED_LOG}"
[[ ${STOP_ON_THE_FIRST_ERROR} == "true" ]] && readonly PARALLEL_HALT_OPTION="--halt soon,fail=1"
process_start_time=$(date '+%s')
for scopus_data_archive in *.zip; do
  start_time=$(date '+%s')
  if grep -q "^${scopus_data_archive}$" "${PROCESSED_LOG}"; then
    echo "Skipping file ${scopus_data_archive} ( .zip file #$((++i)) out of ${num_zips} ).
    It is already marked as completed."
  else
    echo -e "\nProcessing ${scopus_data_archive} ( .zip file #$((++i)) out of ${num_zips} )..."
    # Reduced verbosity
    # -u extracting files that are newer and files that do not already exist on disk
    # -q perform operations quietly
    unzip -u -q "${scopus_data_archive}" -d "${TMP_DIR}"

    export failed_files_dir="${FAILED_FILES_DIR}/${scopus_data_archive}"
    cd "${TMP_DIR}"
    rm -f "${ERROR_LOG}"

    #    echo -e "Truncating staging tables..."
    ## calling a procedure that truncates the staging tables
    # Using Staging
    psql -q -c "CALL truncate_stg_table()"
    #    echo -e "\nTruncating finished"

    find -name '2*.xml' -type f -print0 | parallel -0 ${PARALLEL_HALT_OPTION} ${PARALLEL_JOBSLOTS_OPTION} --line-buffer\
    --tagstring '|job#{#}/{= $_=total_jobs() =} s#{%}|' parse_xml "{}" ${SUBSET_SP} | ${OUTPUT_PROCESSOR}
    parallel_exit_code=${PIPESTATUS[1]}
    ((total_failures += parallel_exit_code)) || :
    echo "SUMMARY FOR ${scopus_data_archive}:"
    processed_pubs=$(cat ${PARALLEL_LOG})
    echo "Total publications: ${processed_pubs}"
    case $parallel_exit_code in
      0)
        echo "ALL IS WELL"
        echo "${scopus_data_archive}" >> "${PROCESSED_LOG}"
        ;;
      1)
        echo "1 publication FAILED PARSING"
        ;;
      [2-9] | [1-9][0-9])
        echo "$parallel_exit_code publications FAILED PARSING"
        ;;
      101)
        echo "More than 100 publications FAILED PARSING"
        ;;
      *)
        echo "TOTAL FAILURE"
        exit_on_errors
        ;;
    esac
    ((total_failures >= MAX_ERRORS)) && exit_on_errors
    ((total_processed_pubs += processed_pubs)) || :

    # sql script that inserts from staging table into scopus
    # Using STAGING
    echo "Merging staged data into Scopus tables..."
    psql -q -f "${ABSOLUTE_SCRIPT_DIR}/stg_scopus_merge.sql"
    #    echo -e "Merging finished"
    #    rm -f "${PARALLEL_LOG}"
    cd ..
    rm -rf ${TMP_DIR}

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
echo "Total publications: ${total_processed_pubs}"
if ((total_failures == 0)); then
  echo "ALL IS WELL"
else
  echo "${total_failures} publications FAILED PARSING"
fi

#psql -c "scopus_create_indexes();"

if [[ -d "${TMP_DIR}" ]]; then
  cd "${TMP_DIR}"
  exit_on_errors
  cd
  rm -rf "${TMP_DIR}"
fi

exit 0
