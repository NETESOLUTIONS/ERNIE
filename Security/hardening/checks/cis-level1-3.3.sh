#!/usr/bin/env bash
echo "3.3 Disable Avahi Server"
echo "___CHECK___"
if chkconfig --list avahi-daemon | grep -E "[2-5]:on"; then
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/zeroconf/d' /etc/sysconfig/network
else
  echo "Check PASSED"
fi
printf "\n\n"
