#!/usr/bin/env bash

usage() {
  cat << 'HEREDOC'
NAME

    safe_updates.sh -- update Jenkins and/or reboot during a quiet period

SYNOPSIS

    sudo safe_updates.sh [-r message] [-j] unsafe_process_user_group [unsafe_process_user]
    safe_updates.sh -h: display this help

DESCRIPTION

    Take actions when the system is in a quiet period, that is there are no:
      # Postgres non-system queries running (if `psql` is installed)
      # Jenkins jobs running
      # Processes owned by the select user group
      # Processes owned by the select user

    The following options are available:

    -r                          Reboot and use `message` to send an email notification

    -j                          Update Jenkins

    unsafe_process_user_group   Owned processes are checked to determine a quiet period

    unsafe_process_user         Owned processes are checked to determine a quiet period

EXIT STATUS

    The safe_updates.sh utility exits with one of the following values:

    0   In the quiet period
    1   Not in the quiet period

HEREDOC
  exit 1
}

set -e
set -o pipefail

# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
#readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)
# Remove longest */ prefix
declare -rx SCRIPT_NAME_WITH_EXT=${0##*/}

# If a character is followed by a colon, the option is expected to have an argument
while getopts r:j OPT; do
  case "$OPT" in
    r)
      readonly REBOOT="$OPTARG"
      ;;
    j)
      readonly JENKINS_UPDATE="true"
      ;;
    *) # -h or `?`: an unknown option
      usage
      ;;
  esac
done
shift $((OPTIND - 1))

# Process positional parameters
[[ $1 == "" ]] && usage
declare -rx UNSAFE_PROCESS_USER_GROUP=$1
declare -rx UNSAFE_PROCESS_USER=$2

TZ=America/New_York echo -e "\n$(date) ## Running $SCRIPT_NAME_WITH_EXT under ${USER}@${HOSTNAME} in ${PWD} ##\n"

disable_cron_job() {
  echo "Disabling cron job..."
  crontab -l | grep --invert-match -F "$SCRIPT_NAME_WITH_EXT" | crontab -
}

########################################
# Notify by email
#
# Arguments:
#   $1 subject
#   $2 body
#   $3 address
########################################
notify() {
  echo "$2" | mailx -S smtp=localhost -s "$1"
}

readonly PROCESS_CHECK="${SCRIPT_DIR}/quiet_period_checks/active_processes.sh"

if ! ${PROCESS_CHECK} -u jenkins 1 && [[ "$REBOOT" || "$JENKINS_UPDATE" == true ]]; then
  exit 1
fi
if [[ "$JENKINS_UPDATE" == true ]]; then
  if command -v monit > /dev/null; then
    monit unmonitor Jenkins
  fi
  systemctl stop jenkins

  yum update -y jenkins

  systemctl start jenkins
  if command -v monit > /dev/null; then
    # Re-enabling monit shortly after start can crash Jenkins
    sleep 20
    monit monitor Jenkins
  fi
fi

if [[ "$REBOOT" == true ]]; then
  if ! ! ${PROCESS_CHECK} -g ${UNSAFE_PROCESS_USER_GROUP} 1; then
    exit 1
  fi

  if [[ $UNSAFE_PROCESS_USER ]] && ! ${PROCESS_CHECK} -u ${UNSAFE_PROCESS_USER}; then
    exit 1
  fi

  if command -v psql > /dev/null && ! ${SCRIPT_DIR}/quiet_period_checks/active_postgres_queries.sh; then
    exit 1
  fi

  echo "In a quiet period"

  disable_cron_job

  notify "Hardening: server reboot" w6y4s9s6d2d1a7a4@neteteam.slack.com
  sleep 10

  echo "**Rebooting**, please wait for 2 minutes, then reconnect"
  reboot
else
  disable_cron_job
fi

echo "$(date) Done"
exit 0
