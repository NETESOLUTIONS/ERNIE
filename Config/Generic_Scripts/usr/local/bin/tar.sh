#!/usr/bin/env bash
if [[ "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    tar.sh -- archive to a compressed TAR

SYNOPSIS

    tar.sh [TAR option] [...] [archive_with_ext] [file_or_directory] [...]
    tar.sh -h: display this help

DESCRIPTION

    Create a gzip-compressed TAR with verbose output.
    Archive name defaults to `{current directory name}.tar.gz`. Files default to everything (`.`).

    Pass-through TAR options would be applied after `-c -z -v` and before `-f archive_and_files`.

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -e
#set -ex
set -o pipefail

# Get a script directory, same as by $(dirname $0)
#readonly SCRIPT_DIR=${0%/*}
#readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)

# Find first non-switch (not -*) option
while (( $# > 0 )); do
  case "$1" in
    -*)
      options="$options $1"
      ;;
    *)
      archive_and_files="$archive_and_files $1"
      ;;
  esac
  shift
done
readonly options

#readonly WORK_DIR=${1:-${ABSOLUTE_SCRIPT_DIR}/build} # $1 with the default
#if [[ ! -d "${WORK_DIR}" ]]; then
#  mkdir "${WORK_DIR}"
#  chmod g+w "${WORK_DIR}"
#fi
#cd "${WORK_DIR}"
echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

if [[ ! ${archive_and_files} ]]; then
  # Remove longest */ prefix
  readonly current_dir_name_with_ext=${PWD##*/}
  archive_and_files="${current_dir_name_with_ext}.tar.gz ."
  readonly archive_and_files
fi

# -c: Create a new archive containing the specified items.
# -z: Compress the resulting archive with gzip(1)
# -f: Write the archive to the specified file
# shellcheck disable=SC2086 # Options are expanded into multiple parameters
tar -c -z -v ${options} -f ${archive_and_files}

exit 0
