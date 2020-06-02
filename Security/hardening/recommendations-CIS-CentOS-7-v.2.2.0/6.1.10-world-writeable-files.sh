#!/usr/bin/env bash
echo "6.1.10 Ensure no world writable files exists"
echo "____CHECK____"
unset check_failed
while IFS= read -r file; do
  if [[ ! $check_failed ]]; then
    check_failed=true
    echo "Check FAILED, correcting ..."
    echo "____SET____"
    echo "Removing write access for 'other' ..."
  fi
  chmod -v -v o-w "${file}"
done < <(df --local -P \
  | awk {'if (NR!=1) print $6'} \
  | xargs -I '{}' find '{}' -xdev -type f -perm -0002)

if [[ ! $check_failed ]]; then
  echo "Check PASSED"
fi
printf "\n\n"
