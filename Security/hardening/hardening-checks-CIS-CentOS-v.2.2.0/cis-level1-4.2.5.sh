#!/usr/bin/env bash
echo "4.2.5	Enable Ignore Broadcast Requests"
echo "____CHECK____"
/sbin/sysctl net.ipv4.icmp_echo_ignore_broadcasts
if [[ "$(/sbin/sysctl net.ipv4.icmp_echo_ignore_broadcasts)" == "net.ipv4.icmp_echo_ignore_broadcasts = 1" ]]; then
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
