== All new, not yet implemented (TODO) checks, Level 2 (L2) and TBD DISABLED checks ==

# TODO 1.1.1.1 Ensure mounting of cramfs filesystems is disabled
# TODO 1.1.1.2 Ensure mounting of freevxfs filesystems is disabled
# TODO 1.1.1.3 Ensure mounting of jffs2 filesystems is disabled
# TODO 1.1.1.4 Ensure mounting of hfs filesystems is disabled
# TODO 1.1.1.5 Ensure mounting of hfsplus filesystems is disabled
# TODO 1.1.1.6 Ensure mounting of squashfs filesystems is disabled
# TODO 1.1.1.7 Ensure mounting of udf filesystems is disabled
# L2: 1.1.1.8 Ensure mounting of FAT filesystems is disabled
# L2: 1.1.6 Ensure separate partition exists for /var
# L2: 1.1.7 Ensure separate partition exists for /var/tmp
#
#if [[ "$(grep "[[:space:]]/tmp[[:space:]]" /etc/fstab)" != "" ]]; then
#  echo "Check PASSED"
#else
#  echo "Partitioning"
#  dd if=/dev/zero of=/tmp/tmp_fs seek=512 count=512 bs=1M
#  mkfs.ext3 -F /tmp/tmp_fs
#  cat >> /etc/fstab << HEREDOC
#/tmp/tmp_fs					/tmp		ext3	noexec,nosuid,nodev,loop 1 1
#/tmp						/var/tmp	none	bind
#HEREDOC
#  chmod a+wt /tmp
#  mount /tmp
#fi
#printf "\n\n"

# L2 1.1.6 Ensure separate partition exists for /var
# L2 1.1.7 Ensure separate partition exists for /var/tmp
# TODO 1.1.8 Ensure nodev option set on /var/tmp partition
# TODO 1.1.9 Ensure nosuid option set on /var/tmp partition
# TODO 1.1.10 Ensure noexec option set on /var/tmp partition
# L2 1.1.11 Ensure separate partition exists for /var/log
# L2 1.1.12 Ensure separate partition exists for /var/log/audit
# L2 1.1.13 Ensure separate partition exists for /home
# TODO 1.1.14 Ensure nodev option set on /home partition
# TODO 1.1.15 Ensure nodev option set on /dev/shm partition
# TODO 1.1.16 Ensure nosuid option set on /dev/shm partition
# TODO 1.1.17 Ensure noexec option set on /dev/shm partition
# TODO 1.1.18 Ensure nodev option set on removable media partitions
# TODO 1.1.19 Ensure nosuid option set on removable media partitions
# TODO 1.1.20 Ensure noexec option set on removable media partitions

# TBD DISABLED Files get modified for different reasons. It's unclear what could be done to fix a failure.
#echo '1.1.21 Ensure sticky bit is set on all world-writable directories'

# TODO 1.1.2 Disable Automounting
# TODO 1.2.1 Ensure package manager repositories are configured
# TODO 1.3.1 Ensure AIDE is installed
# TODO 1.3.2 Ensure filesystem integrity is regularly checked
# TODO 1.5.2 Ensure XD/NX support is enabled
# TODO 1.5.3 Ensure address space layout randomization (ASLR) is enabled
# TODO 1.5.4 Ensure prelink is disabled (Scored)

# L2 1.6.1.1 Ensure SELinux is not disabled in bootloader configuration
# L2 1.6.1.2 Ensure the SELinux state is enforcing
# L2 1.6.1.3 Ensure SELinux policy is configured
# L2 1.6.1.4 Ensure SETroubleshoot is not installed
# L2 1.6.1.5 Ensure the MCS Translation Service (mcstrans) is not installed
# L2 1.6.1.6 Ensure no unconfined daemons exist
# L2 1.6.2 Ensure SELinux is installed

# TBD DISABLED We do not need GNOME Display Manager
#1.7.2 Ensure GDM login banner is configured

# TBD DISABLED Not required for this baseline configuration
#3.3.3 Ensure IPv6 is disabled

# TBD DISABLED Access control should be enforced by a firewall
#3.4.2 Ensure /etc/hosts.allow is configured

# TBD DISABLED Access control should be enforced by a firewall
#3.4.3 Ensure /etc/hosts.deny is configured

# TBD DISABLED 3.6
# Firewall Configuration / IPtables. Better firewall solutions might be preferred over `IPtables`:
# a perimeter firewall over `bpfilter / eBPF` over `nftables` over `IPtables` back-end.
#

#echo -e '## 3.6 Firewall Configuration ##\n\n'
#
#echo "Enable IPtables"
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
#echo "Enable IP6tables"
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

# L2 # 4.1 Configure System Accounting (auditd) #
# L2 4.1.1 Configure Data Retention
# L2 4.1.2 Ensure auditd service is enabled
# L2 4.1.3 Ensure auditing for processes that start prior to auditd is enabled
# L2 4.1.4 Ensure events that modify date and time information are collected
# L2 4.1.5 Ensure events that modify user/group information are collected
# L2 4.1.6 Ensure events that modify the system's network environment are collected
# L2 4.1.7 Ensure events that modify the system's Mandatory Access Controls are collected
# L2 4.1.8 Ensure login and logout events are collected
# L2 4.1.9 Ensure session initiation information is collected
# L2 4.1.10 Ensure discretionary access control permission modification events are collected
# L2 4.1.11 Ensure unsuccessful unauthorized file access attempts are collected
# L2 4.1.12 Ensure use of privileged commands is collected
# L2 4.1.13 Ensure successful file system mounts are collected
# L2 4.1.14 Ensure file deletion events by users are collected
# ...

# TODO 4.2.1.2 Ensure logging is configured

#echo "Configure /etc/rsyslog.conf; Create and Set Permissions on rsyslog Log Files"
#echo "___CHECK 1/5___"
#grep "auth,user.* /var/log/messages" /etc/rsyslog.conf
#if [[ "$(grep "auth,user.* /var/log/messages" /etc/rsyslog.conf)" == "auth,user.* /var/log/messages" ]]; then
#  echo "Check PASSED"
#else
#  echo "Check FAILED, correcting ..."
#  echo "___SET___"
#  echo "auth,user.* /var/log/messages" >> /etc/rsyslog.conf
#  pkill -HUP rsyslogd
#  touch /var/log/messages
#  chown root:root /var/log/messages
#  chmod og-rwx /var/log/messages
#fi
#echo "___CHECK 2/5___"
#grep "kern.* /var/log/kern.log" /etc/rsyslog.conf
#if [[ "$(grep "kern.* /var/log/kern.log" /etc/rsyslog.conf)" == "kern.* /var/log/kern.log" ]]; then
#  echo "Check PASSED"
#else
#  echo "Check FAILED, correcting ..."
#  echo "___SET___"
#  echo "kern.* /var/log/kern.log" >> /etc/rsyslog.conf
#  pkill -HUP rsyslogd
#  touch /var/log/kern.log
#  chown root:root /var/log/kern.log
#  chmod og-rwx /var/log/kern.log
#fi
#echo "___CHECK 3/5___"
#grep "daemon.* /var/log/daemon.log" /etc/rsyslog.conf
#if [[ "$(grep "daemon.* /var/log/daemon.log" /etc/rsyslog.conf)" == "daemon.* /var/log/daemon.log" ]]; then
#  echo "Check PASSED"
#else
#  echo "Check FAILED, correcting ..."
#  echo "___SET___"
#  echo "daemon.* /var/log/daemon.log" >> /etc/rsyslog.conf
#  pkill -HUP rsyslogd
#  touch /var/log/daemon.log
#  chown root:root /var/log/daemon.log
#  chmod og-rwx /var/log/daemon.log
#fi
#echo "___CHECK 4/5___"
#grep "syslog.* /var/log/syslog" /etc/rsyslog.conf
#if [[ "$(grep "syslog.* /var/log/syslog" /etc/rsyslog.conf)" == "syslog.* /var/log/syslog" ]]; then
#  echo "Check PASSED"
#else
#  echo "Check FAILED, correcting ..."
#  echo "___SET___"
#  echo "syslog.* /var/log/syslog" >> /etc/rsyslog.conf
#  pkill -HUP rsyslogd
#  touch /var/log/syslog
#  chown root:root /var/log/syslog
#  chmod og-rwx /var/log/syslog
#fi
#echo "___CHECK 5/5___"
#grep "lpr,news,uucp,local0,local1,local2,local3,local4,local5,local6.* /var/log/unused.log" /etc/rsyslog.conf
#if [[ "$(grep "lpr,news,uucp,local0,local1,local2,local3,local4,local5,local6.* /var/log/unused.log" /etc/rsyslog.conf)" == "lpr,news,uucp,local0,local1,local2,local3,local4,local5,local6.* /var/log/unused.log" ]]; then
#  echo "Check PASSED"
#else
#  echo "Check FAILED, correcting ..."
#  echo "___SET___"
#  echo "lpr,news,uucp,local0,local1,local2,local3,local4,local5,local6.* /var/log/unused.log" >> /etc/rsyslog.conf
#  pkill -HUP rsyslogd
#  touch /var/log/unused.log
#  chown root:root /var/log/unused.log
#  chmod og-rwx /var/log/unused.log
#fi
#printf "\n\n"
#

# TODO DISABLED 4.2.1.4 Ensure rsyslog is configured to send logs to a remote log host

#echo "Configure rsyslog to Send Logs to a Remote Log Host"
#echo "___CHECK___"
#grep "^*.*[^I][^I]*@" /etc/rsyslog.conf
#if [[ "$(grep "^*.*[^I][^I]*@" /etc/rsyslog.conf | wc -l)" != 0 ]]; then
#  echo "Check PASSED"
#else
#  echo "Check FAILED, correcting ..."
#  echo "___SET___"
#  echo "*.* @@remote-host:514" >> /etc/rsyslog.conf
#  pkill -HUP rsyslogd
#fi
#printf "\n\n"
#

# TODO 4.2.2 Configure syslog-ng (if syslog-ng is installed on the system)
# TODO 4.2.3 Ensure rsyslog or syslog-ng is installed

# L2 6.1.1 Audit system file permissions
#echo "___CHECK___"
#rpm -qVa | awk '$2 != "c" { print $0 }' | tee /tmp/hardening-1.2.4.log
#if [[ -s /tmp/hardening-1.2.4.log ]]; then
#  echo "Check FAILED, correct this!"
#else
#  echo "Check PASSED"
#fi
#printf "\n\n"

# TBD DISABLED 5.3.2 Ensure lockout for failed password attempts is configured

# TODO 5.4.1.5 Ensure all users last password change date is in the past

# TBD DISABLED 5.4.4 Ensure default user umask is 027 or more restrictive
# Not recommended in dev environment due to large amount of intersecting users' tasks
#echo "5.4.4 Ensure default user umask is 027 or more restrictive"
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

# L2 5.4.5 Ensure default user shell timeout is 900 seconds or less

# TBD DISABLED 5.5 Ensure root login is restricted to system console
#echo "Restrict root Login to System Console"
cat /etc/securetty
echo "NEEDS MANUAL INSPECTION:"
echo "Remove entries for any consoles that are not in a physically secure location."
printf "\n\n"

== Other / obsolete checks (not in this CIS version) ==

*
ensure_uninstalled 'Remove LDAP ___CHECK 1/2___' openldap-servers

*
ensure_uninstalled 'Remove DNS Server' bind

*
ensure_uninstalled 'Remove SNMP Server' net-snmp

*
echo "Set Daemon umask"
echo "___CHECK___"
grep umask /etc/sysconfig/init
if [[ "$(grep umask /etc/sysconfig/init)" == "umask 027" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "umask 027" >> /etc/sysconfig/init
fi
printf "\n\n"

*
echo "Enable anacron Daemon"
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

*
echo "Ensure permissions on /etc/anacrontab are configured"
echo "___CHECK___"
ensure_permissions
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