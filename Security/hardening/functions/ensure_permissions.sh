#!/usr/bin/env bash

####################################################################
# Ensure system file permissions and ownership are set correctly
# Arguments:
#   $1  file
#   $2  (optional) numerical permissions. Default to 600 / u=rw,go=
# Returns:
#   None
# Examples:
#   ensure_permissions /etc/hosts.allow 644
####################################################################
ensure_permissions() {
  local file="$1"
  local permissions="${2:-600}"
  local -r OWNERSHIP="root:root"
#   $3  OWNERSHIP (optional: defaults to root:root)
#  local OWNERSHIP="${3:-root:root}"

  # shellcheck disable=SC2155
  local actual=$(stat --format="%U:%G %a" "${file}")
  if [[ "$actual" == "$OWNERSHIP $permissions" ]]; then
    echo "Check PASSED"
  else
    echo "Check FAILED"
    echo "The actual OWNERSHIP and permissions for $file: '$actual'"

    echo "Correcting ..."
    echo "___SET___"
    chown "${OWNERSHIP}" "${file}"
    chmod "${permissions}" "${file}"
  fi
}
