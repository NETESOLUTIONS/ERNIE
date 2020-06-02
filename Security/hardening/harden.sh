#!/usr/bin/env bash

usage() {
  cat << 'HEREDOC'
NAME

    harden -- harden a machine semi-automatically per included hardening recommendation scripts

SYNOPSIS

    sudo harden.sh [-k] [-m email] [-e excluded_dir] [-e ...] [-u unsafe_user] [-g unsafe_group] system_user
    harden.sh -h: display this help

DESCRIPTION

    The script automatically makes changes that it can to harden a server. Included hardening checks are based on the
    Baseline Security Configuration derived from the Center for Internet Security (CIS) Benchmark.

    The current directory is used for logs and configuration file backups (e.g. `./2020-05-19-09-33-20.bak/*`).

    The script would fail on the first problem that needs to be fixed manually. Correct the problem and re-run.
    The script should resume at the failing check.

    WARNING: it updates *all* yum packages to their latest versions, including, optionally the kernel.

    Kernel and Jenkins updates are done during automatically determined "safe" periods.

    The following options are available:

    -k                      Include Linux kernel in the updates.
                            Reboot safely and notify `notification_address` by email when kernel is updated.

    -m email                An address to send notification to

    -e excluded_dir         Directory(-ies) excluded from the ownership and system executables check.
                            This is needed for mapped Docker container dirs.
                            The Docker home (if Docker is installed) is excluded automatically.

    -u unsafe_user          Check "active" processes of this effective user to determine a "safe" period.

    -g unsafe_group         Check "active" processes of this effective group to determine a "safe" period.

    system_user             User account to assign ownership of unowned files and directories and backups.
                            The primary group of that user account will be used as group owner.

ENVIRONMENT

    Pre-requisite dependencies:

      # `pcregrep`

    PGDATABASE             When defined, used to include "active" non-system Postgres queries in the

EXIT STATUS

    The harden.sh utility exits with one of the following values:

    0   All hardening checks passed pending unsafe actions: kernel and Jenkins updates.
    >1  A hardening check failed, which could not be automatically corrected.

EXAMPLES

    sudo ./harden.sh -k -m j5g1e0d8w9w2t7v2@neteteam.slack.com -e /data1/upsource -g endusers admin
HEREDOC
  exit 1
}

set -e
set -o pipefail

# Check if Docker is installed
readonly DOCKER_HOME=$(docker info 2> /dev/null | pcregrep -o1 'Docker Root Dir: (.+)')
if [[ ${DOCKER_HOME} ]]; then
  exclude_dirs=("${DOCKER_HOME}")
else
  exclude_dirs=()
fi

safe_update_options=""
# If a character is followed by a colon, the option is expected to have an argument
while getopts km:e:u:g:h OPT; do
  case "$OPT" in
    k)
      readonly KERNEL_UPDATE=true
      ;;
    e)
      exclude_dirs+=("$OPTARG")
      ;;
    m)
      readonly NOTIFICATION_ADDRESS="$OPTARG"
      ;&
    m | u | g)
      # Pass-through options
      safe_update_options="$safe_update_options -$OPT $OPTARG"
      ;;
    *) # -h or `?`: an unknown option
      usage
      ;;
  esac
done
shift $((OPTIND - 1))

# Process positional parameters
[[ $1 == "" ]] && usage
readonly DEFAULT_OWNER_USER=$1
readonly DEFAULT_OWNER_GROUP=$(id --group --name "${DEFAULT_OWNER_USER}")

# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

if ! command -v pcregrep > /dev/null; then
  echo "Please install pcregrep"
  exit 1
fi

BACKUP_DIR=$(date "+%F-%H-%M-%S").bak
readonly BACKUP_DIR

MIN_NON_SYSTEM_UID=$(pcregrep -o1 '^UID_MIN\s+(\d+)' /etc/login.defs)
readonly MIN_NON_SYSTEM_UID

for f in "$SCRIPT_DIR"/functions/*.sh; do
  # shellcheck source=functions/*.sh
  source "$f"
done

# Execute checks
for f in "$SCRIPT_DIR"/recommendations-*/*.sh; do
  # shellcheck source=hardening-checks*/*.sh
  source "$f"
done

echo -e '### Configure PAM ###\n\n'

echo "6.3.1 Upgrade Password Hashing Algorithm to SHA-512"
echo "____CHECK____"
if [[ "$(authconfig --test | grep hashing | grep sha512)" != "" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  echo "authconfig --passalgo=sha512 --update"
  authconfig --passalgo=sha512 --update
fi
printf "\n\n"

echo "6.3.2 Set Password Creation Requirement Parameters Using pam_cracklib"
echo "____CHECK____"
PWD_CREATION_REQUIREMENTS="password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 \
authtok_type= ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1"
if grep -F "${PWD_CREATION_REQUIREMENTS}" /etc/pam.d/system-auth-ac; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/pam.d/system-auth-ac 'password\s+requisite\s+pam_pwquality.so' "${PWD_CREATION_REQUIREMENTS}"
fi
printf "\n\n"

echo "6.3.3 Set Lockout for Failed Password Attempts"
echo "____CHECK____"
echo "Azure already imposed the policy"
printf "\n\n"

echo "6.3.4 Limit Password Reuse"
echo "____CHECK____"
echo "Azure already imposed the policy"
printf "\n\n"

echo "6.3.4 Limit Password Reuse"
echo "___CHECK___"
if grep "remember=5" /etc/pam.d/system-auth-ac; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/password(\t\| )*sufficient/s/$/ remember=5/' /etc/pam.d/system-auth-ac
fi
printf "\n\n"

echo -e '### User Accounts and Environment ###\n\n'

echo "7.0.2 Set System Accounts to Non-Login"
echo "___CHECK___"
if grep -E -v "^\+" /etc/passwd \
  | awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $3<500 && $7!="/sbin/nologin")'; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  for user in $(awk -F: '($3 < 500) {print $1 }' /etc/passwd); do
    if [[ "${user}" != "root" ]]; then
      usermod -L ${user}
      if [[ ${user} != "sync" && ${user} != "shutdown" && ${user} != "halt" ]]; then
        usermod -s /sbin/nologin ${user}
      fi
    fi
  done
fi
printf "\n\n"

echo "7.0.3 Set Default Group for root Account"
echo "___CHECK___"
if [[ "$(grep "^root:" /etc/passwd | cut -f4 -d:)" == 0 ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  usermod -g 0 root
fi
printf "\n\n"

# DISABLED Not recommended in dev environment due to large amount of intersecting users' tasks
#echo "7.0.4 Set Default umask for Users"
#printf "\n\n"
#echo "7.0.4 Set Default umask for Users"
#echo "___CHECK 1/2___"
#grep "^umask 077" /etc/profile
#if [[ "$(grep "^umask 077" /etc/profile | wc -l)" != 0 ]]; then
#  echo "Check PASSED"
#else
#  echo "Check FAILED, correcting ..."
#  echo "___SET___"
#  umask 077
#  echo "umask 077" >> /etc/profile
#fi
#echo "___CHECK 2/2___"
#grep "^umask 077" /etc/bashrc
#if [[ "$(grep "^umask 077" /etc/bashrc | wc -l)" != 0 ]]; then
#  echo "Check PASSED"
#else
#  echo "Check FAILED, correcting ..."
#  echo "___SET___"
#  umask 077
#  echo "umask 077" >> /etc/bashrc
#fi
#printf "\n\n"

echo "7.0.5 Lock Inactive User Accounts"
echo "___CHECK___"
useradd -D | grep INACTIVE
if [[ "$(useradd -D | grep INACTIVE)" == "INACTIVE=35" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  useradd -D -f 35
fi
printf "\n\n"

echo -e '### Set Shadow Password Suite Parameters (/etc/login.defs) ###\n\n'

echo "7.1.1 Set Password Expiration Days"
echo "___CHECK___"
grep '^PASS_MAX_DAYS' /etc/login.defs
if [[ "$(grep '^PASS_MAX_DAYS' /etc/login.defs | sed 's/\(\t\| \)//g')" == "PASS_MAX_DAYS90" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/^PASS_MAX_DAYS/c\PASS_MAX_DAYS  90' /etc/login.defs
fi
printf "\n\n"

echo "7.1.2 Set Password Change Minimum Number of Days"
echo "___CHECK___"
grep '^PASS_MIN_DAYS' /etc/login.defs
if [[ "$(grep '^PASS_MIN_DAYS' /etc/login.defs | sed 's/\(\t\| \)//g')" == "PASS_MIN_DAYS7" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/^PASS_MIN_DAYS/c\PASS_MIN_DAYS  7' /etc/login.defs
fi
printf "\n\n"

echo "7.1.3 Set Password Expiring Warning Days"
echo "___CHECK___"
grep '^PASS_WARN_AGE' /etc/login.defs
if [[ "$(grep '^PASS_WARN_AGE' /etc/login.defs | sed 's/\t//g')" == "PASS_WARN_AGE7" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/^PASS_WARN_AGE/c\PASS_WARN_AGE  7' /etc/login.defs
fi
printf "\n\n"

if [[ ${KERNEL_UPDATE_MESSAGE} || ${JENKINS_UPDATE} == true ]]; then
  readonly LOG=${ABSOLUTE_SCRIPT_DIR}/safe_updates.log
  [[ ${KERNEL_UPDATE_MESSAGE} ]] && safe_update_options="-r "$KERNEL_UPDATE_MESSAGE" $safe_update_options"
  # shellcheck disable=SC2086 # Expanding `$safe_update_options` into multiple parameters
  "$SCRIPT_DIR/safe_updates.sh" $safe_update_options >> "$LOG"
fi

exit 0
