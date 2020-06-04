#!/usr/bin/env bash
echo "2.2.15 Ensure mail transfer agent is configured for local-only mode"
echo "___CHECK___"
mapfile -t actual_strings < <(netstat -an | grep -E ':25 .*LISTEN')
declare -a expected_strings=('tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN'
  'tcp6       0      0 ::1:25                  :::*                    LISTEN')
# Compare two arrays
if [[ "$(printf '%s\n' "${actual_strings[@]}" "${expected_strings[@]}" | sort | uniq --unique)" ]]; then
  echo "Check FAILED, correcting ..."
  echo "Actual configuration:"
  echo "====="
  printf '%s\n' "${actual_strings[@]}"
  echo "====="
  echo "___SET___"
  ensure /etc/postfix/main.cf '^inet_interfaces' 'inet_interfaces = loopback-only'
  systemctl restart postfix
else
  echo "Check PASSED"
fi
printf "\n\n"
