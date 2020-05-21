#!/usr/bin/env bash
echo "4.2.8	Enable TCP SYN Cookies"
echo "____CHECK____"
/sbin/sysctl net.ipv4.tcp_syncookies
if [[ "$(/sbin/sysctl net.ipv4.tcp_syncookies)" == "net.ipv4.tcp_syncookies = 1" ]]; then
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
