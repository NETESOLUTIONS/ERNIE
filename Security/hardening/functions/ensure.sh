#!/usr/bin/env bash

########################################
# Ensure configuration value is set in a config file
# Arguments:
#   $1  file
#   $2  configuration key: an ERE pattern
#   $3  (optional) expected configuration line: a string or a glob pattern (could be multi-line)
#       Omitting this or using glob pattern characters (`*`, `?`, `[...]`) makes auto correction not possible: failing
#       if the key is not found.
# Returns:
#   None
# Examples:
#   1. Ensure `sulogin` is configured the expected way
#     ensure /usr/lib/systemd/system/rescue.service '/sbin/sulogin' \
#       'ExecStart=-/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'
#
#   2. Ensure 2 `restrict default` configuration lines
#     ensure /etc/ntp.conf '^restrict.*default' 'restrict default kod nomodify notrap nopeer noquery
#       restrict -6 default kod nomodify notrap nopeer noquery'
#
#  3. Check that `/etc/chrony.conf` has server(s) or pool(s) present, fail if it does not
#     ensure /etc/chrony.conf '^(server|pool)' '*'
########################################
ensure() {
  local file="$1"
  local pattern="$2"
  local expected="$3"
  # shellcheck disable=SC2155
  local actual=$(grep -E "$pattern" "$file")
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
      upsert "^$line$" "$line" "$file"
    done
  fi
}
