#!/usr/bin/env bash
if [[ "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    process_directory.sh -- process a directory of Scopus data

SYNOPSIS

    process_directory.sh [-c] [working_directory]
    process_directory.sh -h: display this help

DESCRIPTION

    Parse all source Scopus files and update data in the DB in parallel.
    Extract *.zip in the working directory one-by-one, updating files: newer and non-existent only.
    Process an extracted sub-directory and remove it at the end.
    Use the specified working_directory (current directory by default).
    Produce logs with reduced verbosity to reduce log volume.

    The following options are available:

    -c    clean data before processing and don't resume processing. WARNING: be aware that you'll lose all loaded data!

ENVIRONMENT

    * PGHOST/PGDATABASE/PGUSER  default Postgres connection parameters

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -e
#set -ex
set -o pipefail

# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
declare -rx ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)

while (( $# > 0 )); do
  case "$1" in
    -c)
      readonly CLEAN_MODE=true;;
    *)
      break
  esac
  shift
done

if (( $# > 0 )); then
  cd "$1"
fi
echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

if ! which parallel >/dev/null; then
  echo "Please install GNU Parallel"
  exit 1
fi

parse_xml() {
  set -e
  local xml="$1"
  echo "Processing $xml ..."
  psql -f ${ABSOLUTE_SCRIPT_DIR}/parser.sql <"$xml"
  echo "$xml: done."
}
export -f parse_xml

# language=PostgresPLSQL
if [[ "${CLEAN_MODE}" == true ]]; then
  psql -v ON_ERROR_STOP=on --echo-all <<'HEREDOC'
    TRUNCATE scopus_publication_groups CASCADE;
HEREDOC
fi

for scopus_data_archive in *.zip; do
  echo "Processing ${scopus_data_archive} ..."

  # Reduced verbosity
  # -u extracting files that are newer and files that do not already exist on disk
  # -q perform operations quietly
  unzip -u -q "${scopus_data_archive}"

  for subdir in $(find . -mindepth 1 -maxdepth 1 -type d); do
    cd "${subdir}"
    # Process Scopus XML files in parallel
    # Reduced verbosity
    find . -name '2*.xml' | parallel --halt soon,fail=1 --line-buffer --tagstring '|job#{#} s#{%}|' parse_xml "{}"
    # xargs -n: Set the maximum number of arguments taken from standard input for each invocation of utility
    # find . -name '2*.xml' -print0 | xargs -0 -n 1 -I '{}' bash -c "parse_xml {}"
    #  bash -c "set -e; echo -e '\n{}\n'; psql -f ${ABSOLUTE_SCRIPT_DIR}/parser.sql <{}; echo '{}: done.'" \;
    cd ..
    rm -rf "${subdir}"
  done
done

exit 0
