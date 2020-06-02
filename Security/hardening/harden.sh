#!/usr/bin/env bash

usage() {
  cat << 'HEREDOC'
NAME

    harden -- harden a machine semi-automatically per included hardening checks

SYNOPSIS

    sudo harden-CentOS.sh [-k] [-m email] [-e excluded_dir] [-e ...] [-u unsafe_user] [-g unsafe_group] system_user
    harden-CentOS.sh-h: display this help

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

echo -e '### System Access, Authentication and Authorization ###\n\n'

echo -e '### Configure cron and anacron ###\n\n'

echo "6.1.1 Enable anacron Daemon"
echo "___CHECK___"
rpm -q cronie-anacron
if [[ "$(rpm -q cronie-anacron)" != "package cronie-anacron is not installed" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  yum install cronie-anacron
fi
printf "\n\n"

echo "6.1.2 Enable crond Daemon"
echo "___CHECK___"
systemctl is-enabled crond
if [[ "$(systemctl is-enabled crond)" == "enabled" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  systemctl enable crond
fi
printf "\n\n"

echo "6.1.3 Set User/Group Owner and Permission on /etc/anacrontab"
echo "___CHECK___"
stat -L -c "%a %u %g" /etc/anacrontab | egrep ".00 0 0"
if [[ "$(stat -L -c "%a %u %g" /etc/anacrontab | egrep ".00 0 0" | wc -l)" == 1 ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  chown root:root /etc/anacrontab
  chmod og-rwx /etc/anacrontab
fi
printf "\n\n"

echo "6.1.4 Set User/Group Owner and Permission on /etc/crontab"
echo "___CHECK___"
stat -L -c "%a %u %g" /etc/crontab | egrep ".00 0 0"
if [[ "$(stat -L -c "%a %u %g" /etc/crontab | egrep ".00 0 0" | wc -l)" == 1 ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  chown root:root /etc/crontab
  chmod og-rwx /etc/crontab
fi
printf "\n\n"

echo "6.1.5 Set User/Group Owner and Permission on /etc/cron.hourly"
echo "___CHECK___"
stat -L -c "%a %u %g" /etc/cron.hourly | egrep ".00 0 0"
if [[ "$(stat -L -c "%a %u %g" /etc/cron.hourly | egrep ".00 0 0" | wc -l)" == 1 ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  chown root:root /etc/cron.hourly
  chmod og-rwx /etc/cron.hourly
fi
printf "\n\n"

echo "6.1.6 Set User/Group Owner and Permission on /etc/cron.daily"
echo "___CHECK___"
stat -L -c "%a %u %g" /etc/cron.daily | egrep ".00 0 0"
if [[ "$(stat -L -c "%a %u %g" /etc/cron.daily | egrep ".00 0 0" | wc -l)" == 1 ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  chown root:root /etc/cron.daily
  chmod og-rwx /etc/cron.daily
fi
printf "\n\n"

echo "6.1.7 Set User/Group Owner and Permission on /etc/cron.weekly"
echo "___CHECK___"
stat -L -c "%a %u %g" /etc/cron.weekly | egrep ".00 0 0"
if [[ "$(stat -L -c "%a %u %g" /etc/cron.weekly | egrep ".00 0 0" | wc -l)" == 1 ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  chown root:root /etc/cron.weekly
  chmod og-rwx /etc/cron.weekly
fi
printf "\n\n"

echo "6.1.8 Set User/Group Owner and Permission on /etc/cron.monthly"
echo "___CHECK___"
stat -L -c "%a %u %g" /etc/cron.monthly | egrep ".00 0 0"
if [[ "$(stat -L -c "%a %u %g" /etc/cron.monthly | egrep ".00 0 0" | wc -l)" == 1 ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  chown root:root /etc/cron.monthly
  chmod og-rwx /etc/cron.monthly
fi
printf "\n\n"

echo "6.1.9 Set User/Group Owner and Permission on /etc/cron.d"
echo "___CHECK___"
if stat -L -c "%a %u %g" /etc/cron.d | egrep ".00 0 0"; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  chown root:root /etc/cron.d
  chmod og-rwx /etc/cron.d
fi
printf "\n\n"

echo "6.1.10 Restrict at Daemon"
echo "___CHECK 1/2___"
if [[ ! -f /etc/at.deny ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  rm /etc/at.deny
fi
echo "___CHECK 2/2___"
stat -L -c "%a %u %g" /etc/at.allow | egrep ".00 0 0"
if [[ "$(stat -L -c "%a %u %g" /etc/at.allow | egrep ".00 0 0" | wc -l)" == 1 ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  touch /etc/at.allow
  chown root:root /etc/at.allow
  chmod og-rwx /etc/at.allow
fi
printf "\n\n"

echo "6.1.11 Restrict at/cron to Authorized Users"
echo "___CHECK 1/2___"
if [[ ! -f /etc/cron.deny ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  rm /etc/cron.deny
fi
echo "___CHECK 2/2___"
stat -L -c "%a %u %g" /etc/cron.allow | egrep ".00 0 0"
if [[ "$(stat -L -c "%a %u %g" /etc/cron.allow | egrep ".00 0 0" | wc -l)" == 1 ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  touch /etc/cron.allow
  chown root:root /etc/cron.allow
  chmod og-rwx /etc/cron.allow
fi
printf "\n\n"

echo -e '### Configure SSH  ###\n\n'

echo "6.2.1 Set SSH Protocol to 2 (default)"
echo "____CHECK____"
if ! grep '^Protocol.*1' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, SET IN ACTION "
  echo "____SET____"
  sed --in-place --regexp-extended '/^Protocol.*1/d' /etc/ssh/sshd_config
fi
printf "\n\n"

echo "6.2.2 Set LogLevel to INFO (default)"
echo "____CHECK____"
if ! grep -E '^LogLevel [^I]' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, SET IN ACTION "
  echo "____SET____"
  sed --in-place --regexp-extended '/^LogLevel [^I]/d' /etc/ssh/sshd_config
fi
printf "\n\n"

echo "6.2.3 Set Permissions on /etc/ssh/sshd_config"
echo "____CHECK____"
ls -l /etc/ssh/sshd_config
chown root:root /etc/ssh/sshd_config
access_privileges_line=$(ls -l /etc/ssh/sshd_config)
access_privileges=${access_privileges_line:0:10}
if [[ "$access_privileges" == "-rw-------" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  echo "Access mode is changing to 600"
  chmod 600 /etc/ssh/sshd_config
fi
printf "\n\n"

# X11 is needed to run DataGrip on server(s)
#echo "6.2.4 Disable X11 Forwarding"
#printf "\n\n"

echo "6.2.5 Set SSH MaxAuth Tries to 4 or less"
echo "____CHECK____"
declare -i value
# value = 0 when not found
value=$(pcregrep --only-matching=1 '^MaxAuthTries (.*)' /etc/ssh/sshd_config) || :
if ((value > 0 && value <= 4)); then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config '#*MaxAuthTries ' 'MaxAuthTries 4'
fi
printf "\n\n"

echo "6.2.6 Set SSH IgnoreRhosts to yes (default)"
echo "____CHECK____"
if ! grep -E '^IgnoreRhosts no' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config 'IgnoreRhosts ' 'IgnoreRhosts yes'
fi
printf "\n\n"

echo "6.2.7 Set SSH HostbasedAuthentication to no (default)"
if ! grep -E '^HostbasedAuthentication yes' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config 'HostbasedAuthentication ' 'HostbasedAuthentication no'
fi
printf "\n\n"

echo "6.2.8 Disable SSH Root Login"
echo "____CHECK____"
if grep -E '^PermitRootLogin no' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config '#*PermitRootLogin ' 'PermitRootLogin no'
fi
printf "\n\n"

echo "6.2.9 Set SSH PermitEmptyPasswords to no (default)"
echo "____CHECK____"
if ! grep -E '^PermitEmptyPasswords yes' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config 'PermitEmptyPasswords ' 'PermitEmptyPasswords no'
fi
printf "\n\n"

echo "6.2.10 Set SSH PermitUserEnvironment to no (default)"
echo "____CHECK____"
if ! grep -E '^PermitUserEnvironment yes' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config 'PermitUserEnvironment ' 'PermitUserEnvironment no'
fi
printf "\n\n"

echo "6.2.11 Use Only Approved Ciphers in Counter Mode"
echo "____CHECK____"
if grep -E '^Ciphers aes128-ctr,aes192-ctr,aes256-ctr' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config '#*Ciphers ' 'Ciphers aes128-ctr,aes192-ctr,aes256-ctr'
fi
printf "\n\n"

echo "6.2.12 Set SSH Idle Timeout"
echo "____CHECK 1/2____"
if grep -E '^ClientAliveInterval 3600' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config '#*ClientAliveInterval ' 'ClientAliveInterval 3600'
fi
echo "____CHECK 2/2____"
if grep -E '^ClientAliveCountMax 0' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert /etc/ssh/sshd_config '#*ClientAliveCountMax ' 'ClientAliveCountMax 0'
fi
printf "\n\n"

echo "6.2.13 Limit Access via SSH"
if grep -E '^AllowGroups' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  cat << HEREDOC
Check FAILED, correct this!
Add AllowGroups to /etc/ssh/sshd_config
HEREDOC
  exit 1
fi
printf "\n\n"

echo "6.2.14 Set SSH Banner"
echo "____CHECK____"
if grep -E '^Banner' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  if [[ ! -f /etc/issue.net ]]; then
    cat > /etc/issue.net << 'HEREDOC'
********************************************************************
*                                                                  *
* This system is for the use of authorized users only.  Usage of   *
* this system may be monitored and recorded by system personnel.   *
*                                                                  *
* Anyone using this system expressly consents to such monitoring   *
* and is advised that if such monitoring reveals possible          *
* evidence of criminal activity, system personnel may provide the  *
* evidence from such monitoring to law enforcement officials.      *
*                                                                  *
********************************************************************
HEREDOC
  fi
  upsert /etc/ssh/sshd_config '#*Banner ' 'Banner /etc/issue.net'
  systemctl restart sshd
fi
printf "\n\n"

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

# FIXME Implement Check can not be performed. Need further investigation.
#echo "9.2.7 Check Permissions on User Home Directories"
#printf "\n\n"

echo '9.2.8 Check User "Dot" File Permissions'
echo -e "____CHECK____: List of group or world-writable user "dot" files and directories"
for dir in $(cat /etc/passwd | egrep -v '(root|sync|halt|shutdown)' | awk -F: '($7 != "/sbin/nologin") { print $6 }'); do
  for file in $dir/.[A-Za-z0-9]*; do
    if [ ! -h "$file" -a -f "$file" ]; then
      fileperm=$(ls -ld $file | cut -f1 -d" ")
      if [ $(echo $fileperm | cut -c6) != "-" ]; then
        echo "Group Write permission set on file $file"
        echo "Check FAILED, correct this!"
        exit 1
      fi
      if [ $(echo $fileperm | cut -c9) != "-" ]; then
        echo "Other Write permission set on file $file"
        echo "Check FAILED, correct this!"
        exit 1
      fi
    fi
  done
done

echo "9.2.9 Check Permissions on User .netrc Files"
echo -e "____CHECK____: List of problematic permissions on User .netrc Files:"
for dir in $(cat /etc/passwd | egrep -v '(root|sync|halt|shutdown)' \
  | awk -F: '($7 != "/sbin/nologin") { print $6 }'); do
  for file in $dir/.netrc; do
    if [ ! -h "$file" -a -f "$file" ]; then
      fileperm=$(ls -ld $file | cut -f1 -d" ")
      if [ $(echo $fileperm | cut -c5) != "-" ]; then
        echo "Group Read set on $file"
        echo "Check FAILED, correct this!"
        exit 1
      fi
      if [ $(echo $fileperm | cut -c6) != "-" ]; then
        echo "Group Write set on $file"
        echo "Check FAILED, correct this!"
        exit 1
      fi
      if [ $(echo $fileperm | cut -c7) != "-" ]; then
        echo "Group Execute set on $file"
        echo "Check FAILED, correct this!"
        exit 1
      fi
      if [ $(echo $fileperm | cut -c8) != "-" ]; then
        echo "Other Read set on $file"
        echo "Check FAILED, correct this!"
        exit 1
      fi
      if [ $(echo $fileperm | cut -c9) != "-" ]; then
        echo "Other Write set on $file"
        echo "Check FAILED, correct this!"
        exit 1
      fi
      if [ $(echo $fileperm | cut -c10) != "-" ]; then
        echo "Other Execute set on $file"
        echo "Check FAILED, correct this!"
        exit 1
      fi
    fi
  done
done
echo "Check PASSED"
printf "\n\n"

echo "9.2.10 Check for Presence of User .rhosts Files"
echo -e "____CHECK____: List of  Presence of User .rhosts Files:"
for d in $(cat /etc/passwd | egrep -v '(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin") { print $6 }'); do
  for file in ${d}/.rhosts; do
    if [ ! -h "$file" -a -f "$file" ]; then
      cat << HEREDOC
Check FAILED, correct this!
.rhosts file in $d
While no .rhosts files are shipped with OS, users can easily create them. This action is only meaningful if .rhosts
support is permitted in the PAM config. Even though the .rhosts files are ineffective if support is disabled in the PAM
config, they may have been brought over from other systems and could contain information useful to an attacker for those
other systems. If any users have .rhosts files determine why they have them.
HEREDOC
      exit 1
    fi
  done
done
echo "Check PASSED"
printf "\n\n"

echo "9.2.11 Check Groups in /etc/passwd"
echo -e "____CHECK____"
for group in $(cut -s -d: -f4 /etc/passwd | sort -u); do
  if ! grep -q -P "^.*?:x:$group:" /etc/group; then
    echo "Group $group is referenced by /etc/passwd but does not exist in /etc/group"
    echo "Check FAILED, correct this!"
    exit 1
  fi
done
echo "Check PASSED"
printf "\n\n"

echo "9.2.13 Check User Home Directory Ownership for non-system users"
echo -e "____CHECK____"
while IFS=: read user enc_passwd uid gid full_name home shell; do
  if [[ ${uid} -ge ${MIN_NON_SYSTEM_UID} && -d "$home" && ${user} != "nfsnobody" ]]; then
    owner=$(stat -L -c "%U" "$home")
    if [[ "$owner" != "$user" ]]; then
      cat << HEREDOC
Check FAILED, correct this!
The home directory ($home) of user $user is owned by different owner: $owner.
Change the ownership of home directories to a correct user.
HEREDOC
      exit 1
    fi
  fi
done < /etc/passwd
echo "Check PASSED"
printf "\n\n"

echo "9.2.14 Check for Duplicate UIDs"
echo -e "____CHECK____"
cat /etc/passwd | cut -f3 -d":" | sort -n | uniq -c | while read x; do
  [[ -z "${x}" ]] && break
  set - ${x}
  if [[ "$1" -gt "1" ]]; then
    echo "Check FAILED, correct this!"
    echo "Duplicate UIDs $2:"
    gawk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd | xargs
    exit 1
  fi
done
echo -e "\nCheck PASSED: No Duplicate UIDs"
printf "\n\n"

echo "9.2.15 Check for Duplicate GIDs"
echo -e "____CHECK____"
cat /etc/group | cut -f3 -d":" | sort -n | uniq -c | while read x; do
  [[ -z "${x}" ]] && break
  set - ${x}
  if [[ "$1" -gt "1" ]]; then
    echo "Check FAILED, correct this!"
    echo "Duplicate GIDs $2:"
    gawk -F: '($3 == n) { print $1 }' n=$2 /etc/group | xargs
    exit 1
  fi
done
echo -e "\nCheck PASSED: No Duplicate GIDs"
printf "\n\n"

echo "9.2.16 Check for Duplicate User Names"
echo -e "____CHECK____"
cat /etc/passwd | cut -f1 -d":" | sort -n | uniq -c | while read x; do
  [[ -z "${x}" ]] && break
  set - ${x}
  if [[ "$1" -gt "1" ]]; then
    echo "Check FAILED, correct this!"
    echo "Duplicate User Name $2:}"
    gawk -F: '($1 == n) { print $3 }' n=$2 /etc/passwd | xargs
    exit 1
  fi
done
echo -e "\nCheck PASSED: No Duplicate User Name"
printf "\n\n"

echo "9.2.17 Check for Duplicate Group Names"
echo -e "____CHECK____"
cat /etc/group | cut -f1 -d":" | sort -n | uniq -c | while read x; do
  [[ -z "${x}" ]] && break
  set - ${x}
  if [[ "$1" -gt "1" ]]; then
    echo "Check FAILED, correct this!"
    echo "Duplicate Group Name $2:"
    gawk -F: '($1 == n) { print $3 }' n=$2 /etc/group | xargs
    exit 1
  fi
done
echo -e "\nCheck PASSED: No Duplicate Group Name"
printf "\n\n"

echo "9.2.18 Check for Presence of User .netrc Files"
echo -e "____CHECK____"
for dir in $(cat /etc/passwd | awk -F: '{ print $6 }'); do
  if [ ! -h "$dir/.netrc" -a -f "$dir/.netrc" ]; then
    echo "Check FAILED, correct this!"
    echo ".netrc file $dir/.netrc exists"
    exit 1
  fi
done
echo -e "\nCheck PASSED: No Presence of User .netrc Files"
printf "\n\n"

echo "9.2.19 Check for Presence of User .forward Files"
echo -e "____CHECK____"
for dir in $(cat /etc/passwd | awk -F: '{ print $6 }'); do
  if [ ! -h "$dir/.forward" -a -f "$dir/.forward" ]; then
    echo "Check FAILED, correct this!"
    echo ".forward file $dir/.forward exists"
    exit 1
  fi
done
echo -e "\nCheck PASSED: No Presence of User .forward Files"
printf "\n\n"
#endregion

if [[ ${KERNEL_UPDATE_MESSAGE} || ${JENKINS_UPDATE} == true ]]; then
  readonly LOG=${ABSOLUTE_SCRIPT_DIR}/safe_updates.log
  [[ ${KERNEL_UPDATE_MESSAGE} ]] && safe_update_options="-r "$KERNEL_UPDATE_MESSAGE" $safe_update_options"
  # shellcheck disable=SC2086 # Expanding `$safe_update_options` into multiple parameters
  "$SCRIPT_DIR/safe_updates.sh" $safe_update_options >> "$LOG"
fi

exit 0
