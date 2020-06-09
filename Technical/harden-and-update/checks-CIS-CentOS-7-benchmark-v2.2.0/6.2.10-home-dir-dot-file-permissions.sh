#!/usr/bin/env bash
set -e
set -o pipefail
echo "6.2.10 Ensure users' dot files are not group or world writable"
echo -e "____CHECK____"
unset check_failed
# Iterate over end user records, skip comments
coproc grep -E -v '^(#|root|sync|halt|shutdown)' /etc/passwd
# As of Bash 4, `COPROC_PID` has to be saved before it gets reset on process termination
_co_pid=$COPROC_PID
while IFS=: read -r user enc_passwd uid gid full_name home shell; do
  if [[ $shell != "/sbin/nologin" && $shell != "/bin/false" ]]; then
    for file in "$home"/.[A-Za-z0-9]*; do
      if [[ ! -h "$file" && -f "$file" ]]; then
        # if file exists and is not a symbolic link

        perms=$(stat --format="%A" --dereference "$file")
        if [[ "$perms" == ?????w?* ]]; then
          if [[ ! $check_failed ]]; then
            check_failed=true
            echo "Check FAILED"
            echo "___SET___"
          fi
#          echo "Group write permission set on file $file"
          chmod -v g-w "$file"
        fi
        if [[ "$perms" == ????????w? ]]; then
          if [[ ! $check_failed ]]; then
            check_failed=true
            echo "Check FAILED"
            echo "___SET___"
          fi
#          echo "Other write permission set on file $file"
          chmod -v o-w "$file"
        fi
      fi
    done
  fi
done <& "${COPROC[0]}"
wait "$_co_pid"

if [[ ! $check_failed ]]; then
  echo "Check PASSED"
fi

printf "\n\n"