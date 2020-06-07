#!/usr/bin/env bash

################################################
# Check and remove a property set in a file
#
# Arguments:
#   $1  file
#   $2  a PCRE pattern
#
# Returns:
#   None
#
# Examples:
#   ensure_not /etc/motd '(\\v\|\\r\|\\m\|\\s)'
#   ensure_not /etc/passwd '^+:'
################################################
ensure_not() {
  local file="$1"
  local pattern="$2"
  # shellcheck disable=SC2155
  local actual=$(pcregrep "$pattern" "$file")
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
export -f ensure_not
