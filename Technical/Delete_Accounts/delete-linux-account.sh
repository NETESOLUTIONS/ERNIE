#!/usr/bin/env bash

usage() {
  cat <<'HEREDOC'
NAME

    delete-linux-account.sh -- remove a Linux account and the home directory of a user

SYNOPSIS

    sudo delete-linux-account.sh [-n] username group
    delete-linux-account.sh -h: display this help

DESCRIPTION

    Remove a Linux account and the home directory. If a user does not exist the list of users in the group is displayed.
    Requires root permissions: execute under `sudo`.

    username    an end user name, conforming to Linux and Postgres requirements

    The following options are available:

    -n  do not fail if the user doesn't exist

EXIT STATUS

    The utility exits with one of the following values:

    0   successfully removed
    1   error, e.g. the username doesn't exist

AUTHOR(S)

    Written by Dmitriy "DK" Korobskiy.
HEREDOC
  exit 1
}

set -e
set -o pipefail

# If a character is followed by a colon, the option is expected to have an argument
while getopts nh OPT; do
  case "$OPT" in
    n)
      readonly NO_FAIL_MODE=true
      ;;
    *) # -h or `?`: an unknown option
      usage
      ;;
  esac
done
shift $((OPTIND - 1))

# Process positional parameters
[[ $2 == "" ]] && usage

readonly DELETED_USER="$1"
readonly GROUP="$2"

# Get a script directory, same as by $(dirname $0)
#readonly SCRIPT_DIR=${0%/*}
#readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)

#readonly WORK_DIR=${1:-${ABSOLUTE_SCRIPT_DIR}/build} # $1 with the default
#if [[ ! -d "${WORK_DIR}" ]]; then
#  mkdir "${WORK_DIR}"
#  chmod g+w "${WORK_DIR}"
#fi
#cd "${WORK_DIR}"
echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

declare -ri NON_EXISTING_USER_EXIT_CODE=6

set +e
userdel -r "${DELETED_USER}"
declare -ri EXIT_CODE=$?
set -e

if (( EXIT_CODE == 0 )); then
  echo "Linux user ${DELETED_USER} has been removed along with their home directory."
  exit 0
fi

if [[ "$NO_FAIL_MODE" == "" ]] || (( EXIT_CODE != NON_EXISTING_USER_EXIT_CODE )); then
  echo "Failed!"
  echo "$GROUP users:"
  lid --group --onlynames "$GROUP" | sort
  exit 1
fi
