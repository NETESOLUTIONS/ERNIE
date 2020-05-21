#!/usr/bin/env bash
echo "4.1.2	Disable Send Packet Redirects"
echo "____CHECK 1/2____"
/sbin/sysctl net.ipv4.conf.all.send_redirects
if [[ "$(/sbin/sysctl net.ipv4.conf.all.send_redirects)" == "net.ipv4.conf.all.send_redirects = 0" ]]; then
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
if [[ "$(/sbin/sysctl net.ipv4.conf.default.send_redirects)" == "net.ipv4.conf.default.send_redirects = 0" ]]; then
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