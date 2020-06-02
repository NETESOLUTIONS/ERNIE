#!/usr/bin/env bash

########################################################################################################################
# Ensure configuration value is set in a config file
# Arguments:
#   $1  file
#
#   $2  configuration key: a PCRE pattern.
#
#   $3  (optional) expected configuration line(s): a string or a glob pattern
#       Omitting this or using a glob pattern (`*`, `?`, `[...]` characters) switches function to the assert mode: check
#       and-fail if the key is not found.
#       Multiple lines are each checked separately.
#
#   $4 (optional) `^` to prepend the line. Defaults to appending.
#
# Examples:
#   1. Check and configure `sulogin`
#     ensure /usr/lib/systemd/system/rescue.service '/sbin/sulogin' \
#       'ExecStart=-/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'
#
#   2. Check and configure two `restrict default` properties
#     ensure /etc/ntp.conf '^restrict.*default' 'restrict default kod nomodify notrap nopeer noquery
#       restrict -6 default kod nomodify notrap nopeer noquery'
#
#   3. Check that `/etc/chrony.conf` has server(s) or pool(s) present, fail if it does not
#     ensure /etc/chrony.conf '^(server|pool)' '*'
########################################################################################################################
ensure() {
  local -r PREPEND_INSERTION='1'

  local file="$1"
  local pattern="$2"
  local expected="$3"
  local insertion_mode="$4"
  # shellcheck disable=SC2155
  local actual=$(pcregrep "$pattern" "$file")
  # shellcheck disable=SC2053 # Support globs in `$expected`
  if [[ "$actual" == $expected ]]; then
    echo "Check PASSED"
  else
    echo "Check FAILED"
    echo "The actual value in $1: '$actual'"

    # Check for glob pattern special characters: `*?[` (not checking for `extglob` patterns)
    if [[ ! $expected || "$expected" == *[*?[]* ]]; then
      return 1
    fi

    echo "Correcting ..."
    echo "___SET___"
    mapfile -t lines <<< "$expected"
    for line in "${lines[@]}"; do
      if [[ "$insertion_mode" == "$PREPEND_INSERTION" ]]; then
        upsert "$file" '^' "$line"
      else
        upsert "$file" "^$line$" "$line"
      fi
    done
  fi
}