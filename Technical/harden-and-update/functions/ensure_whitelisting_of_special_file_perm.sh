#!/usr/bin/env bash

#################################################################
# Check for non-whitelisted executables with special permissions
#
# Globals:
#   $exclude_dirs array
#   $ABSOLUTE_SCRIPT_DIR
#
# Arguments:
#   $1  permission mask for `find -perm`
#   $2  permission name. A whitelist is read from `${ABSOLUTE_SCRIPT_DIR}/server-whitelists/$2-whitelist.txt`.
#
# Examples:
#   ensure_whitelisting_of_special_file_perm 4000 SUID
#################################################################
ensure_whitelisting_of_special_file_perm() {
  local perm_mask="$1"
  local perm_name="$2"
  local whitelist="${ABSOLUTE_SCRIPT_DIR}/server-whitelists/${perm_name}-whitelist.txt"

  echo "____CHECK____"
  echo "Excluding ${exclude_dirs[*]}"

  local exclude_dir_option
  printf -v exclude_dir_option -- '-not -path *%s/* ' "${exclude_dirs[@]}"
  #    parent=$(echo $path | cut -d/ -f 1-4)
  #    if [[ $(stat -c "%a" $parent) == 700 ]]; then
  #      [[ ${FINAL_EXCLUDE_DIRS} ]] && FINAL_EXCLUDE_DIRS="${FINAL_EXCLUDE_DIRS} " || FINAL_EXCLUDE_DIRS="${EXCLUDE_DIRS} "
  #      FINAL_EXCLUDE_DIRS="${FINAL_EXCLUDE_DIRS}-not -path $path"
  #    fi

  unset check_failed
  # -xdev  Don't descend directories on other filesystems
  # shellcheck disable=SC2086 # Don't quote `exclude_dir_option` to expand it into multiple parameters.
  coproc { df --local --output=target \
    | tail -n +2 \
    | xargs -I '{}' find '{}' ${exclude_dir_option} -xdev -type f -perm "-$perm_mask" -print \
    | grep -F --line-regexp --invert-match "--file=$whitelist"; }
  # As of Bash 4, `COPROC_PID` has to be saved before it gets reset on process termination
  _co_pid=$COPROC_PID
  while IFS= read -r file; do
    if [[ ! $check_failed ]]; then
      check_failed=true
      cat << HEREDOC
Check FAILED...
* Ensure that no rogue programs have been introduced into the system.
* Add legitimate items to the white list: ${whitelist}.
HEREDOC
    fi
    echo "$file"
  done <& "${COPROC[0]}"
  wait "$_co_pid"
  if [[ $check_failed ]]; then
    exit 1
  else
    echo "Check PASSED"
    printf "\n\n"
  fi
}
