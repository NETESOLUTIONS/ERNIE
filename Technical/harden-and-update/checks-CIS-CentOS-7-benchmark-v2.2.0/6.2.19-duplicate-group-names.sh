#!/usr/bin/env bash
echo "6.2.19 Ensure no duplicate group names exist"
echo -e "____CHECK____"
cut -f1 -d":" /etc/group | sort -n | uniq -c | while read -r unique_count group_name; do
  [[ -z "${unique_count}" ]] && break
  if (( unique_count > 1 )); then
    cat <<HEREDOC
Check FAILED, correct this!
Duplicate Group Name $group_name for these groups:
-----
HEREDOC
    gawk -F: '($1 == n) { print $3 }' "n=$group_name" /etc/group
    echo "-----"
    exit 1
  fi
done
echo "Check PASSED"
printf "\n\n"