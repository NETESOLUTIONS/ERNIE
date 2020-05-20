#!/usr/bin/env bash
echo -e '### Modify Network Parameters (Host Only) ###\n\n'

echo "4.1.1	Disable IP Forwarding"
echo "____CHECK____"
/sbin/sysctl net.ipv4.ip_forward
if [[ "$(/sbin/sysctl net.ipv4.ip_forward)" == "net.ipv4.ip_forward = 0" ]]; then
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
