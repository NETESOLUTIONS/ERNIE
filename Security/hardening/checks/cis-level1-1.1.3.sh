#!/usr/bin/env bash
echo '1.1.3 Set nosuid option for /tmp Partition'
if [[ "$(grep /tmp /etc/fstab | grep nosuid)" != "" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correct this!"
fi
printf "\n\n"
