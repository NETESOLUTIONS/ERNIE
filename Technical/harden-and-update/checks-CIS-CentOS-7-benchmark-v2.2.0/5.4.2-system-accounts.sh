#!/usr/bin/env bash
set -e
set -o pipefail
echo "5.4.2 Ensure system accounts are non-login"
echo "___CHECK___"

unset check_failed
coproc grep -E -v "^(\+|#)" /etc/passwd
# As of Bash 4, `COPROC_PID` has to be saved before it gets reset on process termination
_co_pid=$COPROC_PID
while IFS=: read -r user enc_passwd uid gid full_name home shell; do
  if [[ "$user" != "root" && "$user" != "sync" && "$user" != "shutdown" && "$user" != "halt" ]] && \
        ((uid < MIN_NON_SYSTEM_UID)) && [[ "$shell" != "/sbin/nologin" && "$shell" != "/bin/false" ]]; then
    if [[ ! $check_failed ]]; then
      check_failed=true
      echo "Check FAILED..."
      echo "___SET___"
    fi
    echo "$user:$uid:$gid:$full_name:$home:$shell"
    usermod --lock "${user}"
    usermod --shell /sbin/nologin "${user}"
  fi
done <& "${COPROC[0]}"
wait "$_co_pid"

if [[ ! $check_failed ]]; then
  echo "Check PASSED"
fi
printf "\n\n"
