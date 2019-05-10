#!/usr/bin/env bash
if [[ $# -lt 1 || "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    process_directory.sh -- process a directory of Scopus data

SYNOPSIS

    process_directory.sh [-c] [-e] [-v] [-v] [-s] working_dir tmp_dir [failed_files_dir]
    process_directory.sh -h: display this help

DESCRIPTION

    * Parse all source Scopus files from the specified `working_dir` and update data in the DB in parallel.
    * Extract *.zip in the working directory one-by-one, updating files: newer and non-existent only.
    * Parsing and other SQL errors don't fail the build unless `-e` is specified.
    * Move XML files failed to be parsed to `failed_files_dir`, relative to the working dir. (../failed/ by default)
    ** WARNING: be aware that `failed_files_dir` is cleaned before processing!
    * Produce an error log in `{working_dir}/$tmp/errors.log`.
    * Produce output with reduced verbosity to reduce log volume.

    To stop process gracefully after the current ZIP is processed, create a `{working_dir}/.stop` signal file.

    The following options are available:

    -c    clean load: truncate data. WARNING: be aware that you'll lose all loaded data!

    -e    stop on the first error

    -v    verbose output: print processed XML files and error details as errors occur

    -v -v extra-verbose output: print all lines (set -x)

    -s    check subset SP name
ENVIRONMENT

    * PGHOST/PGDATABASE/PGUSER  default Postgres connection parameters

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
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
declare -x FAILED_FILES="False"

while (( $# > 0 )); do
  case "$1" in
    -c)
      readonly CLEAN_MODE=true
      ;;
    -v)
      # Second "-v" = extra verbose?
      if [[ "$VERBOSE" == "true" ]]; then
        set -x
      else
        declare -rx VERBOSE=true
      fi
      ;;
    -e)
      readonly STOP_ON_THE_FIRST_ERROR=true
      echo "process_directory.sh should stop on the first error."
      ;;
    -s)
      readonly sp_name=$"update_scopus_grants"
      ;;
    *)
      break
  esac
  shift
done

cd "$1"
tmp="$2"
readonly FAILED_FILES_DIR=${3:-../failed}

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
  [[ ${VERBOSE} == "true" ]] && echo "Processing $xml ..."
  if psql -q -f ${ABSOLUTE_SCRIPT_DIR}/parser.sql -v "xml_file=$PWD/$xml" -v "sp_name=$sp_name" 2>> "${ERROR_LOG}"; then
    [[ ${VERBOSE} == "true" ]] && echo "$xml: SUCCESSFULLY PARSED."
    return 0
  else
    local full_xml_path=$(realpath ${xml})
    local xml_dir=$(dirname ${full_xml_path})
    cd ..
    [[ ! -d "${failed_files_dir}" ]] && mkdir -p "${failed_files_dir}"
    mv -f "${xml_dir}/" "${failed_files_dir}/"
    chmod -R g+w "${failed_files_dir}/$xml_dir/"
    cd $tmp
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
    exit 1
  fi
}

if [[ "${CLEAN_MODE}" == true ]]; then
  echo "In clean mode: truncating all data ..."
  # language=PostgresPLSQL
  psql -v ON_ERROR_STOP=on --echo-all <<'HEREDOC'
    TRUNCATE scopus_publication_groups CASCADE;
HEREDOC
fi

rm -rf "${FAILED_FILES_DIR}"
rm -rf $tmp
mkdir $tmp

[[ ${STOP_ON_THE_FIRST_ERROR} == "true" ]] && readonly PARALLEL_HALT_OPTION="--halt soon,fail=1"
process_start_time=$(date '+%s')
for scopus_data_archive in *.zip; do
  start_time=$(date '+%s')
  echo -e "\nProcessing ${scopus_data_archive} ( .zip file #$((++i)) out of ${num_zips} )..."
  # Reduced verbosity
  # -u extracting files that are newer and files that do not already exist on disk
  # -q perform operations quietly
  unzip -u -q "${scopus_data_archive}" -d $tmp

  export failed_files_dir="${FAILED_FILES_DIR}/${scopus_data_archive}"
  cd $tmp
  rm -f "${ERROR_LOG}"
  for subdir in $(find . -mindepth 1 -maxdepth 1 -type d); do
    # Process Scopus XML files in parallel
    # Reduced verbosity
    if ! find "${subdir}" -name '2*.xml' | parallel ${PARALLEL_HALT_OPTION} --joblog ${PARALLEL_LOG} --line-buffer \
        --tagstring '|job#{#} s#{%}|' parse_xml "{}"; then
      [[ ${STOP_ON_THE_FIRST_ERROR} == "true" ]] && check_errors # Exits here if errors occurred
    fi
    while read -r line; do
      if echo $line | grep -q "1"; then
        ((++failed_xml_counter))
      else
        ((++processed_xml_counter))
      fi
    done < <(awk 'NR>1{print $7}' "${PARALLEL_LOG}")
    rm -rf "${PARALLEL_LOG}" "${subdir}"
  done
  cd ..

  echo "ZIP-LEVEL SUMMARY FOR ${scopus_data_archive}:"
  echo "NUMBER OF XML FILES SUCCESSFULLY PARSED: ${processed_xml_counter}"
  if ((failed_xml_counter == 0)); then
    echo "SUCCESS"
  else
    echo "NUMBER OF XML FILES WHICH FAILED PARSING: ${failed_xml_counter}"
  fi
  ((failed_xml_counter_total += failed_xml_counter)) || :
  failed_xml_counter=0
  ((processed_xml_counter_total += processed_xml_counter)) || :
  processed_xml_counter=0

  if [[ -f "${STOP_FILE}" ]]; then
    echo "Found the stop signal file. Gracefully stopping..."
#    rm -f "${STOP_FILE}"
    break
  fi

  stop_time=$(date '+%s')
  ((delta = stop_time - start_time + 1)) || :
  ((delta_s = delta % 60)) || :
  ((delta_m = (delta / 60) % 60)) || :
  ((della_h = delta / 3600)) || :
  printf "$(TZ=America/New_York date) :  Done with ${scopus_data_archive} archive in %dh:%02dm:%02ds\n" ${della_h} \
         ${delta_m} ${delta_s}
  if (( i < num_zips )); then
    ((elapsed = elapsed + delta))
    ((est_total = num_zips * elapsed / i)) || :
    ((eta = process_start_time + est_total))
    echo "ETA for completion of the current directory: $(TZ=America/New_York date --date=@${eta})"
  fi
done

echo -e "\nDIRECTORY SUMMARY:"
echo "NUMBER OF XML FILES WHICH SUCCESSFULLY PARSED: ${processed_xml_counter_total}"
if ((failed_xml_counter_total == 0)); then
  echo "SUCCESS"
else
  echo "NUMBER OF XML FILES WHICH FAILED PARSING: ${failed_xml_counter_total}"
fi

cd $tmp
check_errors
# Exits here if errors occurred

cd ..
rm -rf $tmp
exit 0
