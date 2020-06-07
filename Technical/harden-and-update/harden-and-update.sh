#!/usr/bin/env bash

usage() {
  cat << 'HEREDOC'
NAME

    harden-and-update.sh -- harden a Red Hat / CentOS Linux family server and update packages

SYNOPSIS

    sudo [--preserve-env=PGDATABASE] harden-and-update.sh [OPTION]... system_user
    harden-and-update.sh -h: display this help

DESCRIPTION

    The script automatically makes changes that it can to harden a server.
    Included hardening checks are based on the OS-specific Center for Internet Security (CIS) Benchmark.

    WARNING: Some checks incorporate site-specific policies. Review them before running in a new environment.
    WARNING: When the SSH config is hardened, test SSH connectivity after the change.

    Any changed config files are backed up on each run.
    The current directory is used for the log, progress, and backups (e.g. `./2020-05-19-09-33-20.bak/**`).

    The script would fail on the first problem that needs to be fixed manually or on the first error.
    Correct the problem and re-run. The script should resume at the failed check.

    The script patches all yum packages to their latest security patched versions.
    Optionally, the kernel could be updated to the latest LTS version as well.

    Kernel and Jenkins updates are done during automatically determined "safe" periods.

    The following options are available:

    -e excluded_dir         Directory(-ies) excluded from the ownership and system executables check.
                            This is needed for mapped Docker container dirs.
                            Docker system directories (if Docker is installed) are excluded automatically.

    -k                      Update Linux kernel to the latest LTS version.
                            Reboot safely and notify `notification_address` by email when kernel is updated.

      -m email              An address to send notification to

      -u unsafe_user        Check "active" processes of this effective user to determine a "safe" period.

      -g unsafe_group       Check "active" processes of this effective group to determine a "safe" period.

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

    sudo ./harden-and-update.sh -e /data1/upsource -k -m j5g1e0d8w9w2t7v2@neteteam.slack.com -g endusers admin

    sudo --preserve-env=PGDATABASE ./harden-and-update.sh -e /data1/upsource admin

Version 2.0                                           June 2020
HEREDOC
  exit 1
}

set -e
set -o pipefail
shopt -s extglob

# Check if Docker is installed
readonly DOCKER_HOME=$(docker info 2> /dev/null | pcregrep -o1 'Docker Root Dir: (.+)')
if [[ ${DOCKER_HOME} ]]; then
  # See https://stackoverflow.com/questions/46672001/is-it-safe-to-clean-docker-overlay2 for more on `/var/lib/docker`
  export exclude_dirs=("${DOCKER_HOME}" /var/lib/docker)
else
  export exclude_dirs=()
fi

declare -a safe_update_options
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
      safe_update_options+=(-$OPT $OPTARG)
      ;;
    *) # -h or `?`: an unknown option
      usage
      ;;
  esac
done
shift $((OPTIND - 1))

# Process positional parameters
[[ $1 == "" ]] && usage
declare -rx DEFAULT_OWNER_USER=$1
declare -rx DEFAULT_OWNER_GROUP=$(id --group --check_name "${DEFAULT_OWNER_USER}")

# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)

echo -e "\nharden-and-update.sh> running under ${USER}@${HOSTNAME} in ${PWD} \n"

if ! command -v pcregrep > /dev/null; then
  echo "Please install pcregrep"
  exit 1
fi

BACKUP_DIR=$(date "+%F-%H-%M-%S").bak
declare -rx BACKUP_DIR

MIN_NON_SYSTEM_UID=$(pcregrep -o1 '^UID_MIN\s+(\d+)' /etc/login.defs)
declare -rx MIN_NON_SYSTEM_UID

# Source and export all functions to make them available to all check scripts
for function_script in "$SCRIPT_DIR"/functions/*.sh; do
  # shellcheck source=functions/*.sh
  source "$function_script"
done

echo -e "\nExecuting checks...\n"
for check_script in "$SCRIPT_DIR"/checks-*/*.sh "$SCRIPT_DIR"/checks-*/site-specific/*.sh; do
  # Remove longest */ prefix
  check_name_with_ext=${check_script##*/}

  if [[ "${check_name_with_ext}" != *.* ]]; then
    check_name_with_ext=${check_name_with_ext}.
  fi

  # Remove shortest .* suffix
  check_name=${check_name_with_ext%.*}

  progress_file="${check_name}.done"
  if [[ -f "$progress_file" ]]; then
    echo "Skipping '${check_name}': DONE"
  else
    "$check_script"

    touch "$progress_file"
    chown "$DEFAULT_OWNER_USER:$DEFAULT_OWNER_GROUP" "$progress_file"
    chmod g+w "$progress_file"
  fi
done
echo "All checks PASSED"

yum clean expire-cache

if [[ $KERNEL_UPDATE ]]; then # Install an updated kernel package if available
  echo -e "\nChecking for kernel updates"

  # ELRepo repository must hve been installed
  # `kernel-lt`: Long Term Support (LTS) version, `kernel-ml`: the mainline version
  # TBD `python-perf` package might be needed
  yum --enablerepo=elrepo-kernel install -y kernel-lt

  kernel_version=$(uname -r)
  latest_kernel_package_version=$(rpm --query --last kernel-lt | head -1 | pcregrep -o1 'kernel-lt-([^ ]*)')
  # RPM can't format --last output and
  #available_kernel_version=$(rpm --query --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-lt)

  if [[ ${kernel_version} == ${latest_kernel_package_version} ]]; then
    readonly KERNEL_UPDATE_MESSAGE="The kernel version is up to date: v${kernel_version}"

    if [[ $NOTIFICATION_ADDRESS ]]; then
      echo "$KERNEL_UPDATE_MESSAGE" | mailx -S smtp=localhost -s "Hardening: kernel check" "$NOTIFICATION_ADDRESS"
    fi
  else
    readonly KERNEL_UPDATE_MESSAGE="Kernel is updated from v${kernel_version} to v${latest_kernel_package_version}"
    readonly KERNEL_UPDATE_AVAILABLE=true
    echo "Check FAILED, correcting ..."
    echo "___SET___"

    # Keep 2 kernels including the current one
    package-cleanup -y --oldkernels --count=2

    grub2-set-default 0
    backup /boot/grub2/grub.cfg
    grub2-mkconfig -o /boot/grub2/grub.cfg
  fi
  echo "$KERNEL_UPDATE_MESSAGE"
fi

if ! yum check-update jenkins; then
  echo -e "Jenkins update is available"

  # When Jenkins is not installed, this is false
  readonly JENKINS_UPDATE_AVAILABLE=true
fi

if [[ ${KERNEL_UPDATE_AVAILABLE} == true || ${JENKINS_UPDATE_AVAILABLE} == true ]]; then
  if [[ ${KERNEL_UPDATE_AVAILABLE} == true ]]; then
    echo "Rebooting safely..."
    safe_update_options+=(-r "'$KERNEL_UPDATE_MESSAGE'")
  fi
  if [[ $JENKINS_UPDATE_AVAILABLE == true ]]; then
    echo "Updating Jenkins safely..."
    safe_update_options+=(-j)
  fi
  if [[ $PGDATABASE ]]; then
    echo "Will check $PGDATABASE Postgres DB for active, non-system queries"
    safe_update_options+=(-d "$PGDATABASE")
  fi

  readonly CRON_JOB="${ABSOLUTE_SCRIPT_DIR}/update-reboot-safely.sh"
  readonly CRON_LOG="${PWD}/update-reboot-safely.log"
  # Schedule safe reboot or update and let the current script finish successfully
  enable_cron_job "${safe_update_options[@]}"
fi

rm -- *.done

exit 0
