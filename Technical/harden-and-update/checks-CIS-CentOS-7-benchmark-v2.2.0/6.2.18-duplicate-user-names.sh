#!/usr/bin/env bash
set -e
set -o pipefail
echo "6.2.18 Ensure no duplicate user names exist"
echo "____CHECK____"
cut -f1 -d":" /etc/passwd | sort -n | uniq -c | while read -r unique_count username; do
  [[ -z "${unique_count}" ]] && break
  if (( unique_count > 1 )); then
    cat <<HEREDOC
Check FAILED, correct this!
Duplicate User Name $username for these users:
-----
HEREDOC
    gawk -F: '($1 == n) { print $3 }' n="$username" /etc/passwd
    echo "-----"
    exit 1
  fi
done
echo "Check PASSED"
printf "\n\n"