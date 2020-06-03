#!/usr/bin/env bash
echo "6.2.18 Ensure no duplicate user names exist"
echo "____CHECK____"
while read -r unique_count username; do
  [[ -z "${unique_count}" ]] && break
  if (( unique_count > 1 )); then
    echo "Check FAILED, correct this!"
    echo "Duplicate User Name $username for these users:"
    gawk -F: '($1 == n) { print $3 }' n="$username" /etc/passwd | xargs
    exit 1
  fi
done < <(cut -f1 -d":" /etc/passwd | sort -n | uniq -c)
echo -e "\nCheck PASSED: No Duplicate User Name"
printf "\n\n"