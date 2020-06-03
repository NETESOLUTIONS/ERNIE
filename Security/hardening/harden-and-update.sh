#!/usr/bin/env bash

usage() {
  cat << 'HEREDOC'
NAME

    harden-and-update.sh.sh -- harden a machine semi-automatically per included hardening checks and update packages

SYNOPSIS

    sudo harden-and-update.sh [-k] [-m email] [-e excluded_dir] [-e ...] [-u unsafe_user] [-g unsafe_group] system_user
    harden-and-update.sh.sh.sh -h: display this help

DESCRIPTION

    The script automatically makes changes that it can to harden a server. Included hardening checks are based on the
    Baseline Security Configuration derived from the Center for Internet Security (CIS) Benchmark.

    WARNING: Some checks incorporate site-specific policies. Review them before running in a new environment.

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

Version 2.0                                           June 2020
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

yum clean expire-cache

for f in "$SCRIPT_DIR"/functions/*.sh; do
  # shellcheck source=functions/*.sh
  source "$f"
done

# Execute checks
for f in "$SCRIPT_DIR"/checks-*/*.sh; do
  # shellcheck source=hardening-checks*/*.sh
  source "$f"
done

if [[ $KERNEL_UPDATE ]]; # Install an updated kernel package if available
  yum --enablerepo=elrepo-kernel install -y kernel-ml python-perf

  kernel_version=$(uname -r)
  latest_kernel_package_version=$(rpm --query --last kernel-ml | head -1 | pcregrep -o1 'kernel-ml-([^ ]*)')
  # RPM can't format --last output and
  #available_kernel_version=$(rpm --query --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-ml)

  if [[ ${kernel_version} == ${latest_kernel_package_version} ]]; then
    echo "Check PASSED"
    if [[ $NOTIFICATION_ADDRESS ]]; then
      echo "The kernel version is up to date: v${kernel_version}" \
          | mailx -S smtp=localhost -s "Hardening: kernel check" "$NOTIFICATION_ADDRESS"
    fi
  else
    readonly KERNEL_UPDATE_MESSAGE="Kernel update from v${kernel_version} to v${latest_kernel_package_version}"
    echo "Check FAILED, correcting ..."
    echo "___SET___"

    # Keep 2 kernels including the current one
    package-cleanup -y --oldkernels --count=2

    grub2-set-default 0
    grub2-mkconfig -o /boot/grub2/grub.cfg
  fi
fi

if [[ ${KERNEL_UPDATE_MESSAGE} || ${JENKINS_UPDATE} == true ]]; then
  readonly LOG=${ABSOLUTE_SCRIPT_DIR}/update-reboot-safely.log
  [[ ${KERNEL_UPDATE_MESSAGE} ]] && safe_update_options="-r "$KERNEL_UPDATE_MESSAGE" $safe_update_options"
  # shellcheck disable=SC2086 # Expanding `$safe_update_options` into multiple parameters
  "$SCRIPT_DIR/update-reboot-safely.sh" $safe_update_options >> "$LOG"
fi

exit 0
