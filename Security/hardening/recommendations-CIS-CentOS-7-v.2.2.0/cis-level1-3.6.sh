#!/usr/bin/env bash
echo "3.6 Configure Network Time Protocol (NTP)"
echo "___CHECK 1/3___"
ls /etc | grep ntp.conf
if [[ "$(ls /etc | grep ntp.conf)" == "ntp.conf" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  yum -y install ntp
fi
echo "___CHECK 2/3___"
grep 'restrict default' /etc/ntp.conf
if [[ "$(grep 'restrict default' /etc/ntp.conf)" == "restrict default kod nomodify notrap nopeer noquery" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/restrict default/d' /etc/ntp.conf
  echo 'restrict default kod nomodify notrap nopeer noquery' >> /etc/ntp.conf
fi
echo "___CHECK 3/3___"
grep 'restrict -6 default' /etc/ntp.conf
if [[ "$(grep 'restrict -6 default' /etc/ntp.conf)" == "restrict -6 default kod nomodify notrap nopeer noquery" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/restrict -6 default/d' /etc/ntp.conf
  echo 'restrict -6 default kod nomodify notrap nopeer noquery' >> /etc/ntp.conf
fi
printf "\n\n"
