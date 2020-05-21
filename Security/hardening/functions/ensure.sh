#!/usr/bin/env bash

########################################
# Ensure configuration value is set in a config file
# Arguments:
#   $1  file
#   $2  grep ERE pattern
#   $3  expected value. Fail if this is blank.
# Returns:
#   None
# Examples:
#   ensure /usr/lib/systemd/system/rescue.service '/sbin/sulogin' 'ExecStart=-/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'
########################################
ensure() {
  local file="$1"
  local pattern="$2"
  local expected="$3"
  # shellcheck disable=SC2155
  local actual=$(grep -E "$pattern" "$file")
  if [[ "$actual" == "$expected" ]]; then
    echo "Check PASSED"
  else
    echo "Check FAILED"
    echo "The actual value in $1: '$actual'"

    [[ ! $expected ]] && exit 1
    echo "Correcting ..."
    echo "___SET___"
    mapfile -t lines <<< "$expected"
    for line in "${lines[@]}"; do
      upsert "^$line$" "$line" "$file"
    done
  fi
}