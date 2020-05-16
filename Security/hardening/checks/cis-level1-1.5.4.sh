#!/usr/bin/env bash
echo "1.5.4 Require Authentication for Single-User Mode"
echo "___CHECK 1/2___"
if [[ "$(grep SINGLE /etc/sysconfig/init | tee /tmp/hardening-1.5.4.1.log)" == 'SINGLE=/sbin/sulogin' ]]; then
  echo "Check PASSED"
else
  cat /tmp/hardening-1.5.4.1.log
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  if [[ -s /tmp/hardening-1.5.4.1.log ]]; then
    sed -i "/SINGLE/s/sushell/sulogin/" /etc/sysconfig/init
  else
    echo "SINGLE=/sbin/sulogin" >> /etc/sysconfig/init
  fi
fi
