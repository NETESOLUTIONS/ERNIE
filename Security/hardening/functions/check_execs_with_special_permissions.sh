#!/usr/bin/env bash

################################################################################
# Check for non-whitelisted executables with special permissions
# Arguments:
#   $1  executable permission mask (for find -perm)
#   $2  permission name
# Returns:
#   None
# Examples:
#   check_execs_with_special_permissions 4000 SUID
################################################################################
check_execs_with_special_permissions() {
  echo "____CHECK____: List of non-whitelisted $2 System Executables:"
  echo ${EXCLUDE_DIRS}
  # Non-zero exit codes in the sub-shell are intentionally suppressed using this variable declaration
  check_home=$(df --local --output=target | tail -n +2 | \
     xargs -I '{}' find '{}' ${EXCLUDE_DIRS} -xdev -type f -perm -$1 -print | \
     grep -e "^/erniedev_data1/home" || echo "")

  for path in $check_home
  do
    parent=$(echo $path | cut -d/ -f 1-4)
    if [[ $(stat -c "%a" $parent) == 700 ]]; then
      [[ ${FINAL_EXCLUDE_DIRS} ]] && FINAL_EXCLUDE_DIRS="${FINAL_EXCLUDE_DIRS} " || FINAL_EXCLUDE_DIRS="${EXCLUDE_DIRS} "
      FINAL_EXCLUDE_DIRS="${FINAL_EXCLUDE_DIRS}-not -path $path"
    fi
  done
  [[ -z ${FINAL_EXCLUDE_DIRS} ]] && FINAL_EXCLUDE_DIRS="${EXCLUDE_DIRS}"

  local execs=$(df --local --output=target | \
     tail -n +2 | \
     xargs -I '{}' find '{}' "${FINAL_EXCLUDE_DIRS}" -xdev -type f -perm -$1 -print | \
     grep -F --line-regexp --invert-match \
        --file"=${absolute_script_dir}/server-white-lists/$2_executables_white_list.txt")

  if [[ -n "${execs}" ]]; then
    cat <<HEREDOC
Check FAILED for:
${execs}

1. Ensure that no rogue programs have been introduced into the system.
2. Add legitimate items to the white list ($2_executables_white_list.txt).
HEREDOC
    exit 1
  fi
  echo "Check PASSED"
  printf "\n\n"
}