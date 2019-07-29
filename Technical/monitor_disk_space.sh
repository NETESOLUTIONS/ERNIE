#!/usr/bin/env bash
if [[ "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    monitor_disk_space.sh -- do something

SYNOPSIS

    monitor_disk_space.sh
    monitor_disk_space.sh -h: display this help

DESCRIPTION

    Do something. Use the specified working_directory ({script_dir}/build/ by default).

    The following options are available:

    -c    clean data before processing and don't resume processing. WARNING: be aware that you'll lose all loaded data!
    -r    reverse order of processing

ENVIRONMENT

    VAR May be used to specify default options that will be placed at the beginning of the argument list.
        Backslash-escaping is not supported, unlike the behavior in GNU grep.

EXIT STATUS

    The monitor_disk_space.sh utility exits with one of the following values:

    0   One or more lines were selected.
    1   No lines were selected.
    >1  An error occurred.

EXAMPLES

    To find all occurrences of the word `patricia' in a file:

        $ monitor_disk_space.sh 'patricia' myfile

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -e
set -o pipefail
#set -x

# Get a script directory, same as by $(dirname $0)
#readonly SCRIPT_DIR=${0%/*}
#readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)
#
#readonly WORK_DIR=${1:-${ABSOLUTE_SCRIPT_DIR}/build} # $1 with the default
#if [[ ! -d "${WORK_DIR}" ]]; then
#  mkdir "${WORK_DIR}"
#  chmod g+w "${WORK_DIR}"
#fi
#cd "${WORK_DIR}"
echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

df -Phl | { read -r header; echo "${header}"; sort --key=5 --numeric-sort --reverse; } | \
  while read -r filesystem size used avail use_percentage mount; do
    echo -e "$filesystem    \t$size\t$used\t$avail\t$use_percentage\t$mount";
done