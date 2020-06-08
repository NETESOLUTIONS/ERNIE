#!/usr/bin/env bash
set -e
set -o pipefail
echo -e '## 1.5 Additional Process Hardening ##\n\n'

echo "1.5.1 Ensure core dumps are restricted"
echo "____CHECK 1/2____"
ensure /etc/security/limits.conf "hard core" "* hard core 0"

echo "____CHECK 2/2____"
ensure_kernel_param fs.suid_dumpable 0
printf "\n\n"
