#!/usr/bin/env bash

########################################################################################################################
# Ensure configuration value is set in a config file
# Arguments:
#   $1  file
#
#   $2  configuration key: an ERE sub-string pattern.
#
#   $3  (optional) expected configuration line: a string or a glob pattern.
#       Omitting this or using a glob pattern (`*`, `?`, `[...]` characters) switches function to the assert mode:
#       assert 1) that the key is there and 2) that it matches the glob pattern when provided.
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
  # FIXME Currently, the exact match is expected
  #  sometimes a variation of expected could be just fine, e.g. with extra whitespaces
  local expected="$3"
  local insertion_mode="$4"

  # Multiple lines might be matching the pattern
  # shellcheck disable=SC2155 # suppressing failure when a line is not found
  local matching_lines=$(grep -E "$pattern" "$file")
  local line
  if [[ $matching_lines && $expected ]]; then
    while IFS= read -r line; do
      # shellcheck disable=SC2053 # Support globs in `$expected`
      if [[ "$line" != $expected ]]; then
        local check_failed=true
        break
      fi
    done <<< "$matching_lines"
  fi

  if [[ ! $matching_lines || "$check_failed" == true ]]; then
    echo "Check FAILED"
    if [[ $line ]]; then
      echo "The actual value in $file for the pattern '$pattern' = '$line'"
    else
      echo "No match found in $file for the pattern '$pattern'"
    fi
    echo "Expected: '$expected'"

    # Check for glob pattern special characters: `*?[` (not checking for `extglob` patterns)
    if [[ ! $expected || "$expected" == *[*?[]* ]]; then
      echo "This has to be fixed manually."
      return 1
    fi

    echo "___SET___"
    #mapfile -t expected_lines <<< "$expected"
    #for expected_line in "${expected_lines[@]}"; do
    if [[ "$insertion_mode" == "$PREPEND_INSERTION" ]]; then
      upsert "$file" '^' "$expected"
    else
      upsert "$file" "$pattern" "$expected"
    fi
    #done
    return
  fi

  echo "Check PASSED"
}
export -f ensure
