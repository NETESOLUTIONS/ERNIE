#!/usr/bin/env bash
set -e
set -o pipefail
echo "6.2.8 Ensure users' home directories permissions are 750 or more restrictive"
echo "____CHECK____"

unset check_failed
while IFS=: read -r user enc_passwd uid gid full_name home shell; do
  if ((uid >= MIN_NON_SYSTEM_UID)) && [[ "${user}" != "nfsnobody" ]]; then
    perm=$(ls -ld "$home" | cut -f1 -d" ")
    if [ $(echo "$perm" | cut -c6) != "-" ]; then
      echo "Group Write permission set on the home directory ($dir) of user $user"
      check_failed=true
    fi
    if [ $(echo "$perm" | cut -c8) != "-" ]; then
      echo "Other Read permission set on the home directory ($dir) of user $user"
      check_failed=true
    fi
    if [ $(echo "$perm" | cut -c9) != "-" ]; then
      echo "Other Write permission set on the home directory ($dir) of user $user"
      check_failed=true
    fi
    if [ $(echo "$perm" | cut -c10) != "-" ]; then
      echo "Other Execute permission set on the home directory ($dir) of user $user"
      check_failed=true
    fi
  fi
done < /etc/passwd

[[ $check_failed == true ]] && exit 1
echo "Check PASSED"

printf "\n\n"
