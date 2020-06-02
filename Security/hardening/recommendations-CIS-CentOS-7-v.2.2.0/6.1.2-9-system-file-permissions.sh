#!/usr/bin/env bash
echo -e '## 6.1 System File Permissions ##\n\n'

echo "6.1.2 Ensure permissions on /etc/passwd are configured"
echo "____CHECK____"
ensure_permissions /etc/passwd 644
printf "\n\n"

echo "6.1.3 Ensure permissions on /etc/shadow are configured"
echo "____CHECK____"
ensure_permissions /etc/shadow 000
printf "\n\n"

echo "6.1.4 Ensure permissions on /etc/group are configured5"
echo "____CHECK____"
ensure_permissions /etc/group 644
printf "\n\n"

echo "6.1.5 Ensure permissions on /etc/gshadow are configured"
echo "____CHECK____"
ensure_permissions /etc/gshadow 000
printf "\n\n"

echo "6.1.6 Ensure permissions on /etc/passwd- are configured"
echo "____CHECK____"
ensure_permissions /etc/passwd- 644
printf "\n\n"

echo "6.1.7 Ensure permissions on /etc/shadow- are configured"
echo "____CHECK____"
ensure_permissions /etc/shadow- 644
printf "\n\n"

echo "6.1.8 Ensure permissions on /etc/group- are configured"
echo "____CHECK____"
ensure_permissions /etc/group- 644
printf "\n\n"

echo "6.1.9 Ensure permissions on /etc/gshadow- are configured"
echo "____CHECK____"
ensure_permissions /etc/gshadow- 000
printf "\n\n"