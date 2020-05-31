#region New (not yet implemented) checks, Level 2 and DISABLED checks

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

#endregion

#region Other / obsolete checks (not in this CIS version)

#echo "1.2.4 Verify Package Integrity Using RPM"
#echo "___CHECK___"
#rpm -qVa | awk '$2 != "c" { print $0 }' | tee /tmp/hardening-1.2.4.log
#if [[ -s /tmp/hardening-1.2.4.log ]]; then
#  echo "Check FAILED, correct this!"
#else
#  echo "Check PASSED"
#fi
#printf "\n\n"

# TBD DISABLED
# `Exec-shield` is no longer an option in `sysctl` for kernel tuning in CentOS 7, it is by
# default on. This is a security measure, as documented in the RHEL 7 Security Guide.
# See http://centosfaq.org/centos/execshield-in-c6-or-c7-kernels/

#echo "1.6.2 Configure ExecShield"
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

#endregion