#!/usr/bin/env bash
echo "3.1 Set Daemon umask"
echo "___CHECK___"
grep umask /etc/sysconfig/init
if [[ "$(grep umask /etc/sysconfig/init)" == "umask 027" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "umask 027" >> /etc/sysconfig/init
fi
printf "\n\n"
