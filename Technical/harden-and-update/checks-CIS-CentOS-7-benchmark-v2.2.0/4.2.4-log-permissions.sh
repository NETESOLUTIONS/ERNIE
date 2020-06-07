#!/usr/bin/env bash
set -e
set -o pipefail
echo -e '4.2.4 Ensure permissions on all logfiles are configured'
echo "___CHECK___"
find /var/log -type f -exec chmod g-wx,o-rwx {} +
printf "\n\n"
