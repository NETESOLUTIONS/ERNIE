#!/usr/bin/env bash

##################################################################################
# Check end user home directories to ensure a file is not there. Fail if it does.
#
# Arguments:
#   $1  file
#
# Returns:
#   None
#
# Examples:
#   ensure_no_home_dir_files /etc/cron.deny
##################################################################################
ensure_no_home_dir_files() {
  local file_name="$1"

  echo "____CHECK____"
  grep -E -v '^(root|halt|sync|shutdown)' /etc/passwd \
    | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' \
    | while read -r user dir; do
      file="$dir/$file_name"
      if [[ ! -h "$file" && -f "$file" ]]; then
        # if file exists and is not a symbolic link
        echo "Check FAILED, correct this!"
        echo "$file exists"
        exit 1
      fi
    done
  echo "Check PASSED"
  printf "\n\n"
}
export -f ensure_no_home_dir_files

