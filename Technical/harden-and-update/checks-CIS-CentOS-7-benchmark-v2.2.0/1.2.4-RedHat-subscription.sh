#!/usr/bin/env bash
set -e
set -o pipefail
echo "1.2.4 Ensure Red Hat Subscription Manager connection is configured"

echo "___CHECK___"
if subscription-manager identity >/dev/null; then
  echo "Check PASSED"
else
  echo "Check FAILED"
  echo "Run the following command to connect to the Red Hat Subscription Manager: 'subscription-manager register'"
  exit 1
fi
printf "\n\n"