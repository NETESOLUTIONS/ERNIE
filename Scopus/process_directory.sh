#!/usr/bin/env bash
if [[ $# -lt 1 || "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    process_directory.sh -- process a directory of Scopus data

SYNOPSIS

    process_directory.sh [-c] [-e] working_dir [failed_files_dir]
    process_directory.sh -h: display this help

DESCRIPTION

    * Parse all source Scopus files from the specified `working_dir` and update data in the DB in parallel.
    * Extract *.zip in the working directory one-by-one, updating files: newer and non-existent only.
    * Parsing and other SQL errors don't fail the build unless `-e` is specified.
    * Move XML files failed to be parsed to `failed_files_dir`, relative to the working dir. (../failed/ by default)
    * Produce a separate error log.
    * Produce output with reduced verbosity to reduce log volume.

    The following options are available:

    -c    clean load: truncate data and remove previously failed files before processing.
    WARNING: be aware that you'll lose all loaded data!

ENVIRONMENT

    * PGHOST/PGDATABASE/PGUSER  default Postgres connection parameters

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi


set -e
set -o pipefail
#set -x

# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
declare -rx ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)
declare -rx ERROR_LOG=errors.log
declare -rx PARALLEL_LOG=parallel.log
declare -x FAILED_FILES="False"
LESS_VERBOSE=true

while (( $# > 0 )); do
  case "$1" in
    -c)
      readonly CLEAN_MODE=true
      ;;
    -e)
      # TODO This is not working currently
      readonly STOP_ON_THE_FIRST_ERROR=true
      echo "process_directory.sh should stop on the first error."
      ;;
    *)
      break
  esac
  shift
done

cd "$1"
readonly FAILED_FILES_DIR=${2:-../failed}

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

if ! which parallel >/dev/null; then
  echo "Please install GNU Parallel"
  exit 1
fi

# Set counter and ETA variables
declare -i num_zips=$(ls *.zip | wc -l) failed_xml_counter=0 failed_xml_counter_total=0 processed_xml_counter=0 processed_xml_counter_total=0
declare -i process_start_time i=0 start_time stop_time delta delta_s delta_m della_h elapsed=0 est_total eta

parse_xml() {
  local xml="$1"
  if ! $LESS_VERBOSE; then echo "Processing $xml ..." ; fi
  if psql -q -f ${ABSOLUTE_SCRIPT_DIR}/parser.sql -v "xml_file=$PWD/$xml" 2>> "${ERROR_LOG}"; then
    if ! $LESS_VERBOSE; then echo "$xml: SUCCESSFULLY PARSED." ; fi
  else
    [[ ! -d "${failed_files_dir}" ]] && mkdir -p "${failed_files_dir}"
    full_path=$(realpath ${xml})
    full_path=$(dirname ${full_path})
    mv -f $full_path/ "${failed_files_dir}/"
    if ! $LESS_VERBOSE; then echo "$xml: FAILED DURING PARSING." ; fi
    return 1
  fi
}
export -f parse_xml

check_errors() {
  # Errors occurred? Does the error log have a size greater than zero?
  if [[ -s tmp/${ERROR_LOG} ]]; then
    cat <<HEREDOC
Error(s) occurred during processing of ${PWD}.
=====
HEREDOC
    cat tmp/${ERROR_LOG}
    echo "====="
    exit 1
  fi
}

if [[ "${CLEAN_MODE}" == true ]]; then
  echo "In clean mode: truncating all data ..."
  # language=PostgresPLSQL
  psql -v ON_ERROR_STOP=on --echo-all <<'HEREDOC'
    TRUNCATE scopus_publication_groups CASCADE;
HEREDOC

  echo "In clean mode: removing previously failed files ..."
  rm -rf "${FAILED_FILES_DIR}"
fi

rm -rf tmp
mkdir tmp

[[ ${STOP_ON_THE_FIRST_ERROR} == "true" ]] && readonly PARALLEL_HALT_OPTION="--halt soon,fail=1"

for scopus_data_archive in *.zip; do
  start_time=$(date '+%s')
  echo "Processing ${scopus_data_archive} ( .zip file #$((++i)) out of ${num_zips} )..."
  # Reduced verbosity
  # -u extracting files that are newer and files that do not already exist on disk
  # -q perform operations quietly
  unzip -u -q "${scopus_data_archive}" -d tmp
  cd tmp
  export failed_files_dir="../${FAILED_FILES_DIR}/${scopus_data_archive}"
  for subdir in $(find . -mindepth 1 -maxdepth 1 -type d); do
    # Process Scopus XML files in parallel
    # Reduced verbosity
    if ! find "${subdir}" -name '2*.xml' | \
        parallel ${PARALLEL_HALT_OPTION} --joblog ${PARALLEL_LOG} --line-buffer --tagstring '|job#{#} s#{%}|' parse_xml "{}"; then
        [[ ${STOP_ON_THE_FIRST_ERROR} == "true" ]] && check_errors
    fi
    while read -r line;
      do echo $line | grep -q "1" && ((++failed_xml_counter)) && ((++failed_xml_counter_total)) || ((++processed_xml_counter)) && ((++processed_xml_counter_total))
    done < <(awk 'NR>1{print $7}' "${PARALLEL_LOG}")
    > "${PARALLEL_LOG}"
    rm -rf "${subdir}"
  done

  echo "ZIP LEVEL SUMMARY FOR ${scopus_data_archive}:"
  echo "NUMBER OF XML FILES SUCCESSFULLY PARSED: ${processed_xml_counter}"
  echo "NUMBER OF XML FILES WHICH FAILED PARSING: ${failed_xml_counter}"
  failed_xml_counter=0
  processed_xml_counter=0

  stop_time=$(date '+%s')
  ((delta=stop_time - start_time)) || : 
  ((delta_s=delta % 60)) || :
  ((delta_m=(delta / 60) % 60)) || :
  ((della_h=delta / 3600)) || :
  printf "\n$(TZ=America/New_York date) Done with ${scopus_data_archive} archive in %dh:%02dm:%02ds\n" ${della_h} \
         ${delta_m} ${delta_s}
  ((elapsed=elapsed + delta))
  ((est_total=num_zips * elapsed / i)) || :
  ((eta=process_start_time + est_total))
  echo "ETA for completion of current year: $(TZ=America/New_York date --date=@${eta})"
  cd ..
done

#TODO: try to introduce a multiline string here, maybe call a function
#TODO: reset failed XML counters and maintain a larger global count to track total failed XML per year
echo "YEAR LEVEL SUMMARY:"
echo "NUMBER OF XML FILES SUCCESSFULLY PARSED: ${processed_xml_counter_total}"
echo "NUMBER OF XML FILES WHICH FAILED PARSING: ${failed_xml_counter_total}"

#check_errors
exit 0
