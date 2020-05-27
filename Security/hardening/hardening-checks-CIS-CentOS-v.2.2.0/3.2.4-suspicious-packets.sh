#!/usr/bin/env bash
echo "3.2.4 Ensure suspicious packets are logged"
echo "____CHECK 1/2____"
/sbin/sysctl net.ipv4.conf.all.log_martians
if [[ "$(/sbin/sysctl net.ipv4.conf.all.log_martians)" == "net.ipv4.conf.all.log_martians = 1" ]]; then
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
if [[ "$(/sbin/sysctl net.ipv4.conf.default.log_martians)" == "net.ipv4.conf.default.log_martians = 1" ]]; then
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
