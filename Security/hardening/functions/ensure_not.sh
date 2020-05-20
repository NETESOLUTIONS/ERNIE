#!/usr/bin/env bash

########################################
# Ensure configuration is *not* set in a config file
# Arguments:
#   $1  file
#   $2  grep ERE pattern
# Returns:
#   None
# Examples:
#   ensure_not /etc/motd '(\\v\|\\r\|\\m\|\\s)'
########################################
ensure() {
  set -e
  set -o pipefail

  local file="$1"
  local pattern="$2"
  local actual=$(grep -E "$pattern" "$file")
  if [[ ! "$actual" ]]; then
    echo "Check PASSED"
  else
    echo "Check FAILED"
    echo "The actual value in $1: '$actual'"
    echo "Correcting ..."
    backup "$file"
    sed --in-place --regexp-extended "/$pattern/d" "$file"
  fi
}