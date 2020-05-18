#!/usr/bin/env bash
echo '1.1.2 Set nodev option for /tmp Partition'
if [[ "$(grep /tmp /etc/fstab | grep nodev)" != "" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correct this!"
fi
printf "\n\n"
