#!/usr/bin/env bash
if (($# < 1)) || [[ "$1" == "-h" ]]; then
  cat << 'HEREDOC'
NAME

    active_processes.sh -- check the processes of the effective users and/or user groups

SYNOPSIS

    active_processes.sh [-u user] [-g group] ... [max_number_of_processes]
    active_processes.sh -h: display this help

DESCRIPTION

    Check the "active" processes of effective user(s) or group(s).

    "Active" processes are all processes excluding:

    1. `sshd` processes
    2. Login shells, e.g. `-bash`
    3. Status `T`: stopped by job control signal
    3. Status `Z`: defunct ("zombie") process, terminated but not reaped by its parent

    The following options are available:

    -u user                 Linux user name or EUID

    -g group                Linux group name or EGID

    max_number_of_processes defaults to 0

EXIT STATUS

    The utility exits with one of the following values:

    0   Didn't exceed the maximum number of processes
    1   Exceeded the maximum number of processes

EXAMPLES

        $ max_processes.sh -u jenkins 1

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
fi

set -e
set -o pipefail

ps_select_options=()
while (($# > 0)); do
  case "$1" in
    -u)
      shift
      ps_select_options+=("--user $1")
      ;;
    -g)
      shift
      ps_select_options+=("--group $1")
      ;;
    *)
      break
      ;;
  esac
  shift
done

# Get a script directory, same as by `$(dirname $0)`
#readonly SCRIPT_DIR=${0%/*}
#readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)

# Defaults to 0 when empty
declare -ri MAX_PROCESSES=$1

echo "Checking active processes for ${ps_select_options[*]}"

# Redirected output is not truncated: hence `-w` option(s) are not needed
# The filtering and formatting logic is too complex to use `pgrep`
# shellcheck disable=SC2086 # Using unquoted expansion to expand into multiple arguments
readonly PROCESSES=$(ps ${ps_select_options[*]} -o pid,stat,sid,user,group,start_time,args)

#region Filter in the active processes

active_processes=()
while IFS= read -r line; do
  if (( ${#active_processes[@]} > 0 )); then # Skip header parsing
    # Parse fields (whitespace is stripped)
    read -r pid stat sid user group start_time args <<< "$line"

    # Filter out `sshd` processes, login shells and `T` and `Z` states
    if [[ "$args" == sshd:* || "$args" == -* || "${stat:0:1}" == [TZ] ]]; then
      continue
    fi
  fi
  active_processes+=("$line")
done <<< "$PROCESSES"

#endregion

# Minus header
declare -i process_count=$((${#active_processes[@]} - 1))

if (( process_count > MAX_PROCESSES)); then
  echo -e "**Not in a quiet period.** The following $process_count processes of ${ps_select_options[*]} are running:\n"
  printf '%s\n' "${active_processes[@]}"
  exit 1
fi
echo "In a quiet period"

exit 0
