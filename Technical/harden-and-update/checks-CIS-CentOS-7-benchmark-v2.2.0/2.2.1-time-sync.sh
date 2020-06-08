#!/usr/bin/env bash
set -e
set -o pipefail
echo -e '## 2.2 Special Purpose Services ##\n\n'

echo "## 2.2.1 Time Synchronization ##"

echo "2.2.1.1 Ensure time synchronization is in use"
ensure_installed chrony

echo "2.2.1.3 Ensure chrony is configured"
ensure /etc/chrony.conf '^(server|pool)'
# TBD Options can include other stuff
ensure /etc/sysconfig/chronyd '^OPTIONS' 'OPTIONS="-u chrony"'