#!/usr/bin/env bash

########################################################################################################################
# Ensure configuration value is set in a config file
#
# Arguments:
#   $1  file
#   $2  configuration key: an ERE sub-string pattern
#   $3  (optional) expected configuration line. Omitting this would switch to asserting simply that the key is present.
#   $4  (optional) `^` to prepend the line. Defaults to appending.
#
# Examples:
#   1. Check and configure `sulogin`:
#     ensure /usr/lib/systemd/system/rescue.service '/sbin/sulogin' \
#       'ExecStart=-/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'
#
#   2. Check that `/etc/chrony.conf` has server(s) or pool(s) configured, fail if it does not:
#     ensure /etc/chrony.conf '^(server|pool)'
########################################################################################################################
ensure() {
  local -r PREPEND_INSERTION='^'

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
    # Check each matching line against expected
    while IFS= read -r line; do
      if [[ "$line" != "$expected" ]]; then
        local check_failed=true
        break
      fi
    done <<< "$matching_lines"
  fi

  if [[ ! $matching_lines || "$check_failed" == true ]]; then
    echo "Check FAILED"
    if [[ $line ]]; then
      echo "Found unexpected actual value in $file for the pattern '$pattern' = '$line'"
    else
      echo "No match found in $file for the pattern '$pattern'"
    fi
    echo "Expected: '$expected'"

    if [[ ! $expected ]]; then
      echo "This has to be fixed manually."
      return 1
    fi

    echo "___SET___"

    if [[ "$insertion_mode" == "$PREPEND_INSERTION" ]]; then
      upsert "$file" '^' "$expected"
    else
      # If there are matching lines, *all* of them will be updated to `expected` by `upsert`
      upsert "$file" "$pattern" "$expected"
    fi
    #done
    return
  fi

  echo "Check PASSED"
}
export -f ensure
