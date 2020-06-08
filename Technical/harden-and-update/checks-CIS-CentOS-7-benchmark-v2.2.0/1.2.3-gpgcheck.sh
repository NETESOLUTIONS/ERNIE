#!/usr/bin/env bash
set -e
set -o pipefail
echo "1.2.3 Ensure gpgcheck is globally activated"

echo "___CHECK___"
ensure /etc/yum.conf '^gpgcheck=' 'gpgcheck=1'
printf "\n\n"