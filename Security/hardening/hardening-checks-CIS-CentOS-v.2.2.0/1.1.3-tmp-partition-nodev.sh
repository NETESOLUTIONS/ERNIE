#!/usr/bin/env bash
echo -e '# 1. Initial Setup #\n\n'

echo -e '## 1.1 Filesystem Configuration ##\n\n'

echo '1.1.3 Ensure nodev option set on /tmp partition'
echo "___CHECK___"
ensure /etc/fstab '/tmp.*nodev'
printf "\n\n"