#!/usr/bin/env bash
set -e
set -o pipefail
echo "2.2.15 Ensure mail transfer agent is configured for local-only mode"
echo "___CHECK___"

unset check_failed
coproc { netstat -an | pcregrep -o1 ' (\S+):25 .*LISTEN'; }
# As of Bash 4, `COPROC_PID` has to be saved before it gets reset on process termination
_co_pid=$COPROC_PID
while IFS= read -r address; do
  if [[ "$address" != "127.0.0.1" && "$address" != "::1" ]]; then
    check_failed=true
    echo "Check FAILED, correcting ..."
    echo "Mail Transfer Agents (MTA) is listening on '$address'"
    echo "___SET___"
    ensure /etc/postfix/main.cf '^inet_interfaces' 'inet_interfaces = loopback-only'
    systemctl restart postfix
    break
  fi
done <&"${COPROC[0]}"
wait "$_co_pid"

if [[ $check_failed != true ]]; then
  echo "Check PASSED"
fi
printf "\n\n"
