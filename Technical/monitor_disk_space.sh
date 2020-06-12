#!/usr/bin/env bash
if [[ "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    monitor_disk_space.sh -- check all local mounts and fail if the disk space use exceeds the THRESHOLD

SYNOPSIS

    monitor_disk_space.sh [used_THRESHOLD_percentage]
    monitor_disk_space.sh -h: display this help

DESCRIPTION

    Check all local mount points and fail if the used space % exceeds the THRESHOLD %.
    Report disk usage in the descending percentage order.

    The following options are available:

    used_THRESHOLD_percentage   THRESHOLD percentage: an integer number (defaults to 85)

EXIT STATUS

    The utility exits with one of the following values:

    0   Use on all local mounts <= THRESHOLD
    1   Use on at least one mount > THRESHOLD

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

declare -ri DEFAULT_PERCENTAGE=85

# Positional parameters
declare -ri THRESHOLD=${1:-$DEFAULT_PERCENTAGE}

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

warnings=false
printf '%8s %8s %8s %s\n' 'Use' 'Avail' 'Size' 'Mount'

coproc { df -Phl | tail -n +2 | sort --key=5 --numeric-sort --reverse; }
# As of Bash 4, `COPROC_PID` has to be saved before it gets reset on process termination
_co_pid=$COPROC_PID
# shellcheck disable=SC2034 # ignoring unused fields
while read -r filesystem size used avail used_percentage mount; do
  printf '%8s %8s %8s %s\n' "$used_percentage" "$avail" "$size" "$mount"

  declare -i usage=${used_percentage/\%/}
  if ((usage > THRESHOLD)); then
    echo "WARNING: Used disk space exceeds ${THRESHOLD}% THRESHOLD!"
    warnings=true
  fi
done <& "${COPROC[0]}"
wait "$_co_pid"

[[ $warnings == true ]] && exit 1
exit 0
