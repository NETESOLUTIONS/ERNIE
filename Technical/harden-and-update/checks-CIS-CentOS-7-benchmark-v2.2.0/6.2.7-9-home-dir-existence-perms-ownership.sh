#!/usr/bin/env bash
set -e
set -o pipefail
echo "6.2.7 Ensure all users' home directories exist"
echo "6.2.8 Ensure users' home directories permissions are 750 or more restrictive"
echo "6.2.9 Ensure users own their home directories"
echo "____CHECK____"

coproc grep -E -v '^(root|halt|sync|shutdown)' /etc/passwd
# As of Bash 4, `COPROC_PID` has to be saved before it gets reset on process termination
_co_pid=$COPROC_PID
# shellcheck disable=SC2034 # parsing all password fields is easier even when unused
while IFS=: read -r user enc_passwd uid gid full_name home shell; do
  if [[ "$shell" != "/sbin/nologin" && "$shell" != "/bin/false" ]]; then
    if [[ -d "$home" ]]; then
      perms=$(stat --format="%A" --dereference "$home")
      if [[ "$perms" == ?????w?* ]]; then
        echo "Group write permission set on the home '$home' of user '$user UID=$uid GID=$gid $full_name $shell'"
        check_failed=true
      fi
      if [[ "$perms" == ???????r?? ]]; then
        echo "Other read permission set on the home '$home' of user '$user UID=$uid GID=$gid $full_name $shell'"
        check_failed=true
      fi
      if [[ "$perms" == ????????w? ]]; then
        echo "Other write permission set on the home '$home' of user '$user UID=$uid GID=$gid $full_name $shell'"
        check_failed=true
      fi
      if [[ "$perms" == ?????????x ]]; then
        echo "Other execute permission set on the home '$home' of user '$user UID=$uid GID=$gid $full_name $shell'"
        check_failed=true
      fi

      owner=$(stat --format="%U" --dereference "$home")
      if [[ "$owner" != "$user" ]]; then
        echo "The home '$home' of user '$user UID=$uid GID=$gid $full_name $shell' is owned by '$owner'"
        check_failed=true
      fi
    else
      echo "The home '$home' of user '$user UID=$uid GID=$gid $full_name $shell' does not exist"
      check_failed=true
    fi
  fi
done <& "${COPROC[0]}"
wait "$_co_pid"

if [[ $check_failed == true ]]; then
  echo "Check FAILED, correct this!"
  exit 1
fi
echo "Check PASSED"
printf "\n\n"