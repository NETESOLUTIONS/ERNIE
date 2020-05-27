#!/usr/bin/env bash
echo "2.2.15 Ensure mail transfer agent is configured for local-only mode"
echo "___CHECK___"
mapfile -t actual_strings < <(netstat -an | grep -E ':25 .*LISTEN')
declare -a expected_strings=('tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN'
  'tcp6       0      0 ::1:25                  :::*                    LISTEN')

if [[ "$actual_strings" == "$expected_strings" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correcting ..."
  echo "___SET___"
  sed -i '/^inet_interfaces/d' /etc/postfix/main.cf
  echo 'inet_interfaces = localhost' >> /etc/postfix/main.cf
fi
printf "\n\n"
