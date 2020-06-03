#!/usr/bin/env bash
echo "6.2.17 Ensure no duplicate GIDs exist"
echo "____CHECK____"
while read -r unique_count gid; do
  [[ -z "${unique_count}" ]] && break
  if (( unique_count > 1 )); then
    echo "Check FAILED, correct this!"
    echo "Duplicate GID $gid for these groups:"
    gawk -F: '($3 == n) { print $1 }' "n=$gid" /etc/group | xargs
    exit 1
  fi
done < <(cut -f3 -d":" /etc/group | sort -n | uniq -c)
echo -e "\nCheck PASSED: No Duplicate GIDs"
printf "\n\n"