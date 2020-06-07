#!/usr/bin/env bash
set -e
set -o pipefail
echo -e '## 3.4 TCP Wrappers ##\n\n'

echo "3.4.1 Ensure TCP Wrappers is installed"
#echo "____CHECK 1/2____"
#ldd /sbin/sshd | grep libwrap.so
#output=$(ldd /sbin/sshd | grep libwrap.so)
#output_size=${#output}
#if [[ "$output_size" != "0" ]]; then
#  echo "Check PASSED"
#else
#  echo "Check FAILED, correcting ..."
#  echo "____SET____"
#  yum install tcp_wrappers
#fi
#echo "____CHECK 2/2____"

ensure_installed tcp_wrappers tcp_wrappers-libs

echo "3.4.4 Ensure permissions on /etc/hosts.allow are configured"
echo "____CHECK____"
ensure_permissions /etc/hosts.allow 644
printf "\n\n"

echo "3.4.5 Ensure permissions on /etc/hosts.deny are configured"
echo "____CHECK____"
ensure_permissions /etc/hosts.deny 644
printf "\n\n"
