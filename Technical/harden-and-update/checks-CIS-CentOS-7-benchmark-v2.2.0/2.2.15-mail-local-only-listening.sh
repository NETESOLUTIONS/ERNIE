#!/usr/bin/env bash
set -e
set -o pipefail
echo "2.2.15 Ensure mail transfer agent is configured for local-only mode"
echo "___CHECK___"
declare -ra EXPECTED_MAIL_LISTENING_CONFIG=('tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN'
  'tcp6       0      0 ::1:25                  :::*                    LISTEN')

actual_mail_listening_config=()
coproc { netstat -an | grep -E ':25 .*LISTEN'; }
# As of Bash 4, `COPROC_PID` has to be saved before it gets reset on process termination
_co_pid=$COPROC_PID
while IFS= read -r line; do
  # Trim trailing spaces
  actual_mail_listening_config+=("${line%%+( )}")
done <&"${COPROC[0]}"
wait "$_co_pid"

# Compare two arrays
if [[ "$(printf '%s\n' "${actual_mail_listening_config[@]}" "${EXPECTED_MAIL_LISTENING_CONFIG[@]}" \
          | sort \
          | uniq --unique)" ]]; then
  echo "Check FAILED, correcting ..."
  echo "The actual configuration:"
  echo "====="
  printf '%s\n' "${actual_mail_listening_config[@]}"
  echo "====="
  echo "___SET___"
  ensure /etc/postfix/main.cf '^inet_interfaces' 'inet_interfaces = loopback-only'
  systemctl restart postfix
else
  echo "Check PASSED"
fi
printf "\n\n"
