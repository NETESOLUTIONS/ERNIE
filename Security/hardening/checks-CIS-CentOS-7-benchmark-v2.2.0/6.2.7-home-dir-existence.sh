#!/usr/bin/env bash
echo "6.2.7 Ensure all users' home directories exist"
echo "____CHECK____"
while IFS=: read -r user enc_passwd uid gid full_name home shell; do
  if (( uid >= MIN_NON_SYSTEM_UID )) && [[ "${user}" != "nfsnobody" && ! -d "$home" ]]; then
    cat << HEREDOC
Check FAILED, correct this!"
The home directory '$home' of user '$user' (UID=$uid) does not exist.

Users without an assigned home directory should be removed or assigned a home directory as appropriate.
Create it and make sure the respective user owns the directory.
HEREDOC
    exit 1
  fi
done < /etc/passwd
echo "Check PASSED"
printf "\n\n"