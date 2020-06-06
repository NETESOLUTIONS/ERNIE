#!/usr/bin/env bash
echo "6.2.17 Ensure no duplicate GIDs exist"
echo "____CHECK____"
cut -f3 -d":" /etc/group | sort -n | uniq -c | while read -r unique_count gid; do
  [[ -z "${unique_count}" ]] && break
  if (( unique_count > 1 )); then
    cat <<HEREDOC
Check FAILED, correct this!
Duplicate GIDs $gid for these groups:
-----
HEREDOC
    gawk -F: '($3 == n) { print $1 }' "n=$gid" /etc/group
    echo "-----"
    exit 1
  fi
done
echo -e "\nCheck PASSED: No Duplicate GIDs"
printf "\n\n"