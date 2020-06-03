#!/usr/bin/env bash
echo "6.2.5 Ensure root is the only UID 0 account"
echo "____CHECK____"
actual=$(awk -F: '($3 == 0) { print $1 }' < /etc/passwd)
if [[ "$actual" == "root" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correct this!"
  echo -e "All UID 0 accounts EXCEPT root must be deleted:\n$actual"
  exit 1
fi
printf "\n\n"
