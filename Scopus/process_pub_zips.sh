#!/usr/bin/env bash
readonly FATAL_FAILURE_CODE=255

if [[ "$1" == "-h" ]]; then
  cat << 'HEREDOC'
NAME

    process_pub_zips.sh -- process a directory of Scopus publication ZIPs

SYNOPSIS

    process_pub_zips.sh [-l processed_log] [-rep] [-s subset_SP] [-e max_errors] [-v] [-v] [-n parallel_jobs]
                        [-f failed_pub_dir] [-t tmp_dir] [working_dir]

    process_pub_zips.sh -h: display this help

DESCRIPTION

    Extract all publication ZIP files from the `{working_dir}` (`.` by default) into the tmp_dir.
    Process extracted ZIPs one-by-one. Parse all XMLs and update data in the DB in parallel.
    Produce an error log in `{tmp_dir}/errors.log`.
    Produce output with reduced verbosity to reduce the log volume.

    The following options are available.
    Directories and files can be specified as absolute or relative to `{working_dir}` paths.

    -l processed_log  log successfully completed publication ZIPs
                      skip already processed files (unless `-rep`)

    -rep              reprocess previously successfully completed publication ZIPs

    -s subset_SP      parse a subset of data via the specified subset parsing Stored Procedure (SP)

    -e max_errors     stop when the error number reaches this threshold, 101 by default

    -v                verbose output: print processed XML files

    -v -v             extra-verbose output: print all lines (`set -x`)

    -n parallel_jobs  maximum number of jobs to run in parallel, # of CPU cores by default

    -t tmp_dir        `tmp` or `tmp-{SP_name}` (for subsets) by default
                      WARNING: be aware that `{tmp_dir}` is removed before processing and on success.

    -f failed_pub_dir move failed publication XML files to `{failed_pub_dir}/{pub_ZIP_name}/`, `../failed` by default
                      WARNING: be aware that `failed_pub_dir` is cleaned before processing.

    To stop process gracefully after the current ZIP is processed, create a `{working_dir}/.stop` signal file.

ENVIRONMENT

    * PGHOST/PGDATABASE/PGUSER  default Postgres connection parameters

EXIT STATUS

    Exits with one of the following values:

    0    Success
    1    Error occurred
    255  Maximum number of errors reached / fatal failure

EXAMPLES

    To run in verbose mode and stop on the first error:

      $ ./process_pub_zips.sh -e 1 -v /erniedev_data2/Scopus_testing

    To run a parser subset and stop on the first error:

      $ ./process_pub_zips.sh -s scopus_parse_grants -e 1 /erniedev_data2/Scopus_testing

HEREDOC
  exit $FATAL_FAILURE_CODE
fi

set -e
set -o pipefail

readonly STOP_FILE=".stop"
# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)
readonly ABSOLUTE_SCRIPT_DIR
export ABSOLUTE_SCRIPT_DIR
declare -rx ERROR_LOG=error.log
declare -rx TMP_OUT=/tmp/ERNIE-Scopus-process_pub_zips.out
declare -i MAX_ERRORS=101

FAILED_FILES_DIR="../failed"
echo -e "\nRunning process_data_directory.sh $*"

REPROCESS=false
while (($# > 0)); do
  case "$1" in
    -l)
      shift
      readonly PROCESSED_LOG="$1"
      ;;
    -rep)
      readonly REPROCESS=true
      ;;
    -s)
      shift
      readonly SUBSET_SP=$1
      ;;
    -e)
      shift
      declare -ri MAX_ERRORS=$1
      (( MAX_ERRORS > 0 )) && readonly PARALLEL_HALT_OPTION="--halt soon,fail=${MAX_ERRORS}"
      ;;
    -v)
      # Second "-v" = extra verbose?
      if [[ "$VERBOSE" == "true" ]]; then
        set -x
      else
        declare -rx VERBOSE=true
      fi
      ;;
    -n)
      shift
      readonly PARALLEL_JOBSLOTS_OPTION="-j $1"
      ;;
    -f)
      shift
      readonly FAILED_FILES_DIR="$1"
      ;;
    -t)
      shift
      readonly TMP_DIR=$1
      ;;
    *)
      cd "$1"
      ;;
  esac
  shift
done

declare -rx WORKING_DIR="${PWD}"

readonly TOTAL_JOB_PROCESSOR="tail -1 | pcregrep -o1 'job#\d+/(\d+)' >${TMP_OUT}"
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
export TMP_DIR
rm -rf ${TMP_DIR}

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##"

if ! command -v parallel > /dev/null; then
  echo "Please install GNU Parallel"
  exit $FATAL_FAILURE_CODE
fi

# Set counter and ETA variables
declare -i num_zips
num_zips=$(ls *.zip | wc -l)
declare -i total_failures=0 processed_pubs total_processed_pubs=0
declare -i process_start_time i=0 start_time stop_time delta delta_s delta_m della_h elapsed=0 est_total eta

parse_pub() {
  local pub_xml="$1"
  [[ $2 ]] && local subset_option="-v subset_sp=$2"

  [[ ${VERBOSE} == "true" ]] && echo "Parsing $pub_xml"
  # Always produce minimum output below even when not verbose to get stats via the OUTPUT_PROCESSOR
  # Extra output is discarded in non-verbose mode by the OUTPUT_PROCESSOR
  # Using Staging
  # shellcheck disable=SC2086
  if psql -q -f "${ABSOLUTE_SCRIPT_DIR}/parse_and_stage.sql" -v "xml_file=$PWD/$pub_xml" ${subset_option} \
        2>> "${ERROR_LOG}"; then
    echo "$pub_xml: SUCCESSFULLY PARSED."
    return 0
  else
    echo -e "$pub_xml parsing FAILED.\n" | tee -a "${ERROR_LOG}"

    local full_xml_path
    full_xml_path=$(realpath "${pub_xml}")
    cd "${WORKING_DIR}"
    [[ ! -d "${failed_files_dir}" ]] && mkdir -p "${failed_files_dir}"
    mv -f "$full_xml_path" "${failed_files_dir}/"
    cd "${TMP_DIR}"
    return 1
  fi
}
export -f parse_pub

# Create an empty file if it does not exist to simplify check condition below
touch "${PROCESSED_LOG}"

process_start_time=$(date '+%s')
for scopus_data_archive in *.zip; do
  start_time=$(date '+%s')

  already_processed=false
  if [[ -s "${PROCESSED_LOG}" ]]; then # Size > 0
    grep -q "^${scopus_data_archive}$" "${PROCESSED_LOG}" && already_processed=true
  fi

  if [[ $already_processed == true && $REPROCESS == false ]]; then
    echo "Skipping publication ZIP ${scopus_data_archive} (#$((++i)) out of ${num_zips}).
    It is already marked as completed."
  else
    echo -e "\nProcessing ${scopus_data_archive} (publication ZIP #$((++i)) out of ${num_zips})"
    # Reduced verbosity
    # -u extracting files that are newer and files that do not already exist on disk
    # -q perform operations quietly
    if ! unzip -u -q "${scopus_data_archive}" -d "${TMP_DIR}"; then
      echo "Corrupted ZIP: ${WORKING_DIR}/${scopus_data_archive}"
      exit $FATAL_FAILURE_CODE
    fi

    export failed_files_dir="${FAILED_FILES_DIR}/${scopus_data_archive}"
    cd "${TMP_DIR}"
    rm -f "${ERROR_LOG}"

    echo "Truncating staged data"
    if ! psql -f "${ABSOLUTE_SCRIPT_DIR}/truncate_staged_data.sql" >"${TMP_OUT}"; then
      echo "=== psql output ==="
      cat "${TMP_OUT}"
      echo "==================="
      rm -f "${TMP_OUT}"
      exit $FATAL_FAILURE_CODE
    fi
    echo "Truncated."

    echo "Parsing ..."
    #@formatter:off
    set +e
    # shellcheck disable=SC2016
    # shellcheck disable=SC2086
    find . -name '*.xml' -type f -print0 | parallel -0 ${PARALLEL_HALT_OPTION} ${PARALLEL_JOBSLOTS_OPTION} \
        --line-buffer --tagstring '|job#{#}/{= $_=total_jobs() =} s#{%}|' parse_pub "{}" "${SUBSET_SP}" \
        | "${OUTPUT_PROCESSOR}"
    parallel_exit_code=${PIPESTATUS[1]}
    set -e
    #@formatter:on

    processed_pubs=$(cat ${TMP_OUT})
    echo "Parsed ${processed_pubs} publications"
    if (( processed_pubs == 0)); then
      echo "Unexpected PROBLEM"
      exit $FATAL_FAILURE_CODE
    fi
    ((total_processed_pubs += processed_pubs)) || :
    ((total_failures += parallel_exit_code)) || :
    if (( parallel_exit_code > 0 )); then
      # Preserve error log
      cd "${WORKING_DIR}"
      cp -fv "${TMP_DIR}/${ERROR_LOG}" "${failed_files_dir}/"
      cd "${TMP_DIR}"
    fi
    case $parallel_exit_code in
      0)
        echo "OK"
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
        # Terminate
        ((total_failures = MAX_ERRORS+1))
        ;;
    esac

    if ((total_failures >= MAX_ERRORS)); then
      if [[ -s "${ERROR_LOG}" ]]; then
        cat << HEREDOC
Error(s) occurred during processing of ${WORKING_DIR}.
=====
HEREDOC
        head -100 "${ERROR_LOG}"
        cat << HEREDOC
[skipped ?]
=====
HEREDOC
      fi

      exit $FATAL_FAILURE_CODE
    fi

    cd "${WORKING_DIR}"

    # sql script that inserts from staging table into scopus
    # Using STAGING
    echo "Merging staged data into Scopus tables"
    if ! psql -f "${ABSOLUTE_SCRIPT_DIR}/merge_staged_data.sql" >"${TMP_OUT}"; then
      echo "=== psql output ==="
      cat "${TMP_OUT}"
      echo "==================="
      rm -f "${TMP_OUT}"
      exit $FATAL_FAILURE_CODE
    fi

    if [[ "$PROCESSED_LOG" && $already_processed == false && $parallel_exit_code == 0 ]]; then
      echo "${scopus_data_archive}" >> "${PROCESSED_LOG}"
    fi

    rm -f "${TMP_OUT}"
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

    #@formatter:off
    printf "Done with ${scopus_data_archive} publication ZIP in %dh:%02dm:%02ds at %.1f pubs/min.\n" ${della_h} ${delta_m} \
        ${delta_s} "$((10**9 * processed_pubs*60/delta ))e-9"
    #@formatter:on

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

exit 0
