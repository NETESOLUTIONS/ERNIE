#!/usr/bin/env bash

########################################
# Ensure file permissions and ownership are set correctly
# Arguments:
#   $1  file
#   $2  numerical permissions (optional: defaults to 600 / u=rw,go=)
#   $3  ownership (optional: defaults to root:root)
# Returns:
#   None
# Examples:
#   ensure /usr/lib/systemd/system/rescue.service '/sbin/sulogin' 'ExecStart=-/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'
########################################
ensure_permissions() {
  set -e
  set -o pipefail

  local file="$1"
  local permissions="${2:-600}"
  local ownership="${3:-root:root}"
  local actual
  actual=$(stat --format="%U:%G %a" "${file}")
  if [[ "$actual" == "$ownership $permissions" ]]; then
    echo "Check PASSED"
  else
    echo "Check FAILED"
    echo "The actual ownership and permissions for $file: $actual"

    echo "Correcting ..."
    echo "___SET___"
    chown "${ownership}" "${file}"
    chmod "${permissions}" "${file}"
  fi
}
