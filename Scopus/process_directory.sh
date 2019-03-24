#!/usr/bin/env bash
if [[ "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    process_directory.sh -- process a directory of Scopus data

SYNOPSIS

    process_directory.sh [-c] [working_directory]
    process_directory.sh -h: display this help

DESCRIPTION

    * Parse all source Scopus files and update data in the DB in parallel.
    * Use the specified working_directory (current directory by default).
    * Extract *.zip in the working directory one-by-one, updating files: newer and non-existent only.
    * Rename processed *.zip files to *.processed.
    * Produce logs with reduced verbosity to reduce log volume.

    The following options are available:

    -c    clean data before processing and clean "bad" files. WARNING: be aware that you'll lose all loaded data!

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
declare -rx PSQL_ERROR_LOG=psql_errors.log
readonly PARALLEL_JOB_LOG=parallel_job.log

while (( $# > 0 )); do
  case "$1" in
    -c)
      readonly CLEAN_MODE=true
      ;;
    *)
      break
  esac
  shift
done

if (( $# > 0 )); then
  cd "$1"
fi
readonly BAD_FILES_DIR=$(cd "../../bad" && pwd)

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"
#year_dir=$(pwd)
#mkdir -p ${year_dir}/corrupted

if ! which parallel >/dev/null; then
  echo "Please install GNU Parallel"
  exit 1
fi

parse_xml() {
  set -e
  local xml="$1"
  echo "Processing $xml ..."
  psql -f ${ABSOLUTE_SCRIPT_DIR}/parser.sql <"$xml" 2>> "${PSQL_ERROR_LOG}"
  echo "$xml: done."
}
export -f parse_xml

if [[ "${CLEAN_MODE}" == true ]]; then
  # language=PostgresPLSQL
  psql -v ON_ERROR_STOP=on --echo-all <<'HEREDOC'
    TRUNCATE scopus_publication_groups CASCADE;
HEREDOC

  rm -rf "${BAD_FILES_DIR}"
fi

[[ ! -d tmp ]] && mkdir tmp
[[ ! -d processed ]] && mkdir processed

for scopus_data_archive in *.zip; do
  echo "Processing ${scopus_data_archive} ..."

  # Reduced verbosity
  # -u extracting files that are newer and files that do not already exist on disk
  # -q perform operations quietly
  unzip -u -q "${scopus_data_archive}" -d tmp
  cd tmp
  for subdir in $(find . -mindepth 1 -maxdepth 1 -type d); do
    # Process Scopus XML files in parallel
    # Reduced verbosity
    set +e
    set +o pipefail
    
    find "${subdir}" -name '2*.xml' | \
      parallel --joblog "${PARALLEL_JOB_LOG}" --halt never --line-buffer --tagstring '|job#{#} s#{%}|' parse_xml "{}"
    set -e
    set -o pipefail
    file_names=$(cut -f 7,9 "${PARALLEL_JOB_LOG}" | awk '{if ($1 == "3") print $3;}')
    for i in $(echo $file_names); do
      [[ ! -d "${BAD_FILES_DIR}" ]] && mkdir -p "${BAD_FILES_DIR}"
      full_path=$(realpath $i)
      full_path=$(dirname $full_path)
      mv $full_path/ "${BAD_FILES_DIR}/"
    done
    rm -rf "${subdir}"
  done
  error_contents=$(grep ERROR ${PSQL_ERROR_LOG} | grep -v NOTICE | head -n 1)
  echo -e "Error(s) occurred during processing of ${scopus_data_archive}: see "${BAD_FILES_DIR}/".
    ${error_contents}" | mailx -s "Scopus processing errors for ${PWD}" j1c0b0d0w9w7g7v2@neteteam.slack.com
  rm "${PSQL_ERROR_LOG}"
  cd ..
  mv "${scopus_data_archive}" processed/
done
rmdir tmp

exit 0
