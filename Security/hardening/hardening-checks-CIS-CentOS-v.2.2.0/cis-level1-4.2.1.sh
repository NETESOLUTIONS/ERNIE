#!/usr/bin/env bash
echo -e '### Modify Network Parameters (Host and Router) ###\n\n'

echo "4.2.1	Disable Source Routed Packet Acceptance"
echo "____CHECK 1/2____"
/sbin/sysctl net.ipv4.conf.all.accept_source_route
if [[ "$(/sbin/sysctl net.ipv4.conf.all.accept_source_route)" == "net.ipv4.conf.all.accept_source_route = 0" ]]; then
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
if [[ "$(/sbin/sysctl net.ipv4.conf.default.accept_source_route)" == "net.ipv4.conf.default.accept_source_route = 0" ]]; then
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
