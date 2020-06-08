#!/usr/bin/env bash
set -e
set -o pipefail
echo "6.2.9 Ensure users own their home directories"
echo "____CHECK____"
while IFS=: read -r user enc_passwd uid gid full_name home shell; do
  if [[ ${uid} -ge ${MIN_NON_SYSTEM_UID} && ${user} != "nfsnobody" ]]; then
    owner=$(stat -L -c "%U" "$home")
    if [[ "$owner" != "$user" ]]; then
      cat << HEREDOC
Check FAILED, correct this!
The home directory '$home' of user '$user' is owned by different owner: '$owner'.
Change the ownership to a correct user.
HEREDOC
      exit 1
    fi
  fi
done < /etc/passwd
echo "Check PASSED"
printf "\n\n"