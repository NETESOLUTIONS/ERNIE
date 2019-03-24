#!/usr/bin/env bash
if [[ $# -lt 1 || "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    process_directory.sh -- process a directory of Scopus data

SYNOPSIS

    process_directory.sh [-c] working_directory [failed_files_directory]
    process_directory.sh -h: display this help

DESCRIPTION

    * Parse all source Scopus files from he specified working_directory and update data in the DB in parallel.
    * Extract *.zip in the working directory one-by-one, updating files: newer and non-existent only.
    * Move failed XML files to `failed_files_directory`, relative to the working directory (../failed/ by default)
    * Produce logs with reduced verbosity to reduce log volume.

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
set -x

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

cd "$1"
readonly FAILED_FILES_DIR=${2:-../failed}

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

  rm -rf "${FAILED_FILES_DIR}"
fi

[[ ! -d tmp ]] && mkdir tmp
[[ ! -d processed ]] && mkdir processed

for scopus_data_archive in *.zip; do
  echo "Processing ${scopus_data_archive} ..."
  rm -rf tmp

  # Reduced verbosity
  # -u extracting files that are newer and files that do not already exist on disk
  # -q perform operations quietly
  unzip -u -q "${scopus_data_archive}" -d tmp
  cd tmp
  failed_files_dir="../${FAILED_FILES_DIR}/${scopus_data_archive}"
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
      [[ ! -d "${failed_files_dir}" ]] && mkdir -p "${failed_files_dir}"
      full_path=$(realpath $i)
      full_path=$(dirname $full_path)
      mv -f $full_path/ "${failed_files_dir}/"
    done
    rm -rf "${subdir}"
  done
  declare error_contents=$(grep ERROR ${PSQL_ERROR_LOG} | grep -v NOTICE | head -n 1)
  { cat <<HEREDOC
Error(s) occurred during processing of ${scopus_data_archive}.
See the error log in ${PWD}/tmp/${PSQL_ERROR_LOG} and failed files in $(cd "${failed_files_dir}" && pwd)/.
The first error:
${error_contents}
HEREDOC
  } | mailx -s "Scopus processing errors for ${PWD}/" j1c0b0d0w9w7g7v2@neteteam.slack.com

# mv "${scopus_data_archive}" processed/
  cd ..
done

exit 0
