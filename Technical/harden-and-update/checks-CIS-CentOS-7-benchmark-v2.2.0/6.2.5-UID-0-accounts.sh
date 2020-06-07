#!/usr/bin/env bash
set -e
set -o pipefail
echo "6.2.5 Ensure root is the only UID 0 account"
echo "____CHECK____"
readonly UID_0_ACCOUNTS=$(awk -F: '($3 == 0) { print $1 }' < /etc/passwd)
if [[ "$UID_0_ACCOUNTS" == "root" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correct this!"
  echo "All UID 0 accounts EXCEPT root must be deleted. The following account has been found"
  echo "$UID_0_ACCOUNTS"
  exit 1
fi
printf "\n\n"
