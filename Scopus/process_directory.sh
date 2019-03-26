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
#-e    stop on the first error
  exit 1
fi


set -e
set -o pipefail
#set -x

# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
declare -rx ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)
declare -rx ERROR_LOG=errors.log
#readonly PARALLEL_JOB_LOG=parallel_job.log
declare -x FAILED_FILES="False"

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
#year_dir=$(pwd)
#mkdir -p ${year_dir}/corrupted

if ! which parallel >/dev/null; then
  echo "Please install GNU Parallel"
  exit 1
fi

parse_xml() {
  local xml="$1"
  echo "Processing $xml ..."
  if psql -f ${ABSOLUTE_SCRIPT_DIR}/parser.sql -v "xml_file=$PWD/$xml" 2>> "${ERROR_LOG}"; then
    echo "$xml: DONE."
  else
#    echo -e "$xml FAILED\n" | tee -a "${ERROR_LOG}"
    [[ ! -d "${failed_files_dir}" ]] && mkdir -p "${failed_files_dir}"
    full_path=$(realpath ${xml})
    full_path=$(dirname ${full_path})
    mv -f $full_path/ "${failed_files_dir}/"
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

  # No longer need a separate email notification now.
  # The build fails at the end if any errors occurred hence we get heads up.
  #  declare error_contents=$(grep ERROR tmp/${ERROR_LOG} | grep -v NOTICE | head -n 1)
  #  { cat <<HEREDOC
  #Error(s) occurred during processing of ${PWD}/
  #See the failed files in $(cd "${FAILED_FILES_DIR}" && pwd)/
  #The first error:
  #---
  #${error_contents}
  #---
  #HEREDOC
  #  } | mailx -s "Scopus processing errors for ${PWD}/" j1c0b0d0w9w7g7v2@neteteam.slack.com

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
#[[ ! -d processed ]] && mkdir processed

[[ ${STOP_ON_THE_FIRST_ERROR} == "true" ]] && readonly PARALLEL_HALT_OPTION="--halt soon,fail=1"

for scopus_data_archive in *.zip; do
  echo "Processing ${scopus_data_archive} ..."

  # Reduced verbosity
  # -u extracting files that are newer and files that do not already exist on disk
  # -q perform operations quietly
  unzip -u -q "${scopus_data_archive}" -d tmp
  cd tmp
  export failed_files_dir="../${FAILED_FILES_DIR}/${scopus_data_archive}"
  for subdir in $(find . -mindepth 1 -maxdepth 1 -type d); do
    # Process Scopus XML files in parallel
    # Reduced verbosity
#    set +e
#    set +o pipefail
    # --joblog "${PARALLEL_JOB_LOG}"
    if ! find "${subdir}" -name '2*.xml' | \
        parallel ${PARALLEL_HALT_OPTION} --line-buffer --tagstring '|job#{#} s#{%}|' parse_xml "{}"; then
      [[ ${STOP_ON_THE_FIRST_ERROR} == "true" ]] && check_errors
    fi
#    set -e
#    set -o pipefail
#    failed_files=$(cut -f 7,9 "${PARALLEL_JOB_LOG}" | awk '{if ($1 == "3") print $3;}')
#    if [[ -n ${failed_files} ]]; then
#      FAILED_FILES="True"
#    fi
#    for i in $(echo $failed_files); do
#      [[ ! -d "${failed_files_dir}" ]] && mkdir -p "${failed_files_dir}"
#      full_path=$(realpath $i)
#      full_path=$(dirname $full_path)
#      mv -f $full_path/ "${failed_files_dir}/"
#    done
    rm -rf "${subdir}"
  done
  
  # mv "${scopus_data_archive}" processed/
  cd ..
done

check_errors
exit 0
