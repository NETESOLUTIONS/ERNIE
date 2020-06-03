#!/usr/bin/env bash

########################################################################################################################
# Check that a volume is mounted with a specified option. Fail if it is not.
#
# Arguments:
#   $1 mount point
#   $2 mount option
#
# Examples:
#   ensure_mount_option /tmp nodev
########################################################################################################################
ensure_mount_option() {
  local mount_point="$1"
  local mount_option="$2"

  echo "___CHECK___"
  if mount | pcregrep "on ${mount_point} .*\\(.*\\W${mount_option}\\W.*\\)"; then
    echo "Check PASSED"
  else
    echo "Check FAILED"
    cat << HEREDOC
Mounted '${mount_point}' volumes:
-----
HEREDOC
    mount | pcregrep "on ${mount_point}"
    cat << HEREDOC
-----
  * Add ${mount_option} to the mount options in /etc/fstab or /etc/systemd/system/local-fs.target.wants/{mount}.mount
  * Remount: sudo mount -o remount,${mount_option} ${mount_point}
HEREDOC
    exit 1
  fi
  printf "\n\n"
}
