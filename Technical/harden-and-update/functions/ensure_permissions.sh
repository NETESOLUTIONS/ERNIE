#!/usr/bin/env bash

########################################################################################################################
# Check and set system file permissions and ownership. Create a file if it does not exist.
#
# Arguments:
#   $1  file
#   $2  (optional) numerical permissions. Default to 600 / u=rw,go=
#
# Examples:
#   ensure_permissions /etc/hosts.allow 644
########################################################################################################################
ensure_permissions() {
  local -r OWNERSHIP="root:root"

  local file="$1"
  local permissions="${2:-600}"

  # shellcheck disable=SC2155 # intentionally suppress failures for non-existent files
  local actual=$(stat --format="%U:%G %a" "${file}" 2> /dev/null)
  if [[ "$actual" == "$OWNERSHIP $permissions" ]]; then
    echo "Check PASSED"
  else
    echo "Check FAILED"
    [[ -f "${file}" ]] && echo "The actual OWNERSHIP and permissions for $file: '$actual'"

    echo "Correcting ..."
    echo "___SET___"
    [[ ! -f "${file}" ]] && touch "${file}"
    chown "${OWNERSHIP}" "${file}"
    chmod "${permissions}" "${file}"
  fi
}
export -f ensure_permissions

