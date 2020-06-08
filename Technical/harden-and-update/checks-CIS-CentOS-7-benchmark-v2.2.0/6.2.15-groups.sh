#!/usr/bin/env bash
set -e
set -o pipefail
echo "6.2.15 Ensure all groups in /etc/passwd exist in /etc/group"
echo -e "____CHECK____"
for group in $(cut -s -d: -f4 /etc/passwd | sort -u); do
  if ! grep -q -P "^.*?:x:$group:" /etc/group; then
    echo "Group $group is referenced by /etc/passwd but does not exist in /etc/group"
    echo "Check FAILED, correct this!"
    exit 1
  fi
done
echo "Check PASSED"
printf "\n\n"
