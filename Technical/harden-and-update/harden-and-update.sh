#!/usr/bin/env bash

usage() {
  cat << 'HEREDOC'
NAME

    harden-and-update.sh -- harden a Red Hat / CentOS Linux family server and update packages

SYNOPSIS

    sudo [--preserve-env=PGDATABASE] harden-and-update.sh [OPTION]...
    harden-and-update.sh -h: display this help

DESCRIPTION

    The script automatically makes changes that it can to harden a server.
    Included hardening checks are based on the OS-specific Center for Internet Security (CIS) Benchmark.

    WARNING: Some checks incorporate site-specific policies. Review them before running in a new environment.

    WARNING: SSH into a server before running on a new server. After the SSH config is hardened, test SSH connectivity.

    The script fails on the first problem that needs to be fixed manually or on the first script error.
    Correct the problem and re-run. The script should resume at the failed check.

    The script patches all yum packages to their latest security patches.
    Optionally, the kernel could be updated to the latest LTS version as well.

    Kernel and Jenkins updates are done during automatically determined "safe" periods.

    All changed config files are backed up for each run.
    The working directory is used to write the safe update log, progress files, and backups.
    The script directory is used to write the safe update lock file.

    The following options are available:

    -e excluded_dir         Directory(-ies) excluded from the SUID/SGID checks.
                            Docker system directories (if Docker is installed) are excluded automatically.

    -k                      (CentOS only) Update Linux kernel to the latest LTS version.
                            Reboot safely and notify `notification_address` by email when kernel is updated.

      -m email              An address to send notification to

    -u unsafe_user          Check "active" processes of this effective user to determine a "safe" period.

    -g unsafe_group         Check "active" processes of this effective group to determine a "safe" period.

    -o system_user          User account to assign ownership of backups and progress files.
                            The primary group of that user account will be used as group owner.
                            Defaults to `jenkins`.

    -v                      Verbose mode

ENVIRONMENT

    Pre-requisite dependencies:

      # `pcregrep`
      # (CentOS) ELRepo repository must be installed

    PGDATABASE             When defined, used to include "active" non-system Postgres queries in the

EXIT STATUS

    The harden.sh utility exits with one of the following values:

    0   All hardening checks passed pending unsafe actions: kernel and Jenkins updates.

    1   Pre-requisite check failed.

    >=1 A hardening check failed, which could not be automatically corrected.

EXAMPLES

    sudo ./harden-and-update.sh -e /data1/upsource -k -m j5g1e0d8w9w2t7v2@neteteam.slack.com -g endusers admin

    sudo --preserve-env=PGDATABASE ./harden-and-update.sh -e /data1/upsource admin

Version 2.2.1                                           August 2020
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
  exclude_dirs=("${DOCKER_HOME}" /var/lib/docker)
else
  exclude_dirs=()
fi

readonly OS_NAME=$(pcregrep -o1 '^NAME="(.*)"' /etc/os-release)
if [[ $OS_NAME != "Red Hat Enterprise Linux Server" && $OS_NAME != "CentOS Linux" ]]; then
  # shellcheck disable=SC2016
  echo 'WARNING: YMMV. This script is designed for RHEL or CentOS only. It might still work if `yum` is used.'
fi

DEFAULT_OWNER_USER="jenkins"
declare -a safe_update_options
# If a character is followed by a colon, the option is expected to have an argument
while getopts e:km:u:g:o:vh OPT; do
  case "$OPT" in
    e)
      exclude_dirs+=("$OPTARG")
      ;;
    k)
      if [[ $OS_NAME != "CentOS Linux" ]]; then
        echo "Kernel update is supported on CentOS only"
        exit 1
      fi
      readonly KERNEL_UPDATE=true
      ;;
    m)
      readonly NOTIFICATION_ADDRESS="$OPTARG"
      ;&
    m | u | g)
      # Pass-through options
      # shellcheck disable=SC2206 # no need to quote `$OPT`
      safe_update_options+=(-$OPT "$OPTARG")
      ;;
    o)
      DEFAULT_OWNER_USER="$OPTARG"
      DEFAULT_OWNER_GROUP=$(id --group --name "${DEFAULT_OWNER_USER}")
      declare -rx DEFAULT_OWNER_GROUP
      ;;
    v)
      set -x
      ;;
    *) # -h or `?`: an unknown option
      usage
      ;;
  esac
done
#shift $((OPTIND - 1))
declare -rx DEFAULT_OWNER_USER

#Process positional parameters
#[[ $1 == "" ]] && usage

if (( ${#exclude_dirs[@]} > 0 )); then
  printf -v FIND_EXCLUDE_DIR_OPTION -- '-not -path *%s/* ' "${exclude_dirs[@]}"
  export FIND_EXCLUDE_DIR_OPTION
fi

# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)
declare -rx ABSOLUTE_SCRIPT_DIR

echo
echo "harden-and-update.sh> running under ${USER}@${HOSTNAME} in ${PWD} \n"

if ! command -v pcregrep > /dev/null; then
  echo "Please install pcregrep"
  exit 1
fi

BACKUP_DIR=$(date "+%F-%H-%M-%S").bak
declare -rx BACKUP_DIR

MIN_NON_SYSTEM_UID=$(pcregrep -o1 '^UID_MIN\s+(\d+)' /etc/login.defs)
declare -rx MIN_NON_SYSTEM_UID
echo "Regular user UIDs start at $MIN_NON_SYSTEM_UID (per /etc/login.defs)"

# Source and export all functions to make them available to all check scripts
for function_script in "$SCRIPT_DIR"/functions/*.sh; do
  # shellcheck source=functions/*.sh
  source "$function_script"
done

echo -e "Executing checks...\n"
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

# TODO Implement Red Hat 7 kernel update per https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/kernel_administration_guide/ch-manually_upgrading_the_kernel
if [[ $KERNEL_UPDATE ]]; then # Install an updated kernel package if available
  echo -e "\nChecking for kernel updates"

  installed_kernel_full_version=$(uname -r)
  installed_kernel_version=${installed_kernel_full_version%%-*}

  if [[ $OS_NAME == "CentOS Linux" ]]; then
    # Pre-requisite: ELRepo repository must be installed
    # `kernel-lt`: Long Term Support (LTS) version, `kernel-ml`: the mainline version
    # TBD `python-perf` package might be needed
    yum --enablerepo=elrepo-kernel install -y kernel-lt

    kernel_package_version=$(rpm --query --queryformat '%{VERSION}' kernel-lt)
  fi

  #kernel_package_version=$(rpm --query --last kernel-lt | head -1 | pcregrep -o1 'kernel-lt-([^-]*)')
  set +e
  vercomp "${installed_kernel_version}" "${kernel_package_version}"
  # 2: installed_kernel_version < kernel_package_version
  declare -i comparison_result=$?
  set -e
  if ((comparison_result < 2)); then
    readonly KERNEL_UPDATE_MESSAGE="The kernel version is up to date: v${installed_kernel_version}"

    if [[ $NOTIFICATION_ADDRESS ]]; then
      echo "$KERNEL_UPDATE_MESSAGE" | mailx -S smtp=localhost -s "Hardening: kernel check" "$NOTIFICATION_ADDRESS"
    fi
  else
    readonly KERNEL_UPDATE_MESSAGE="Kernel update: from v${installed_kernel_version} to v${kernel_package_version}"
    readonly KERNEL_UPDATE_AVAILABLE=true
    if [[ $OS_NAME == "CentOS Linux" ]]; then
      echo "Check FAILED, correcting ..."
      echo "___SET___"

      # Keep 2 kernels including the current one
      package-cleanup -y --oldkernels --count=2

      grub2-set-default 0
      backup /boot/grub2/grub.cfg
      grub2-mkconfig -o /boot/grub2/grub.cfg
    fi
  fi
  echo "$KERNEL_UPDATE_MESSAGE"
fi

if yum list installed jenkins &>/dev/null; then
  if yum check-update jenkins; then
    echo -e "\nJenkins is up to date"
  else
    echo -e "\nJenkins update is available"

    # When Jenkins is not installed, this is false
    readonly JENKINS_UPDATE_AVAILABLE=true
  fi
fi

if [[ ${KERNEL_UPDATE_AVAILABLE} == true || ${JENKINS_UPDATE_AVAILABLE} == true ]]; then
  if [[ ${KERNEL_UPDATE_AVAILABLE} == true ]]; then
    echo "Scheduling a safe reboot for the kernel update"
    safe_update_options+=(-r "'$KERNEL_UPDATE_MESSAGE'")
  fi
  if [[ $JENKINS_UPDATE_AVAILABLE == true ]]; then
    echo "Scheduling a safe Jenkins update"
    safe_update_options+=(-j)
  fi
  if [[ $PGDATABASE ]]; then
    safe_update_options+=(-d "$PGDATABASE")
  fi
  echo "Safe update/reboot options: ${safe_update_options[*]}"

  readonly CRON_JOB="${ABSOLUTE_SCRIPT_DIR}/update-reboot-safely.sh"
  readonly CRON_LOG="${PWD}/update-reboot-safely.log"
  # Schedule safe reboot or update and let the current script finish successfully
  enable_cron_job "${safe_update_options[@]}"
fi

rm -- *.done

exit 0
