#!/usr/bin/env bash
echo -e '## 6.2 User and Group Settings ##\n\n'

echo "6.2.1 Ensure password fields are not empty"
failures=$(awk -F: '($2 == "" ) { print $1 }' < /etc/shadow)
if [[ -z "${failures}" ]]; then
  echo -e "\nCheck PASSED"
else
  cat << HEREDOC
Check FAILED, correct this!

Status (second column) legend:

PS  : Account has a usable password
LK  : User account is locked
L   : if the user account is locked (L)
NP  : Account has no password (NP)
P   : Account has a usable password (P)
HEREDOC

  while IFS=: read -r user; do
    passwd -S "${user}"
  done <<< "$failures"
  exit 1
fi
printf "\n\n"