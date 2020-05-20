#!/usr/bin/env bash

########################################
# Backup into a unique backup directory if BACKUP_DIR is defined
#
# Arguments:
#   $1 file
# Returns:
#   None
# Examples:
#   backup /etc/motd
########################################
backup() {
  set -e
  set -o pipefail

  local file="$1"
  if [[ $BACKUP_DIR ]]; then
    if [[ ! -d $BACKUP_DIR ]]; then
      mkdir -p "$BACKUP_DIR"

      chown "$DEFAULT_OWNER_USER:$DEFAULT_OWNER_GROUP" "$BACKUP_DIR"
    fi
    local target_file="$BACKUP_DIR/$file"

    # Don't overwrite if the file has been already backed up during the current run
    if [[ ! -f $target_file ]]; then
      # Preserve timestamp
      cp -pv "$file" "$target_file"

      chown "$DEFAULT_OWNER_USER:$DEFAULT_OWNER_GROUP" "$target_file"
    fi
  fi
}