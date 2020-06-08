#!/usr/bin/env bash
set -e
set -o pipefail
echo -e '# 1. Initial Setup #\n\n'

echo -e '## 1.1 Filesystem Configuration ##\n\n'

echo '1.1.3 Ensure nodev option set on /tmp partition'
ensure_mount_option /tmp nodev