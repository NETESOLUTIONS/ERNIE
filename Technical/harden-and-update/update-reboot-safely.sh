#!/usr/bin/env bash

usage() {
  cat << 'HEREDOC'
NAME

    update-reboot-safely.sh -- update Jenkins and/or reboot during a quiet (safe) period

SYNOPSIS

    sudo update-reboot-safely.sh [-j] [-r message] [-m email] [-g unsafe_group] [-u unsafe_user] [-d postgres_DB]
    update-reboot-safely.sh -h: display this help

DESCRIPTION

    Update Jenkins and/or reboot when there are no Jenkins jobs or processes owned by unsafe user/group running.
    Disables a cron job for this script when safe.

    The following options are available:

    -j                          Update Jenkins

    -r message                  Reboot and email a `message` to `notification_address` when there are no:
                                * Jenkins jobs running
                                * "Active" processes owned by the group (EGID) and, optionally, user (EUID).
                                  These are all processes excluding:
                                  1. `sshd` processes
                                  2. Login shells, e.g. `-bash`
                                  3. Status `T`: stopped by job control signal
                                  4. Status `Z`: defunct ("zombie") process, terminated but not reaped by its parent
                                * Optionally, Postgres active, non-system queries running in the specified DB

        -m email                An address to send notification to

        -g unsafe_group         Owned (under EGID) processes are considered unsafe for reboot

        -u unsafe_user          Owned (under EUID) processes are considered unsafe for reboot.
                                `jenkins` user is automatically unsafe when there are more than 1 active processes.

        -d postgres_DB          When defined, check Postgres DB for active, non-system queries

ENVIRONMENT

    Pre-requisite dependency:

      # `pcregrep`

EXIT STATUS

    The utility exits with one of the following values:

    0   In the quiet period
    1   Not in the quiet period

HEREDOC
  exit 1
}

set -e
set -o pipefail

# If a character is followed by a colon, the option is expected to have an argument
while getopts jr:m:g:u:d:h OPT; do
  case "$OPT" in
    j)
      readonly JENKINS_UPDATE="true"
      ;;
    r)
      readonly REBOOT_MSG="$OPTARG"
      ;;
    m)
      readonly NOTIFICATION_ADDRESS="$OPTARG"
      ;;
    g)
      readonly UNSAFE_USER="$OPTARG"
      ;;
    u)
      readonly UNSAFE_GROUP="$OPTARG"
      ;;
    d)
      readonly POSTGRES_DB="$OPTARG"
      ;;
    *) # -h or `?`: an unknown option
      usage
      ;;
  esac
done
shift $((OPTIND - 1))

# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)
# Remove longest */ prefix
readonly SCRIPT_NAME_WITH_EXT=${0##*/}
readonly CRON_JOB="${ABSOLUTE_SCRIPT_DIR}/${SCRIPT_NAME_WITH_EXT}"
#readonly CRON_LOG=${ABSOLUTE_SCRIPT_DIR}/${SCRIPT_NAME}.log

echo -e "\n$(TZ=America/New_York date) ## Running $SCRIPT_NAME_WITH_EXT $* under ${USER}@${HOSTNAME} in ${PWD} ##\n"

disable_cron_job() {
  echo "Disabling the cron job"
  crontab -l | grep --invert-match -F "$CRON_JOB" | crontab -
}

readonly PROCESS_CHECK="${SCRIPT_DIR}/safe-period-detectors/active-processes.sh"

if [[ "$REBOOT_MSG" || "$JENKINS_UPDATE" == true ]]; then
  set +e
  ${PROCESS_CHECK} -u jenkins 1
  if (($? == 1)); then
    #    set -e
    #    enable_cron_job "$@"
    exit 1
  fi
  set -e

  if [[ "$JENKINS_UPDATE" == true ]]; then
    echo "Updating Jenkins"
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
fi

if [[ "$REBOOT_MSG" ]]; then
  readonly JENKINS_GROUPS=$(id jenkins)
  if [[ $UNSAFE_GROUP && $JENKINS_GROUPS == *($UNSAFE_GROUP)* ]]; then
    # Allow 1 Jenkins server process
    readonly MAX_GROUP_PROCESSES=1
  else
    readonly MAX_GROUP_PROCESSES=0
  fi

  if [[ $UNSAFE_GROUP ]] && ! "${PROCESS_CHECK}" -g "${UNSAFE_GROUP}" $MAX_GROUP_PROCESSES \
      || [[ $UNSAFE_USER ]] && ! ${PROCESS_CHECK} -u "${UNSAFE_USER}" \
      || [[ $POSTGRES_DB ]] && ! "${SCRIPT_DIR}/safe-period-detectors/active-postgres-queries.sh" "$POSTGRES_DB"; then
    #    enable_cron_job "$@"
    exit 1
  fi

  if [[ $NOTIFICATION_ADDRESS ]]; then
    # Notify by email
    echo "$REBOOT_MSG" | mailx -S smtp=localhost -s "Hardening: server reboot" "$NOTIFICATION_ADDRESS"
    sleep 10
  fi

  disable_cron_job

  echo "$(TZ=America/New_York date) Done. **Rebooting**"
  reboot
else
  disable_cron_job
fi

echo "$(TZ=America/New_York date) Done"
exit 0
