#!/usr/bin/env bash
echo "1.2.2 Verify that gpgcheck is Globally Activated"
echo "___CHECK___"
grep gpgcheck /etc/yum.conf
if [[ "$(grep gpgcheck /etc/yum.conf)" == "gpgcheck=1" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/gpgcheck=/d' /etc/yum.conf
  echo "gpgcheck=1" >> /etc/yum.conf
fi
printf "\n\n"
