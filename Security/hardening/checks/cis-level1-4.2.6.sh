#!/usr/bin/env bash
echo "4.2.6	Enable Bad Error Message Protection"
echo "____CHECK____"
/sbin/sysctl net.ipv4.icmp_ignore_bogus_error_responses
if [[ "$(/sbin/sysctl net.ipv4.icmp_ignore_bogus_error_responses)" == "net.ipv4.icmp_ignore_bogus_error_responses = 1" ]]; then
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
