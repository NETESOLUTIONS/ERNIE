#!/usr/bin/env bash
echo -e '## Filesystem Configuration ##\n\n'

echo '1.1.1 Create separate partition for /tmp'
echo 'Verify that there is a /tmp file partition in the /etc/fstab file'
if [[ "$(grep "[[:space:]]/tmp[[:space:]]" /etc/fstab)" != "" ]]; then
  echo "Check PASSED"
else
  echo "Partitioning"
  dd if=/dev/zero of=/tmp/tmp_fs seek=512 count=512 bs=1M
  mkfs.ext3 -F /tmp/tmp_fs
  cat >> /etc/fstab << HEREDOC
/tmp/tmp_fs					/tmp		ext3	noexec,nosuid,nodev,loop 1 1
/tmp						/var/tmp	none	bind
HEREDOC
  chmod a+wt /tmp
  mount /tmp
fi
printf "\n\n"
