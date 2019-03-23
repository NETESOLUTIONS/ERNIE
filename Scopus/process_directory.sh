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
year_dir=$(pwd)
mkdir -p ${year_dir}/corrupted

if ! which parallel >/dev/null; then
  echo "Please install GNU Parallel"
  exit 1
fi

parse_xml() {
  set -e
  local xml="$1"
  echo "Processing $xml ..."
  psql -f ${ABSOLUTE_SCRIPT_DIR}/parser.sql <"$xml" 2>> ~/error_log.txt
  echo "$xml: done."
}
export -f parse_xml

# language=PostgresPLSQL
if [[ "${CLEAN_MODE}" == true ]]; then
  psql -v ON_ERROR_STOP=on --echo-all <<'HEREDOC'
    TRUNCATE scopus_publication_groups CASCADE;
HEREDOC
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
    set +o
    
    find "${subdir}" -name '2*.xml' | \
      parallel --joblog ~/parallel_log.txt --halt never --line-buffer --tagstring '|job#{#} s#{%}|' parse_xml "{}"
    set -e
    set -o pipefail
    file_names=$(cut -f 7,9 ~/parallel_log.txt | awk '{if ($1 == "3") print $3;}') 
    for i in $(echo $file_names)
    do
	full_path=$(realpath $i)
   	full_path=$(dirname $full_path)
 	mv $full_path/ ${year_dir}/corrupted/
    done
    # xargs -n: Set the maximum number of arguments taken from standard input for each invocation of utility
    # TODO follow up re: fail early for find -exec
    #  find . -name '2*.xml' -print0 | xargs -0 -n 1 -I '{}' bash -c "parse_xml {}"
    #  bash -c "set -e; echo -e '\n{}\n'; psql -f ${ABSOLUTE_SCRIPT_DIR}/parser.sql <{}; echo '{}: done.'" \;
    rm -rf "${subdir}"
  done
  error_contents=$(grep ERROR /home/sitaram/error_log.txt | grep -v NOTICE | head -n 1)
  echo -e "Path ${year_dir}/corrupted contains all corrupted files for year $1 \n ${error_contents}" | mailx -s "Scopus year $1" j1c0b0d0w9w7g7v2@neteteam.slack.com
  rm ~/error_log.txt
  cd ..
  mv "${scopus_data_archive}" processed/
done
rmdir tmp

exit 0
