#!/usr/bin/env bash

########################################################################################################################
# Backup into a unique backup directory if BACKUP_DIR is defined
#
# Arguments:
#   $1 absolute absolute_file_name path
#
# Examples:
#   backup /etc/motd
########################################################################################################################
backup() {
  local absolute_file_name="$1"
  if [[ $BACKUP_DIR ]]; then
    local target_file="${BACKUP_DIR}${absolute_file_name}"
    # Remove shortest /* suffix
    local target_dir=${target_file%/*}

    if [[ ! -d "$target_dir" ]]; then
      mkdir -p "$target_dir"

      chown -R "$DEFAULT_OWNER_USER:$DEFAULT_OWNER_GROUP" "$BACKUP_DIR"
    fi

    # Don't overwrite if the absolute_file_name has been already backed up during the current run
    if [[ ! -f "$target_file" ]]; then
      # Preserve timestamp
      cp -pv "$absolute_file_name" "$target_file"

      chown "$DEFAULT_OWNER_USER:$DEFAULT_OWNER_GROUP" "$target_file"
    fi
  fi
}