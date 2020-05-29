#!/usr/bin/env bash
echo -e '## 3.5 Uncommon Network Protocols ##\n\n'

echo "3.5.1 Ensure DCCP is disabled"
echo "___CHECK___"
grep "install dccp /bin/true" /etc/modprobe.d/CIS.conf
if [[ "$(grep "install dccp /bin/true" /etc/modprobe.d/CIS.conf)" == "install dccp /bin/true" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "install dccp /bin/true" >> /etc/modprobe.d/CIS.conf
fi
printf "\n\n"

echo "4.6.2 Disable SCTP"
echo "___CHECK___"
grep "install sctp /bin/true" /etc/modprobe.d/CIS.conf
if [[ "$(grep "install sctp /bin/true" /etc/modprobe.d/CIS.conf)" == "install sctp /bin/true" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "install sctp /bin/true" >> /etc/modprobe.d/CIS.conf
fi
printf "\n\n"

echo "4.6.3 Disable RDS"
echo "___CHECK___"
grep "install rds /bin/true" /etc/modprobe.d/CIS.conf
if [[ "$(grep "install rds /bin/true" /etc/modprobe.d/CIS.conf)" == "install rds /bin/true" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "install rds /bin/true" >> /etc/modprobe.d/CIS.conf
fi
printf "\n\n"

echo "4.6.4 Disable TIPC"
echo "___CHECK___"
grep "install tipc /bin/true" /etc/modprobe.d/CIS.conf
if [[ "$(grep "install tipc /bin/true" /etc/modprobe.d/CIS.conf)" == "install tipc /bin/true" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  echo "install tipc /bin/true" >> /etc/modprobe.d/CIS.conf
fi
printf "\n\n"