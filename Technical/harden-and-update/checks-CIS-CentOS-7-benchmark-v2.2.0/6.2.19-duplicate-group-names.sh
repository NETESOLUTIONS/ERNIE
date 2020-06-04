#!/usr/bin/env bash
echo "6.2.19 Ensure no duplicate group names exist"
echo -e "____CHECK____"
while read -r unique_count group_name; do
  [[ -z "${unique_count}" ]] && break
  if (( unique_count > 1 )); then
    echo "Check FAILED, correct this!"
    echo "Duplicate Group Name $group_name for these groups:"
    gawk -F: '($1 == n) { print $3 }' "n=$group_name" /etc/group | xargs
    exit 1
  fi
done < <(cut -f1 -d":" /etc/group | sort -n | uniq -c)
echo "Check PASSED"
printf "\n\n"