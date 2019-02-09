#!/bin/bash
#** Usage notes are incorporated into online help (-h). The format mimics a manual page.
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME
  mount_disks.sh -- Mount the given Azure disks

SYNOPSIS
  Usage:
  mount_disks.sh -h: display this help

DESCRIPTION
  This script will find attached discs and either directly mount them or make new partitions to mount.

NOTE
  Success of this job is dependent upon pre-established Azure privileges and a saved connection via cli

HEREDOC
  exit 1
fi

#** Failing the script on the first error (-e + -o pipefail)
#** Echoing lines (-x)
set -x
set -e
set -o pipefail

# Obtain a list of attached disks that do not include the main OS disks
# For each disk, mount the partition to a new folder in the root directory
disk_prefix=$1
if [ $(mount | grep /${disk_prefix}) ]; then
  umount /${disk_prefix}*
fi
if [ -d /${disk_prefix}* ]; then
  rm -rf /${disk_prefix}*
fi
disk_counter=1
disks=($(ls /dev/sd[c-z]))
for disk in "${disks[@]}"; do
  if ls ${disk}[0-9] >/dev/null 2>&1 ; then
    for ready_disk in $(ls ${disk}[0-9]); do
      mkdir /${disk_prefix}${disk_counter}
      mount $ready_disk /${disk_prefix}${disk_counter}
      let "disk_counter++"
    done
  fi
done
