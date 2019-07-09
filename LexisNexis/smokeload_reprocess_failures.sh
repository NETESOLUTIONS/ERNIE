#!/usr/bin/env bash
if [[ "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    lexis_nexis_smokeload_reprocess_failures.sh -- reprocess XML files present in a failed files directory

SYNOPSIS

    lexis_nexis_smokeload_reprocess_failures.sh [-e] [-v] [-v] [-s subset_SP] [working_dir]
    lexis_nexis_smokeload_reprocess_failures.sh -h: display this help

    This script is largely based on the process_directory.sh script from ERNIE Scopus

DESCRIPTION

    Loop through all directories present in the failed files directory.
    Parse all XMLs available in each subdirectory in parallel and upsert data into the DB.
    Produce an error log in `subdir/reprocessed_errors.log`.
    If ANY errors occur on reprocessing, ensure that the original error log and XML files are preserved in the failed files subdirectory.
    If NO errors occur on reprocessing, clear out the failed files subdirectory and archive the old error log.
    Produce output with reduced verbosity to reduce the log volume.

    The following options are available:

    -e    stop on the first error. Parsing and other SQL errors don't fail the build unless `-e` is specified.

    -v    verbose output: print processed XML files and error details as errors occur

    -v -v extra-verbose output: print all lines (`set -x`)

    -s subset_SP: parse a subset of data via the specified subset parsing Stored Procedure (SP)

    To stop process gracefully after the current zip file is processed, create a `{working_dir}/.stop` signal file.

ENVIRONMENT

    * PGHOST/PGDATABASE/PGUSER  default Postgres connection parameters


EXAMPLES

HEREDOC
  exit 1
fi

set -e
set -o pipefail

readonly STOP_FILE=".stop"
# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
declare -rx ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)
declare -rx ERROR_LOG=reprocessed_error.log
declare -rx PARALLEL_LOG=parallel.log

while (( $# > 0 )); do
  echo "Using CLI arg '$1'"
  case "$1" in
    -e)
      readonly STOP_ON_THE_FIRST_ERROR=true
      ;;
    -s)
      shift
      echo "Using CLI arg '$1'"
      readonly SUBSET_SP=$1
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
      break
  esac
  shift
done

arg_array=( "$@" )
echo "${arg_array[*]}"
# Courtesy of https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash
IFS=$'\n' sorted_args=($(sort ${SORT_ORDER} <<<"${arg_array[*]}")); unset IFS

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##"

if ! which parallel >/dev/null; then
  echo "Please install GNU Parallel"
  exit 1
fi

reparse_xml() {
  local xml="$1"
  local file_identification="-v file_name=$2"
  [[ $3 ]] && local subset_option="-v subset_sp=$3"
  [[ ${VERBOSE} == "true" ]] && echo "Processing $xml ..."
  if psql -q -f ${ABSOLUTE_SCRIPT_DIR}/Postgres/parser.sql -v "xml_file=$PWD/$xml" ${subset_option} ${file_identification} 2>>"${ERROR_LOG}"; then
    [[ ${VERBOSE} == "true" ]] && echo "$xml: SUCCESSFULLY PARSED."
    psql -c "DELETE FROM failed_files_lexis_nexis WHERE xml_filename = $(basename ${xml})"
    return 0
  else
    [[ ${VERBOSE} == "true" ]] && echo "$xml: FAILED DURING PARSING."
    return 1
  fi
}
export -f reparse_xml
declare -i num_dirs=${#sorted_args[@]}
declare -i failed_xml_counter=0 failed_xml_counter_total=0 processed_xml_counter=0 processed_xml_counter_total=0

for dir in "${sorted_args[@]}" ; do
  echo -e "\nReprocessing files in ${dir} ( directory #$((++i)) out of ${num_dirs} )..."

  #Identify whether it's US file or EP file
  if [[ ${dir} == *"US"* ]]; then
    file_name="US"
  else
    file_name="EP"
  fi

  # Process XML files using GNU parallel
  cd ${dir}
  rm -f "${ERROR_LOG}"
  if ! find -name '*.xml' | parallel ${PARALLEL_HALT_OPTION} --joblog ${PARALLEL_LOG} --line-buffer \
      --tagstring '|job#{#} s#{%}|' reparse_xml "{}" ${file_name} ${SUBSET_SP}; then
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

  # Status report
  echo "SUMMARY FOR ${dir}:"
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

  if [[ -f "${STOP_FILE}" ]]; then
    echo -e "\nFound the stop signal file. Gracefully stopping..."
    break
  fi

done

echo -e "\nSMOKELOAD SUMMARY:"
echo "SUCCESSFULLY PARSED ${processed_xml_counter_total} XML FILES"
if ((failed_xml_counter_total == 0)); then
  echo "ALL IS WELL"
else
  echo "FAILED PARSING ${failed_xml_counter_total} XML FILES"
fi


exit 0
