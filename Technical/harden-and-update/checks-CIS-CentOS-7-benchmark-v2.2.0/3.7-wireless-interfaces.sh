#!/usr/bin/env bash
set -e
set -o pipefail
echo '## 3.7 Ensure wireless interfaces are disabled ##'
echo "___CHECK___"
if command -v iwconfig 2> /dev/null && ! iwconfig; then
  cat <<'HEREDOC'
Wireless interfaces migth be present.
Run the following command and verify wireless interfaces are active: `ip link show up`
Run the following command to disable any wireless interfaces: `ip link set <interface> down`
HEREDOC
  exit
fi
printf "\n\n"
