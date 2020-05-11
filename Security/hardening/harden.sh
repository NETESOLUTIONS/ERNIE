#!/usr/bin/env bash
if [[ $# -lt 2 || "$1" == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    harden.sh -- harden a CentOS machine semi-automatically

SYNOPSIS

    sudo harden.sh system_user end_user_group [excluded_dir] ...
    harden.sh -h: display this help

DESCRIPTION

    The script automatically makes changes that it can to harden a CentOS server per the Baseline Security Configuration
    derived from the Center for Internet Security (CIS) Security Benchmarks.
    The script would fail on the first problem that needs to be fixed manually. Correct the problem and re-run.

    WARNING: it updates Linux kernel and all packages to their latest versions. In the case of kernel update, it would
    reboot the server. Re-run the script after the reboot.

    The following options are available:

    system_user     User account to assign ownership of unowned files and directories.
                         The primary group of that user account will be used as group owner.
                    Processes owned by this user are checked to determine a quiet period for reboot.

    end_user_group  Processed owned by this group are checked to determine a quiet period for reboot.

    excluded_dir    Directory excluded from the ownership and system executables check.
                    This is needed for mapped Docker container dirs. The Docker home is excluded automatically.

EXAMPLES

    sudo ./harden.sh pardi_admin pardiusers /pardidata1/upsource
HEREDOC
  exit 1
fi

readonly MIN_NON_SYSTEM_UID=$(pcregrep -o1 '^UID_MIN\s+(\d+)' /etc/login.defs)

set -e
set -o pipefail

readonly SYSTEM_USER=$1
readonly DEFAULT_OWNER_GROUP=$(id --group --name ${SYSTEM_USER})
shift
readonly END_USER_GROUP=$1
shift

readonly DOCKER_HOME=$(docker info 2>/dev/null | pcregrep -o1 'Docker Root Dir: (.+)')
[[ ${DOCKER_HOME} ]] && EXCLUDE_DIRS="-not -path *${DOCKER_HOME}/*"
while (( $# > 0 )); do
  [[ ${EXCLUDE_DIRS} ]] && EXCLUDE_DIRS="$EXCLUDE_DIRS "
  EXCLUDE_DIRS="${EXCLUDE_DIRS}-not -path *$1/*"
  shift
done
readonly EXCLUDE_DIRS

# Get a script directory, same as by $(dirname $0)
readonly SCRIPT_DIR=${0%/*}
cd "$SCRIPT_DIR"

echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

# TODO Many checks are executed twice. Refactor to execute once and capture stdout.

for f in functions/*.sh; do
  source "$f"
done

# region Baseline Configuration items: 1-100.

for f in checks/*.sh; do
  source "$f"
done

echo -e '## Filesystem Configuration ##\n\n'

echo '1.1.1 Create separate partition for /tmp'
echo 'Verify that there is a /tmp file partition in the /etc/fstab file'
if [[ "$(grep "[[:space:]]/tmp[[:space:]]" /etc/fstab)" != "" ]]; then
  echo "Check PASSED"
else
  echo "Partitioning"
  dd if=/dev/zero of=/tmp/tmp_fs seek=512 count=512 bs=1M
  mkfs.ext3 -F /tmp/tmp_fs
  cat >> /etc/fstab << HEREDOC
/tmp/tmp_fs					/tmp		ext3	noexec,nosuid,nodev,loop 1 1
/tmp						/var/tmp	none	bind
HEREDOC
  chmod a+wt /tmp
  mount /tmp
fi
printf "\n\n"

echo '1.1.2 Set nodev option for /tmp Partition'
if [[ "$(grep /tmp /etc/fstab |grep nodev)" != "" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correct this!"
fi
printf "\n\n"

echo '1.1.3 Set nosuid option for /tmp Partition'
if [[ "$(grep /tmp /etc/fstab |grep nosuid)" != "" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correct this!"
fi
printf "\n\n"

echo '1.1.4 Set noexec option for /tmp Partition'
if [[ "$(grep /tmp /etc/fstab |grep nosuid)" != "" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correct this!"
fi
printf "\n\n"

# TBD DISABLED
#echo '1.1.17 Set Sticky Bit on All world-writable directories'

echo -e '## Configure Software Updates ##\n\n'

echo "1.2.1 Verify CentOS GPG Key is Installed"
echo "___CHECK___"
rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey
matches=$(rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey)
b='gpg(CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>) gpg(OpenLogic Inc (OpenLogic RPM Development) <support@openlogic.com>)'
if [[ "$(echo $matches)" == *"$b"* ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
fi
printf "\n\n"

echo "1.2.2 Verify that gpgcheck is Globally Activated"
echo "___CHECK___"
grep gpgcheck /etc/yum.conf
if [[ "$(grep gpgcheck /etc/yum.conf)" = "gpgcheck=1" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/gpgcheck=/d' /etc/yum.conf
  echo "gpgcheck=1" >> /etc/yum.conf
fi
printf "\n\n"

echo "1.2.3 Obtain Software Package Updates with yum"
echo "___CHECK___"
#yum check-update
if yum check-update --exclude=jenkins; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  ACCEPT_EULA=Y yum -y update --exclude=jenkins
fi
printf "\n\n"

# TBD DISABLED Files get modified for different reasons. It's unclear what could be done to fix a failure.

#echo "1.2.4 Verify Package Integrity Using RPM"
#echo "___CHECK___"
#rpm -qVa | awk '$2 != "c" { print $0 }' | tee /tmp/hardening-1.2.4.log
#if [[ -s /tmp/hardening-1.2.4.log ]]; then
#  echo "Check FAILED, correct this!"
#else
#  echo "Check PASSED"
#fi
#printf "\n\n"

echo -e '## Advanced Intrusion Detection Environment (AIDE) ##\n\n'

echo -e '## Configure SELinux ##\n\n'

echo -e '## Secure Boot Settings ##\n\n'

echo "1.5.1 Set User/Group Owner on the boot loader config"
echo "___CHECK___"
BOOT_CONFIG=/etc/grub2.cfg
if stat --dereference --format="%u %g" ${BOOT_CONFIG} | grep "0 0"; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  chown root:root ${BOOT_CONFIG}
fi
printf "\n\n"

echo "1.5.2 Set Permissions on the boot loader config"
echo "___CHECK___"
if stat --dereference --format="%a" ${BOOT_CONFIG} | grep ".00"; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  chmod og-rwx ${BOOT_CONFIG}
fi
printf "\n\n"

echo "1.5.3 Set Boot Loader Password"
echo "___CHECK___"
matches=$(grep "^password" ${BOOT_CONFIG}) || :
if [[ "$matches" == 'password --md5' || -z "$matches" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED"
  exit 1
#  echo "Check FAILED, correcting ..."
#  echo "___SET___"
#  sed -i '/^password/d' ${BOOT_CONFIG}
#  echo "password --md5 _[Encrypted Password]_" >>${BOOT_CONFIG}
fi
printf "\n\n"

echo "1.5.4 Require Authentication for Single-User Mode"
echo "___CHECK 1/2___"
if [[ "$(grep SINGLE /etc/sysconfig/init | tee /tmp/hardening-1.5.4.1.log)" == 'SINGLE=/sbin/sulogin' ]]; then
  echo "Check PASSED"
else
  cat /tmp/hardening-1.5.4.1.log
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  if [[ -s /tmp/hardening-1.5.4.1.log ]]; then
    sed -i "/SINGLE/s/sushell/sulogin/" /etc/sysconfig/init
  else
    echo "SINGLE=/sbin/sulogin" >> /etc/sysconfig/init
  fi
fi

echo "___CHECK 2/2___"
if [[ "$(grep PROMPT /etc/sysconfig/init | tee /tmp/hardening-1.5.4.2.log)" == 'PROMPT=no' ]]; then
  echo "Check PASSED"
else
  cat /tmp/hardening-1.5.4.2.log
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  if [[ -s /tmp/hardening-1.5.4.2.log ]]; then
    sed -i "/PROMPT/s/yes/no/" /etc/sysconfig/init
  else
    echo "PROMPT=no" >> /etc/sysconfig/init
  fi
fi
printf "\n\n"

echo "1.5.5 Disable Interactive Boot"
echo "___CHECK___"
grep "^PROMPT" /etc/sysconfig/init
if [[ "$(grep "^PROMPT" /etc/sysconfig/init)" == 'PROMPT=no' ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i "/PROMPT/s/yes/no/" /etc/sysconfig/init
fi
printf "\n\n"

echo -e '### Additional Process Hardening ###\n\n'

echo "1.6.1	Restrict Core Dumps"
echo "____CHECK 1/2____"
grep "hard core" /etc/security/limits.conf
if [[ "$(grep "hard core" /etc/security/limits.conf)" = "* hard core 0" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/* hard core/d' /etc/security/limits.conf
  echo "* hard core 0" >> /etc/security/limits.conf
fi

echo "____CHECK 2/2____"
sysctl fs.suid_dumpable
if [[ "$(sysctl fs.suid_dumpable)" = "fs.suid_dumpable = 0" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/fs.suid_dumpable = 0/d' /etc/sysctl.conf
  echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf
fi
printf "\n\n"

# TBD DISABLED
# Samet K.: Exec-shield is no longer an option in sysctl for kernel tuning in CENTOS7, it is by
# default on. This is a security measure, as documented in the RHEL 7 Security Guide.
# See http://centosfaq.org/centos/execshield-in-c6-or-c7-kernels/

#echo "1.6.2	Configure ExecShield"
#echo "____CHECK____"
#if [ "$(sysctl kernel.exec-shield)" = "kernel.exec-shield = 1" ]; then
#  echo "Check PASSED"
#else
#  echo "Check FAILED, correcting ..."
#  echo "____SET____"
#  sed -i '/kernel.exec-shield =/d' /etc/security/limits.conf
#  echo "kernel.exec-shield = 1" >> /etc/security/limits.conf
#fi
#printf "\n\n"

echo "1.6.3	Enable Randomized Virtual Memory Region Placement"
echo "____CHECK____"
sysctl kernel.randomize_va_space
if [[ "$(sysctl kernel.randomize_va_space)" = "kernel.randomize_va_space = 2" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/kernel.randomize_va_space =/d' /etc/security/limits.conf
  echo "kernel.randomize_va_space = 2" >> /etc/security/limits.conf
fi
printf "\n\n"

echo -e '## OS Services ##\n\n'

echo -e '### Remove Legacy Services ###\n\n'

uninstall 2.1.1 telnet-server
uninstall 2.1.2 telnet
uninstall 2.1.3 rsh-server
uninstall 2.1.4 rsh
uninstall 2.1.5 ypbind
uninstall 2.1.6 ypserv
uninstall 2.1.7 tftp
uninstall 2.1.8 tftp-server
uninstall 2.1.9 talk
uninstall 2.1.10 talk-server

echo "2.1.12 Disable chargen-dgram"
disable_sysv_service chargen-dgram

echo "2.1.13 Disable chargen-stream"
disable_sysv_service chargen-stream

echo "2.1.14 Disable daytime-dgram"
disable_sysv_service daytime-dgram

echo "2.1.15 Disable daytime-stream"
disable_sysv_service daytime-stream

echo "2.1.16 Disable echo-dgram"
disable_sysv_service echo-dgram

echo "2.1.17 Disable echo-stream"
disable_sysv_service echo-stream

echo "2.1.18 Disable tcpmux-server"
disable_sysv_service tcpmux-server

echo -e '### Special Purpose Services ###\n\n'

echo "3.1 Set Daemon umask"
echo "___CHECK___"
grep umask /etc/sysconfig/init
if [[ "$(grep umask /etc/sysconfig/init)" = "umask 027" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "umask 027" >> /etc/sysconfig/init
fi
printf "\n\n"

# DISABLED X WIndow is required in order to run DataGrip on server(s)
#echo "3.2 Remove X Window"
#echo "___CHECK 1/2___"
#systemctl get-default
#if [[ "$(systemctl get-default)" = "multi-user.target" ]]; then
#  echo "Check PASSED"
#else
#  echo "Check FAILED, correcting ..."
#  echo "___SET___"
#  systemctl set-default multi-user.target
#fi
#echo "___CHECK 2/2___"
#yum grouplist | grep "X Window System"
#if [[ "$(yum grouplist | grep 'X Window System')" = "" ]]; then
#  echo "Check PASSED"
#else
#  echo "Check FAILED, correcting ..."
#  echo "___SET___"
#  yum groupremove "X Window System"
#fi
#printf "\n\n"

echo "3.3 Disable Avahi Server"
echo "___CHECK___"
if chkconfig --list avahi-daemon | grep -E "[2-5]:on"; then
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/zeroconf/d' /etc/sysconfig/network
else
  echo "Check PASSED"
fi
printf "\n\n"

echo "3.4 Disable Print Server - CUPS"
disable_sysv_service cups

uninstall '3.5 Remove DHCP Server' dhcp

echo "3.6 Configure Network Time Protocol (NTP)"
echo "___CHECK 1/3___"
ls /etc | grep ntp.conf
if [[ "$(ls /etc | grep ntp.conf)" = "ntp.conf" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  yum -y install ntp
fi
echo "___CHECK 2/3___"
grep 'restrict default' /etc/ntp.conf
if [[ "$(grep 'restrict default' /etc/ntp.conf)" = "restrict default kod nomodify notrap nopeer noquery" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/restrict default/d' /etc/ntp.conf
  echo 'restrict default kod nomodify notrap nopeer noquery' >> /etc/ntp.conf
fi
echo "___CHECK 3/3___"
grep 'restrict -6 default' /etc/ntp.conf
if [[ "$(grep 'restrict -6 default' /etc/ntp.conf)" = "restrict -6 default kod nomodify notrap nopeer noquery" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/restrict -6 default/d' /etc/ntp.conf
  echo 'restrict -6 default kod nomodify notrap nopeer noquery' >> /etc/ntp.conf
fi
printf "\n\n"

uninstall '3.5 Remove LDAP ___CHECK 1/2___' openldap-servers
uninstall '___CHECK 2/2___' openldap-clients

echo "3.8 Disable NFS and RPC"
disable_sysv_service nfslock
disable_sysv_service rpcgssd
disable_sysv_service rpcbind
disable_sysv_service rpcidmapd
disable_sysv_service rpcsvcgssd

uninstall '3.9 Remove DNS Server' bind

uninstall '3.10 Remove FTP Server' vsftpd

uninstall '3.11 Remove HTTP Server' httpd

uninstall '3.12 Remove Dovecot (IMAP and POP3 services)' dovecot

uninstall '3.13 Remove Samba' samba

uninstall '3.14 Remove HTTP Proxy Server' squid

uninstall '3.15 Remove SNMP Server' net-snmp

echo "3.16 Configure Mail Transfer Agent for Local-Only Mode"
echo "___CHECK___"
netstat -an | grep LIST | grep ":25[[:space:]]" || :
matches=$(netstat -an | grep LIST | grep ":25[[:space:]]" || :)
b='tcp 0 0 127.0.0.1:25 0.0.0.0:* LISTEN'
if [[ "$(echo $matches)" == *"$b"* ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/^inet_interfaces/d' /etc/postfix/main.cf
  echo 'inet_interfaces = localhost' >> /etc/postfix/main.cf
fi
printf "\n\n"

echo -e '### Network Configuration and Firewalls ###\n\n'

# region TBD DISABLED until the decision on a firewall is made
#echo "4.0.7	Enable IPtables"
#echo "____CHECK____"
#chkconfig --list iptables
#if [ "$(chkconfig --list iptables)" = "iptables 0:off 1:off 2:on 3:on 4:on 5:on 6:off" ];
#  then     echo "Check PASSED"
#else
#  echo "Check FAILED, correcting ..."
#  echo "____SET____"
#  service iptables restart
#  chkconfig iptables on
#fi
#printf "\n\n"
#
#
#echo "4.0.8	Enable IP6tables"
#echo "____CHECK____"
#chkconfig --list ip6tables
#if [ "$(chkconfig --list ip6tables)" = "ip6tables 0:off 1:off 2:on 3:on 4:on 5:on 6:off" ];
#  then     echo "Check PASSED"
#else
#  echo "Check FAILED, correcting ..."
#  echo "____SET____"
#  service ip6tables restart
#  chkconfig ip6tables on
#fi
#printf "\n\n"
# endregion

echo -e '### Modify Network Parameters (Host Only) ###\n\n'

echo "4.1.1	Disable IP Forwarding"
echo "____CHECK____"
/sbin/sysctl net.ipv4.ip_forward
if [[ "$(/sbin/sysctl net.ipv4.ip_forward)" = "net.ipv4.ip_forward = 0" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/net.ipv4.ip_forward =/d' /etc/sysctl.conf
  echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
  /sbin/sysctl -w net.ipv4.ip_forward=0
  /sbin/sysctl -w net.ipv4.route.flush=1
fi
printf "\n\n"

echo "4.1.2	Disable Send Packet Redirects"
echo "____CHECK 1/2____"
/sbin/sysctl net.ipv4.conf.all.send_redirects
if [[ "$(/sbin/sysctl net.ipv4.conf.all.send_redirects)" = "net.ipv4.conf.all.send_redirects = 0" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/net.ipv4.conf.all.send_redirects =/d' /etc/sysctl.conf
  echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
  /sbin/sysctl -w net.ipv4.conf.all.send_redirects=0
  /sbin/sysctl -w net.ipv4.route.flush=1
fi
echo "____CHECK 2/2____"
/sbin/sysctl net.ipv4.conf.default.send_redirects
if [[ "$(/sbin/sysctl net.ipv4.conf.default.send_redirects)" = "net.ipv4.conf.default.send_redirects = 0" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/net.ipv4.conf.default.send_redirects =/d' /etc/sysctl.conf
  echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.conf
  /sbin/sysctl -w net.ipv4.conf.default.send_redirects=0
  /sbin/sysctl -w net.ipv4.route.flush=1
fi
printf "\n\n"

echo -e '### Modify Network Parameters (Host and Router) ###\n\n'

echo "4.2.1	Disable Source Routed Packet Acceptance"
echo "____CHECK 1/2____"
/sbin/sysctl net.ipv4.conf.all.accept_source_route
if [[ "$(/sbin/sysctl net.ipv4.conf.all.accept_source_route)" = "net.ipv4.conf.all.accept_source_route = 0" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/net.ipv4.conf.all.accept_source_route =/d' /etc/sysctl.conf
  echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.conf
  /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0
  /sbin/sysctl -w net.ipv4.route.flush=1
fi
echo "____CHECK 2/2____"
/sbin/sysctl net.ipv4.conf.default.accept_source_route
if [[ "$(/sbin/sysctl net.ipv4.conf.default.accept_source_route)" = \
    "net.ipv4.conf.default.accept_source_route = 0" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/net.ipv4.conf.default.accept_source_route =/d' /etc/sysctl.conf
  echo "/net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf
  /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0
  /sbin/sysctl -w net.ipv4.route.flush=1
fi
printf "\n\n"

echo "4.2.2	Disable ICMP Redirect Acceptance"
echo "____CHECK 1/2____"
/sbin/sysctl net.ipv4.conf.all.accept_redirects
if [[ "$(/sbin/sysctl net.ipv4.conf.all.accept_redirects)" = "net.ipv4.conf.all.accept_redirects = 0" ]];
  then     echo "Check PASSED";
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/net.ipv4.conf.all.accept_redirects =/d' /etc/sysctl.conf
  echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
  /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0
  /sbin/sysctl -w net.ipv4.route.flush=1
fi
echo "____CHECK 2/2____"
/sbin/sysctl net.ipv4.conf.default.accept_redirects
if [[ "$(/sbin/sysctl net.ipv4.conf.default.accept_redirects)" = "net.ipv4.conf.default.accept_redirects = 0" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/net.ipv4.conf.default.accept_redirects =/d' /etc/sysctl.conf
  echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
  /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0
  /sbin/sysctl -w net.ipv4.route.flush=1
fi
printf "\n\n"

echo "4.2.4	Log Suspicious Packets"
echo "____CHECK 1/2____"
/sbin/sysctl net.ipv4.conf.all.log_martians
if [[ "$(/sbin/sysctl net.ipv4.conf.all.log_martians)" = "net.ipv4.conf.all.log_martians = 1" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/net.ipv4.conf.all.log_martians =/d' /etc/sysctl.conf
  echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf
  /sbin/sysctl -w net.ipv4.conf.all.log_martians=1
  /sbin/sysctl -w net.ipv4.route.flush=1
fi
echo "____CHECK 2/2____"
/sbin/sysctl net.ipv4.conf.default.log_martians
if [[ "$(/sbin/sysctl net.ipv4.conf.default.log_martians)" = "net.ipv4.conf.default.log_martians = 1" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/net.ipv4.conf.default.log_martians =/d' /etc/sysctl.conf
  echo "net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.conf
  /sbin/sysctl -w net.ipv4.conf.default.log_martians=1
  /sbin/sysctl -w net.ipv4.route.flush=1
fi
printf "\n\n"

echo "4.2.5	Enable Ignore Broadcast Requests"
echo "____CHECK____"
/sbin/sysctl net.ipv4.icmp_echo_ignore_broadcasts
if [[ "$(/sbin/sysctl net.ipv4.icmp_echo_ignore_broadcasts)" = "net.ipv4.icmp_echo_ignore_broadcasts = 1" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/net.ipv4.icmp_echo_ignore_broadcasts =/d' /etc/sysctl.conf
  echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf
  /sbin/sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
  /sbin/sysctl -w net.ipv4.route.flush=1
fi
printf "\n\n"

echo "4.2.6	Enable Bad Error Message Protection"
echo "____CHECK____"
/sbin/sysctl net.ipv4.icmp_ignore_bogus_error_responses
if [[ "$(/sbin/sysctl net.ipv4.icmp_ignore_bogus_error_responses)" = \
    "net.ipv4.icmp_ignore_bogus_error_responses = 1" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/net.ipv4.icmp_ignore_bogus_error_responses =/d' /etc/sysctl.conf
  echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.conf
  /sbin/sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
  /sbin/sysctl -w net.ipv4.route.flush=1
fi
printf "\n\n"

echo "4.2.8	Enable TCP SYN Cookies"
echo "____CHECK____"
/sbin/sysctl net.ipv4.tcp_syncookies
if [[ "$(/sbin/sysctl net.ipv4.tcp_syncookies)" = "net.ipv4.tcp_syncookies = 1" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/net.ipv4.tcp_syncookies =/d' /etc/sysctl.conf
  echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
   /sbin/sysctl -w net.ipv4.tcp_syncookies=1
   /sbin/sysctl -w net.ipv4.route.flush=1
fi
printf "\n\n"

#echo "Section Header: Wireless Networking"
#printf "\n\n"
#
#echo "4.3.1	Deactivate Wireless Interfaces (Linux laptops)"
#printf "\n\n"

#echo "Section Header: Disable IPv6"
#printf "\n\n"

# Not required for this baseline configuration
#echo "4.4.2	Disable IPv6"
#printf "\n\n"

#echo "Section Header: Configure IPv6"
#printf "\n\n"
#
# Not required for this baseline configuration
#echo "4.4.1.1 Disable IPv6 Router Advertisements"
#printf "\n\n"

echo "4.4.1.2 Disable IPv6 Redirect Acceptance"
echo "____CHECK 1/2____"
/sbin/sysctl net.ipv6.conf.all.accept_redirects
if [[ "$(/sbin/sysctl net.ipv6.conf.all.accept_redirects)" = "net.ipv6.conf.all.accept_redirects = 0" ]]; then
   echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/net.ipv6.conf.all.accept_redirects =/d' /etc/sysctl.conf
  echo "net.ipv6.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
  /sbin/sysctl -w net.ipv6.conf.all.accept_redirects=0
  /sbin/sysctl -w net.ipv6.route.flush=1
fi
echo "____CHECK 2/2____"
/sbin/sysctl net.ipv6.conf.default.accept_redirects
if [[ "$(/sbin/sysctl net.ipv6.conf.default.accept_redirects)" = "net.ipv6.conf.default.accept_redirects = 0" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  sed -i '/net.ipv6.conf.default.accept_redirects =/d' /etc/sysctl.conf
  echo "net.ipv6.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
  /sbin/sysctl -w net.ipv6.conf.default.accept_redirects=0
  /sbin/sysctl -w net.ipv6.route.flush=1
fi
printf "\n\n"

echo -e '### Install TCP Wrappers ###\n\n'

echo "4.4.1.2 Disable IPv6 Redirect Acceptance"
echo "____CHECK 1/2____"
ldd /sbin/sshd | grep libwrap.so
output=$(ldd /sbin/sshd | grep libwrap.so)
output_size=${#output}
if [[ "$output_size" != "0" ]]; then
   echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  yum install tcp_wrappers
fi
echo "____CHECK 2/2____"
yum list tcp_wrappers | grep -w 'tcp_wrappers'
out2=$(yum list tcp_wrappers | grep -w 'tcp_wrappers')
out2_size=${#out2}
if [[ "$out2_size" != "0" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  yum install tcp_wrappers
fi
printf "\n\n"

echo "4.5.2 Create /etc/hosts.allow"
echo "Requirements are met by our external Firewalls, yet we can immediately revise this part upon request."
printf "\n\n"

echo "4.5.3 Verify Permissions on /etc/hosts.allow"
echo "____CHECK____"
ls -l /etc/hosts.allow
access_privileges_line=$(ls -l /etc/hosts.allow)
access_privileges=${access_privileges_line:0:10}
if [[ "$access_privileges" = "-rw-r--r--" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  echo "Access mode is changing to u=rw,go=r"
  chmod u=rw,go=r /etc/hosts.allow
fi
printf "\n\n"

echo "4.5.2 Create /etc/hosts.deny"
echo "Requirements are met by our external Firewalls, yet we can immediately revise this part upon request."
printf "\n\n"

echo "4.5.3 Verify Permissions on /etc/hosts.deny"
echo "____CHECK____"
ls -l /etc/hosts.deny
access_privileges_line=$(ls -l /etc/hosts.deny)
access_privileges=${access_privileges_line:0:10}
if [[ "$access_privileges" = "-rw-r--r--" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  echo "Access mode is changing to u=rw,go=r"
  chmod u=rw,go=r /etc/hosts.deny
fi
printf "\n\n"
# endregion

# region Baseline Configuration items: 101-199.
echo -e '### Uncommon Network Protocols ###\n\n'

echo "4.6.1 Disable DCCP"
echo "___CHECK___"
grep "install dccp /bin/true" /etc/modprobe.d/CIS.conf
if [[ "$(grep "install dccp /bin/true" /etc/modprobe.d/CIS.conf)" == "install dccp /bin/true" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "install dccp /bin/true" >> /etc/modprobe.d/CIS.conf
fi
printf "\n\n"

echo "4.6.2 Disable SCTP"
echo "___CHECK___"
grep "install sctp /bin/true" /etc/modprobe.d/CIS.conf
if [[ "$(grep "install sctp /bin/true" /etc/modprobe.d/CIS.conf)" == "install sctp /bin/true" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "install sctp /bin/true" >> /etc/modprobe.d/CIS.conf
fi
printf "\n\n"

echo "4.6.3 Disable RDS"
echo "___CHECK___"
grep "install rds /bin/true" /etc/modprobe.d/CIS.conf
if [[ "$(grep "install rds /bin/true" /etc/modprobe.d/CIS.conf)" == "install rds /bin/true" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "install rds /bin/true" >> /etc/modprobe.d/CIS.conf
fi
printf "\n\n"

echo "4.6.4 Disable TIPC"
echo "___CHECK___"
grep "install tipc /bin/true" /etc/modprobe.d/CIS.conf
if [[ "$(grep "install tipc /bin/true" /etc/modprobe.d/CIS.conf)" == "install tipc /bin/true" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "install tipc /bin/true" >> /etc/modprobe.d/CIS.conf
fi
printf "\n\n"

echo -e '### Logging and Auditing ###\n\n'

echo "5.0.3 Configure logrotate"
echo "___CHECK 1/6___"
grep "/var/log/cron" /etc/logrotate.d/syslog
if [[ "$(grep "/var/log/cron" /etc/logrotate.d/syslog)" == "/var/log/cron" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '1i/var/log/cron' /etc/logrotate.d/syslog
fi
echo "___CHECK 2/6___"
grep "/var/log/maillog" /etc/logrotate.d/syslog
if [[ "$(grep "/var/log/maillog" /etc/logrotate.d/syslog)" == "/var/log/maillog" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '1i/var/log/maillog' /etc/logrotate.d/syslog
fi
echo "___CHECK 3/6___"
grep "/var/log/messages" /etc/logrotate.d/syslog
if [[ "$(grep "/var/log/messages" /etc/logrotate.d/syslog)" == "/var/log/messages" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '1i/var/log/messages' /etc/logrotate.d/syslog
fi
echo "___CHECK 4/6___"
grep "/var/log/secure" /etc/logrotate.d/syslog
if [[ "$(grep "/var/log/secure" /etc/logrotate.d/syslog)" == "/var/log/secure" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '1i/var/log/secure' /etc/logrotate.d/syslog
fi
echo "___CHECK 5/6___"
grep "/var/log/boot.log" /etc/logrotate.d/syslog
if [[ "$(grep "/var/log/boot.log" /etc/logrotate.d/syslog)" == "/var/log/boot.log" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '1i/var/log/boot.log' /etc/logrotate.d/syslog
fi
echo "___CHECK 6/6___"
grep "/var/log/spooler" /etc/logrotate.d/syslog
if [[ "$(grep "/var/log/spooler" /etc/logrotate.d/syslog)" == "/var/log/spooler" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '1i/var/log/spooler' /etc/logrotate.d/syslog
fi
printf "\n\n"

echo -e '### Configure rsyslog ###\n\n'

echo "5.1.1 Install the rsyslog package"
echo "___CHECK___"
rpm -q rsyslog
if [[ "$(rpm -q rsyslog)" != "package rsyslog is not installed" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  yum install rsyslog
fi
printf "\n\n"

echo "5.1.2 Activate the rsyslog Service and disable syslog service if exists"
disable_sysv_service syslog
enable_sysv_service rsyslog

echo "& 5.1.3 Configure /etc/rsyslogg.conf; 5.1.4 Create and Set Permissions on rsyslog Log Files"
echo "___CHECK 1/5___"
grep "auth,user.* /var/log/messages" /etc/rsyslog.conf
if [[ "$(grep "auth,user.* /var/log/messages" /etc/rsyslog.conf)" == "auth,user.* /var/log/messages" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "auth,user.* /var/log/messages" >> /etc/rsyslog.conf
  pkill -HUP rsyslogd
  touch /var/log/messages
  chown root:root /var/log/messages
  chmod og-rwx /var/log/messages
fi
echo "___CHECK 2/5___"
grep "kern.* /var/log/kern.log" /etc/rsyslog.conf
if [[ "$(grep "kern.* /var/log/kern.log" /etc/rsyslog.conf)" == "kern.* /var/log/kern.log" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "kern.* /var/log/kern.log" >> /etc/rsyslog.conf
  pkill -HUP rsyslogd
  touch /var/log/kern.log
  chown root:root /var/log/kern.log
  chmod og-rwx /var/log/kern.log
fi
echo "___CHECK 3/5___"
grep "daemon.* /var/log/daemon.log" /etc/rsyslog.conf
if [[ "$(grep "daemon.* /var/log/daemon.log" /etc/rsyslog.conf)" == "daemon.* /var/log/daemon.log" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "daemon.* /var/log/daemon.log" >> /etc/rsyslog.conf
  pkill -HUP rsyslogd
  touch /var/log/daemon.log
  chown root:root /var/log/daemon.log
  chmod og-rwx /var/log/daemon.log
fi
echo "___CHECK 4/5___"
grep "syslog.* /var/log/syslog" /etc/rsyslog.conf
if [[ "$(grep "syslog.* /var/log/syslog" /etc/rsyslog.conf)" == "syslog.* /var/log/syslog" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "syslog.* /var/log/syslog" >> /etc/rsyslog.conf
  pkill -HUP rsyslogd
  touch /var/log/syslog
  chown root:root /var/log/syslog
  chmod og-rwx /var/log/syslog
fi
echo "___CHECK 5/5___"
grep "lpr,news,uucp,local0,local1,local2,local3,local4,local5,local6.* /var/log/unused.log" /etc/rsyslog.conf
if [[ "$(grep "lpr,news,uucp,local0,local1,local2,local3,local4,local5,local6.* /var/log/unused.log" /etc/rsyslog.conf)" == "lpr,news,uucp,local0,local1,local2,local3,local4,local5,local6.* /var/log/unused.log" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "lpr,news,uucp,local0,local1,local2,local3,local4,local5,local6.* /var/log/unused.log" >> /etc/rsyslog.conf
  pkill -HUP rsyslogd
  touch /var/log/unused.log
  chown root:root /var/log/unused.log
  chmod og-rwx /var/log/unused.log
fi
printf "\n\n"

echo "5.1.5 Configure rsyslog to Send Logs to a Remote Log Host"
echo "___CHECK___"
grep "^*.*[^I][^I]*@" /etc/rsyslog.conf
if [[ "$(grep "^*.*[^I][^I]*@" /etc/rsyslog.conf | wc -l)" != 0 ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "*.* @@remote-host:514" >> /etc/rsyslog.conf
  pkill -HUP rsyslogd
fi
printf "\n\n"

echo "5.1.6 Accept Remote rsyslog Messages Only on Designated Log Hosts"
echo "___CHECK 1/2___"
grep '^$ModLoad imtcp.so' /etc/rsyslog.conf
if [[ "$(grep '^$ModLoad imtcp.so' /etc/rsyslog.conf)" == "\$ModLoad imtcp.so" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "\$ModLoad imtcp.so" >> /etc/rsyslog.conf
  pkill -HUP rsyslogd
fi
echo "___CHECK 2/2___"
grep '^$InputTCPServerRun 514' /etc/rsyslog.conf
if [[ "$(grep '^$InputTCPServerRun 514' /etc/rsyslog.conf)" == "\$InputTCPServerRun 514" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "\$InputTCPServerRun 514" >> /etc/rsyslog.conf
  pkill -HUP rsyslogd
fi
printf "\n\n"

echo -e '### Configure System Accounting (auditd) ###\n\n'

echo -e '### Configure Data Retention ###\n\n'

echo -e '### System Access, Authentication and Authorization ###\n\n'

# DISABLED N/A for the Cloud hosting
#echo "6.0.4 Restrict root Login to System Console"
#cat /etc/securetty
#echo "NEEDS INSPECTION:"
#echo "Remove entries for any consoles that are not in a physically secure location."
#printf "\n\n"

echo "6.0.5 Restrict Access to the su Command"
if grep -E '^auth\s+required\s+pam_wheel.so\s+use_uid' /etc/pam.d/su; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert '#*auth\s+required\s+pam_wheel.so' 'auth\t\trequired\tpam_wheel.so use_uid' /etc/pam.d/su
fi
printf "\n\n"

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
if [[ "$access_privileges" = "-rw-------" ]]; then
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
if (( value > 0 && value <= 4 )); then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert '#*MaxAuthTries ' 'MaxAuthTries 4' /etc/ssh/sshd_config
fi
printf "\n\n"

echo "6.2.6 Set SSH IgnoreRhosts to yes (default)"
echo "____CHECK____"
if ! grep -E '^IgnoreRhosts no' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert 'IgnoreRhosts ' 'IgnoreRhosts yes' /etc/ssh/sshd_config
fi
printf "\n\n"

echo "6.2.7 Set SSH HostbasedAuthentication to no (default)"
if ! grep -E '^HostbasedAuthentication yes' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert 'HostbasedAuthentication ' 'HostbasedAuthentication no' /etc/ssh/sshd_config
fi
printf "\n\n"

echo "6.2.8 Disable SSH Root Login"
echo "____CHECK____"
if grep -E '^PermitRootLogin no' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert '#*PermitRootLogin ' 'PermitRootLogin no' /etc/ssh/sshd_config
fi
printf "\n\n"

echo "6.2.9 Set SSH PermitEmptyPasswords to no (default)"
echo "____CHECK____"
if ! grep -E '^PermitEmptyPasswords yes' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert 'PermitEmptyPasswords ' 'PermitEmptyPasswords no' /etc/ssh/sshd_config
fi
printf "\n\n"

echo "6.2.10 Set SSH PermitUserEnvironment to no (default)"
echo "____CHECK____"
if ! grep -E '^PermitUserEnvironment yes' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert 'PermitUserEnvironment ' 'PermitUserEnvironment no' /etc/ssh/sshd_config
fi
printf "\n\n"

echo "6.2.11 Use Only Approved Ciphers in Counter Mode"
echo "____CHECK____"
if grep -E '^Ciphers aes128-ctr,aes192-ctr,aes256-ctr' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert '#*Ciphers ' 'Ciphers aes128-ctr,aes192-ctr,aes256-ctr' /etc/ssh/sshd_config
fi
printf "\n\n"

echo "6.2.12 Set SSH Idle Timeout"
echo "____CHECK 1/2____"
if grep -E '^ClientAliveInterval 3600' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert '#*ClientAliveInterval ' 'ClientAliveInterval 3600' /etc/ssh/sshd_config
fi
echo "____CHECK 2/2____"
if grep -E '^ClientAliveCountMax 0' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  upsert '#*ClientAliveCountMax ' 'ClientAliveCountMax 0' /etc/ssh/sshd_config
fi
printf "\n\n"

echo "6.2.13 Limit Access via SSH"
if grep -E '^AllowGroups' /etc/ssh/sshd_config; then
  echo "Check PASSED"
else
  cat <<HEREDOC
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
    cat >/etc/issue.net <<'HEREDOC'
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
  upsert '#*Banner ' 'Banner /etc/issue.net' /etc/ssh/sshd_config
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
  upsert 'password\s+requisite\s+pam_pwquality.so' "${PWD_CREATION_REQUIREMENTS}" /etc/pam.d/system-auth-ac
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
if grep -E -v "^\+" /etc/passwd | \
    awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $3<500 && $7!="/sbin/nologin")'; then
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

echo -e '### Warning Banners ###\n\n'

echo "8.1 Set Warning Banner for Standard Login Services"
echo "___CHECK 1/3___"
ls /etc/motd
if [[ "$(ls /etc/motd)" == "/etc/motd" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  touch /etc/motd
  chown root:root /etc/motd
  chmod u=rw,go=r /etc/motd
fi
echo "___CHECK 2/3___"
ls /etc/issue
if [[ "$(ls /etc/issue)" == "/etc/issue" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue
  chown root:root /etc/issue
  chmod u=rw,go=r /etc/issue
fi
echo "___CHECK 3/3___"
ls /etc/issue.net
if [[ "$(ls /etc/issue.net)" == "/etc/issue.net" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue.net
  chown root:root /etc/issue.net
  chmod u=rw,go=r /etc/issue.net
fi
printf "\n\n"

echo "8.2 Remove OS Information from Login Warning Banners"
echo "___CHECK 1/3___"
if ! grep -E '(\\v|\\r|\\m|\\s)' /etc/motd; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/(\\v\|\\r\|\\m\|\\s)/d' /etc/motd
fi
echo "___CHECK 2/3___"
if ! grep -E  '(\\v|\\r|\\m|\\s)' /etc/issue; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/(\\v\|\\r\|\\m\|\\s)/d' /etc/issue
fi
echo "___CHECK 3/3___"
if ! grep -E '(\\v|\\r|\\m|\\s)' /etc/issue.net; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/(\\v\|\\r\|\\m\|\\s)/d' /etc/issue.net
fi
printf "\n\n"

echo "8.3 Set GNOME Warning Banner"
echo "___CHECK___"
echo "We do not need GNOME Display Manager, and we do not have /apps directory."
printf "\n\n"

echo -e '### System Maintenance ###\n\n'

echo -e '### Verify System File Permissions ###\n\n'

echo "9.1.2 Verify Permissions on /etc/passwd"
echo "____CHECK____"
ls -l /etc/passwd
access_privileges_line=$(ls -l /etc/passwd)
access_privileges=${access_privileges_line:0:10}
if [[ "$access_privileges" = "-rw-r--r--" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  echo "Access mode is changing to u=rw,go=r"
  chmod u=rw,go=r /etc/passwd
fi
printf "\n\n"

echo "9.1.3 Verify Permissions on /etc/shadow"
echo "____CHECK____"
ls -l /etc/shadow
access_privileges_line=$(ls -l /etc/shadow)
access_privileges=${access_privileges_line:0:10}
if [[ "$access_privileges" = "----------" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  echo "Access mode is changing to a="
  chmod a= /etc/shadow
fi
printf "\n\n"

echo "9.1.4 Verify Permissions on /etc/gshadow"
echo "____CHECK____"
ls -l /etc/gshadow
access_privileges_line=$(ls -l /etc/gshadow)
access_privileges=${access_privileges_line:0:10}
if [[ "$access_privileges" = "----------" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  echo "Access mode is changing to a="
  chmod a= /etc/gshadow
fi
printf "\n\n"

echo "9.1.5 Verify Permissions on /etc/group"
echo "____CHECK____"
ls -l /etc/group
access_privileges_line=$(ls -l /etc/group)
access_privileges=${access_privileges_line:0:10}
if [ "$access_privileges" = "-rw-r--r--" ];
  then    echo "Check PASSED";
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  echo "Access mode is changing to u=rw,go=r"
  chmod u=rw,go=r /etc/group
fi
printf "\n\n"

echo "9.1.6 Verify User/Group Ownership on /etc/passwd"
echo "____CHECK____"
ls -l /etc/passwd
is_root_root=$(ls -l /etc/passwd | egrep -w "root root")
#check the length if it nonzero, then success, otherwise failure.
if [[ "${#is_root_root}" != "0" ]];
  then    echo "Check PASSED";
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  echo "User/group Ownership is changing to root:root"
  chown root:root /etc/passwd
fi
printf "\n\n"

echo "9.1.7 Verify User/Group Ownership on /etc/shadow"
echo "____CHECK____"
ls -l /etc/shadow
is_root_root=$(ls -l /etc/shadow | egrep -w "root root")
#check the length if it nonzero, then success, otherwise failure.
if [[ "${#is_root_root}" != "0" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  echo "User/group Ownership is changing to root:root"
  chown root:root /etc/shadow
fi
printf "\n\n"

echo "9.1.8 Verify User/Group Ownership on /etc/gshadow"
echo "____CHECK____"
ls -l /etc/gshadow
is_root_root=$(ls -l /etc/gshadow | egrep -w "root root")
#check the length if it nonzero, then success, otherwise failure.
if [[ "${#is_root_root}" != "0" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  echo "User/group Ownership is changing to root:root"
  chown root:root /etc/gshadow
fi
printf "\n\n"

echo "9.1.9 Verify User/Group Ownership on /etc/group"
echo "____CHECK____"
ls -l /etc/group
is_root_root=$(ls -l /etc/group | egrep -w "root root")
#check the length if it nonzero, then success, otherwise failure.
if [[ "${#is_root_root}" != "0" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  echo "User/group Ownership is changing to root:root"
  chown root:root /etc/group
fi
printf "\n\n"

echo "9.1.10 Find World Writable Files"
echo "____CHECK____: List of World writables files below:"
output=$(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -0002)
if [[ -z ${output} ]]; then
  echo "Check PASSED : no World Writable file"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  echo "Removing write access for 'other' ..."
  for file in ${output};do
    chmod o-w ${file}
  done
fi
printf "\n\n"

echo "9.1.11 Find Un-owned Files and Directories + 9.1.12 Find Un-grouped Files and Directories"

echo "____CHECK____: List of Un-owned Files and Directories:"
rm -f ownership_issues.log
# -xdev Don't descend directories on other filesystems
df --local --output=target | tail -n +2 | xargs -I '{}' find '{}' ${EXCLUDE_DIRS} -xdev -type f \( -nouser -or -nogroup \) -ls |\
    while read inode blocks perms number_of_links_or_dirs owner group size month day time_or_year filename; do
  echo -e "$filename $owner $group $size $month $day $time_or_year" | tee -a ownership_issues.log
  chown ${SYSTEM_USER}:${DEFAULT_OWNER_GROUP} "$filename"
done
# df --local -P | awk {'if (NR!=1) print $6'}

if [[ ! -f ownership_issues.log ]]; then
  echo "Check PASSED : No Un-owned Files and Directories and no Un-grouped Files and Directories"
else
  echo "Check FAILED, corrected."
  echo "____SET____"
  echo "Assigned ownership to ${SYSTEM_USER}:${DEFAULT_OWNER_GROUP}"
  echo "WARNING: review ownership_issues.log for obsolete files that can be removed"
fi
printf "\n\n"

echo "9.1.13 Find SUID System Executables"
check_execs_with_special_permissions 4000 SUID

echo "9.1.14 Find SGID System Executables"
check_execs_with_special_permissions 2000 SGID

echo -e '### Review User and Group Settings ###\n\n'

echo "9.2.1 Ensure Password Fields are Not Empty"
failures=$(cat /etc/shadow | awk -F: '($2 == "" ) { print $1 " does not have a password "}')
if [[ -z "${failures}" ]]; then
  echo -e "\nCheck PASSED"
else
  echo "Check FAILED, correct this!"
  echo "PLEASE CHECK WHY FOLLOWING USERS HAVING PASSWORD STATUS NP HAVE NOT BEEN SET ANY PASSWORD"
  for user in $(awk -F ':' '{print $1}' /etc/passwd); do
    passwd -S ${user}
  done
  cat <<HEREDOC
Status (second column) legend:

PS  : Account has a usable password
LK  : User account is locked
L   : if the user account is locked (L)
NP  : Account has no password (NP)
P   : Account has a usable password (P)
HEREDOC
  exit 1
fi
printf "\n\n"

echo "9.2.4 Verify No Legacy '+' Entries Exist in /etc/passwd,/etc/shadow and /etc/group"
echo "____CHECK____"
if ! grep '^+:' /etc/passwd /etc/shadow /etc/group; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "____SET____"
  echo "Legacy entries are deleted"
  sed -i '/^+:/d' /etc/passwd
  sed -i '/^+:/d' /etc/shadow
  sed -i '/^+:/d' /etc/group
fi
printf "\n\n"

echo "9.2.5 Verify No UID 0 Accounts Exist Other Than root"
echo -e "____CHECK____:
User List  having UID equals to 0"
cat /etc/passwd | awk -F: '($3 == 0) { print $1 }'
output=$(cat /etc/passwd | awk -F: '($3 == 0) { print $1 }')
#check the length if it nonzero, then success, otherwise failure.
if [[ "$output" = "root" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correct this!"
  echo "All UID 0 accounts EXCEPT root must be deleted."
  exit 1
fi
printf "\n\n"

echo "9.2.6 Ensure root PATH Integrity"
echo -e "____CHECK____"
if [[ ""`echo $PATH | grep :: `"" != """" ]]; then
  echo "Check FAILED, correct this!"
  echo "Empty Directory in PATH \(::\)"
  exit 1
fi

if [[ "`echo $PATH | grep :$`" != """" ]]; then
  echo "Check FAILED, correct this!"
  echo ""Trailing : in PATH""
  exit 1
fi

p=`echo $PATH | sed -e 's/::/:/' -e 's/:$//' -e 's/:/ /g'`
set -- $p
while [[ ""$1"" != """" ]]; do
  if [[ ""$1"" = ""."" ]]; then
    echo ""PATH contains .""
    echo "Check FAILED, correct this!"
    exit 1
  fi

  if [[ ! -d $1 ]]; then
    echo $1 is not a directory
    echo "Check FAILED, correct this!"
    exit 1
  fi

  dirperm=`ls -ldH $1 | cut -f1 -d"" ""`
  if [ `echo $dirperm | cut -c6 ` != ""-"" ]; then
    echo ""Group Write permission set on directory $1""
    echo "Check FAILED, correct this!"
    exit 1
  fi
  if [ `echo $dirperm | cut -c9 ` != ""-"" ]; then
    echo ""Other Write permission set on directory $1""
    echo "Check FAILED, correct this!"
    exit 1
  fi

  dirown=`ls -ldH $1 | awk '{print $3}'`
  if [ ""$dirown"" != ""root"" ] ; then
    echo $1 is not owned by root
    echo "Check FAILED, correct this!"
    exit 1
  fi
  shift
done
echo "Check PASSED"
printf "\n\n"

# FIXME Implement Check can not be performed. Need further investigation.
#echo "9.2.7 Check Permissions on User Home Directories"
#printf "\n\n"

echo '9.2.8 Check User "Dot" File Permissions'
echo  -e "____CHECK____: List of group or world-writable user "dot" files and directories"
for dir in `cat /etc/passwd | egrep -v '(root|sync|halt|shutdown)' | awk -F: '($7 != "/sbin/nologin") { print $6 }'`; do
  for file in $dir/.[A-Za-z0-9]*; do
    if [ ! -h "$file" -a -f "$file" ]; then
      fileperm=`ls -ld $file | cut -f1 -d" "`
    if [ `echo $fileperm | cut -c6 ` != "-" ]; then
      echo "Group Write permission set on file $file"
      echo "Check FAILED, correct this!"
      exit 1
    fi
    if [ `echo $fileperm | cut -c9 ` != "-" ]; then
      echo "Other Write permission set on file $file"
      echo "Check FAILED, correct this!"
      exit 1
    fi
  fi
 done
done

echo "9.2.9 Check Permissions on User .netrc Files"
echo  -e "____CHECK____: List of problematic permissions on User .netrc Files:"
for dir in `cat /etc/passwd | egrep -v '(root|sync|halt|shutdown)' |\
    awk -F: '($7 != "/sbin/nologin") { print $6 }'`; do
  for file in $dir/.netrc; do
    if [ ! -h "$file" -a -f "$file" ]; then
      fileperm=`ls -ld $file | cut -f1 -d" "`
      if [ `echo $fileperm | cut -c5 ` != "-" ]; then
        echo "Group Read set on $file"
        echo "Check FAILED, correct this!"
        exit 1
      fi
      if [ `echo $fileperm | cut -c6 ` != "-" ]; then
        echo "Group Write set on $file"
        echo "Check FAILED, correct this!"
        exit 1
      fi
      if [ `echo $fileperm | cut -c7 ` != "-" ]; then
        echo "Group Execute set on $file"
        echo "Check FAILED, correct this!"
        exit 1
      fi
      if [ `echo $fileperm | cut -c8 ` != "-" ]; then
        echo "Other Read set on $file"
        echo "Check FAILED, correct this!"
        exit 1
      fi
      if [ `echo $fileperm | cut -c9 ` != "-" ]; then
        echo "Other Write set on $file"
        echo "Check FAILED, correct this!"
        exit 1
      fi
      if [ `echo $fileperm | cut -c10 ` != "-" ]; then
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
      cat <<HEREDOC
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
for group in $(cut -s -d: -f4 /etc/passwd | sort -u ); do
  if ! grep -q -P "^.*?:x:$group:" /etc/group; then
    echo "Group $group is referenced by /etc/passwd but does not exist in /etc/group"
    echo "Check FAILED, correct this!"
    exit 1
  fi
done
echo "Check PASSED"
printf "\n\n"

echo "9.2.12 Check That Users Are Assigned Valid Home Directories"
echo -e "____CHECK____"
while IFS=: read user enc_passwd uid gid full_name home shell; do
  if [[ ${uid} -ge ${MIN_NON_SYSTEM_UID} && ! -d "$home" && ${user} != "nfsnobody" ]]; then
    cat <<HEREDOC
Check FAILED, correct this!"
This script checks to make sure that home directories assigned in the /etc/passwd file exist.

The home directory ($home) of user $user does not exist.

Users without an assigned home directory should be removed or assigned a home directory as appropriate. Create it and
make sure the respective user owns the directory.
HEREDOC
    exit 1
  fi
done </etc/passwd
echo "Check PASSED"
printf "\n\n"

echo "9.2.13 Check User Home Directory Ownership for non-system users"
echo -e "____CHECK____"
while IFS=: read user enc_passwd uid gid full_name home shell; do
  if [[ ${uid} -ge ${MIN_NON_SYSTEM_UID} && -d "$home" && ${user} != "nfsnobody" ]]; then
    owner=$(stat -L -c "%U" "$home")
    if [[ "$owner" != "$user" ]]; then
      cat <<HEREDOC
Check FAILED, correct this!
The home directory ($home) of user $user is owned by different owner: $owner.
Change the ownership of home directories to a correct user.
HEREDOC
      exit 1
    fi
  fi
done </etc/passwd
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
for dir in `cat /etc/passwd | awk -F: '{ print $6 }'`; do
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
for dir in `cat /etc/passwd | awk -F: '{ print $6 }'`; do
  if [ ! -h "$dir/.forward" -a -f "$dir/.forward" ]; then
    echo "Check FAILED, correct this!"
    echo ".forward file $dir/.forward exists"
    exit 1
  fi
done
echo -e "\nCheck PASSED: No Presence of User .forward Files"
printf "\n\n"
# endregion

if [[ ${KERNEL_UPDATE} == true || ${JENKINS_UPDATE} == true ]]; then
  readonly LOG=${absolute_script_dir}/safe_reboot.log
  echo "Activating the cron job for safe reboot..."
  # Use flock to prevent secondary processes if the first safe_reboot hasn't finished for some reason.
  { crontab -l; \
  echo "*/10 * * * * flock --nonblock $SCRIPT_DIR/safe_updates.lock sudo $SCRIPT_DIR/safe_updates.sh -r 'Kernel update from v${kernel_version} to v${latest_kernel_package_version}' -j ${END_USER_GROUP} ${SYSTEM_USER} >>$LOG"; } | crontab -
fi

exit 0