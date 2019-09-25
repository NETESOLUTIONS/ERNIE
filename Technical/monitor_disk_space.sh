#!/usr/bin/env bash
if [[ "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    monitor_disk_space.sh -- check all local mounts and fail if the disk space use exceeds the threshold

SYNOPSIS

    monitor_disk_space.sh [used_threshold_percentage]
    monitor_disk_space.sh -h: display this help

DESCRIPTION

    Check all local mounts and fail if the used % exceeds the threshold %.
    Prints disk usage in descending perenetage order and warnings for mounts exceeding threshols.

    The following options are available:

    used_threshold_percentage   threshold percentage: an integer number (defaults to 85)

EXIT STATUS

    The monitor_disk_space.sh utility exits with one of the following values:

    0   Use on all local mounts <= threshold
    1   Use on at least one mount > threshold

EXAMPLES

        $ monitor_disk_space.sh 90

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -e
set -o pipefail
#set -x

readonly SPACES_15='               '
declare -ri DEFAULT_PERCENTAGE=85
declare -ri threshold=${1:-$DEFAULT_PERCENTAGE}

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

warnings=false
echo -e "Mount           Size\tUsed\tAvail\tUse%\tFilesystem";

# Use process substitution to pipe into the loop in order to preserve warnings variable
while read -r filesystem size used avail used_percentage mount; do
  echo -e "$mount${SPACES_15:0:$((15 - ${#mount}))} $size\t$used\t$avail\t$used_percentage\t$filesystem";
  declare -i usage=${used_percentage/\%/}
  if ((usage > threshold)); then
    echo "WARNING: Used disk space exceeds ${threshold}% threshold!"
    warnings=true
  fi
done < <(df -Phl | tail -n +2 | sort --key=5 --numeric-sort --reverse)

[[ $warnings == true ]] && exit 1
exit 0
