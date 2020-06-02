#!/usr/bin/env bash
echo -e '### Verify System File Permissions ###\n\n'

echo "6.1.2 Ensure permissions on /etc/passwd are configured"
echo "____CHECK____"
ensure_permissions /etc/passwd 644
printf "\n\n"