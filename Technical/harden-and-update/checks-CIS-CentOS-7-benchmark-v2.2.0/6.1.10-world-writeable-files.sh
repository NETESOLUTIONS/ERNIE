#!/usr/bin/env bash
echo "6.1.10 Ensure no world writable files exists"
echo "____CHECK____"
unset check_failed
coproc {df --local -P  | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -0002; }
# As of Bash 4, `COPROC_PID` has to be saved before it gets reset on process termination
_co_pid=$COPROC_PID
while IFS= read -r line; do
  echo "Processing $line ..."
done <& "${COPROC[0]}"
wait "$_co_pid"


while IFS= read -r file; do
  if [[ ! $check_failed ]]; then
    check_failed=true
    echo "Check FAILED, correcting ..."
    echo "____SET____"
    echo "Removing write access for 'other' ..."
  fi
  chmod -v -v o-w "${file}"
done < <()

if [[ ! $check_failed ]]; then
  echo "Check PASSED"
fi
printf "\n\n"
