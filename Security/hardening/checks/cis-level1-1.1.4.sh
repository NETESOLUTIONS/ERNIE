#!/usr/bin/env bash
echo '1.1.4 Set noexec option for /tmp Partition'
if [[ "$(grep /tmp /etc/fstab | grep nosuid)" != "" ]]; then
  echo "Check PASSED"
else
  echo "Check FAILED, correct this!"
fi
printf "\n\n"
