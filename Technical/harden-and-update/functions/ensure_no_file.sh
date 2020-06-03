#!/usr/bin/env bash

########################################################################################################################
# Check and remove a file if it exists
#
# Arguments:
#   $1  file
#
# Example:
#   ensure_no_file /etc/cron.deny
########################################################################################################################
ensure_no_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    echo "Check PASSED"
  else
    echo "Check FAILED, correcting ..."
    echo "___SET___"
    rm "$file"
  fi
}
