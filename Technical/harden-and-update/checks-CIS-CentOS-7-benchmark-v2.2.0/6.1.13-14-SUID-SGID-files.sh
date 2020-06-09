#!/usr/bin/env bash
set -e
set -o pipefail
#echo "6.1.10 Ensure no world writable files exists"
#echo "6.1.11 Ensure no unowned files or directories exist"
#echo "6.1.12 Ensure no ungrouped files or directories exist"
echo "6.1.13 Audit SUID executables"
echo "6.1.14 Audit SGID executables"

readonly SUID_WHITELIST="${ABSOLUTE_SCRIPT_DIR}/server-whitelists/SUID-whitelist.txt"
readonly SGID_WHITELIST="${ABSOLUTE_SCRIPT_DIR}/server-whitelists/SGID-whitelist.txt"

echo "____CHECK____"
echo "Scanning all drives. Please, wait..."
[[ "$FIND_EXCLUDE_DIR_OPTION" ]] && echo "(excluding the directories via: '${FIND_EXCLUDE_DIR_OPTION}')"

readonly GREP_PIPELINE_INDEX=3
# `find -xdev`: don't descend directories on other filesystems
# `find -perm /{bits}`: *any* of the permission bits mode are set for the file.
# shellcheck disable=SC2086 # Don't quote `exclude_dir_option` to expand it into multiple params
coproc { df --local --output=target \
  | tail -n +2 \
  | xargs -I '{}' find '{}' ${FIND_EXCLUDE_DIR_OPTION} -xdev -type f \
        -perm "/u=s,g=s" -ls 2> /dev/null;
#        \( -perm "/u=s,g=s,o=w" -or -nouser -or -nogroup \) -ls 2> /dev/null;
}
# As of Bash 4, `COPROC_PID` has to be saved before it gets reset on process termination
_co_pid=$COPROC_PID
while read -r inode blocks perms number_of_links_or_dirs owner group size month day time_or_year file; do
#  # A world-writeable file?
#  if [[ "$perms" == ????????w? ]]; then
#    if [[ ! $check_failed ]]; then
#      check_failed=true
#      echo "Check FAILED, correcting ..."
#      echo "____SET____"
#    fi
#    chmod -v -v o-w "${file}"
#  fi
#
#  # An unowned or ungrouped file?
#  if [[ $owner == +([0-9]) || $group == +([0-9]) ]]; then
#    if [[ ! $check_failed ]]; then
#      check_failed=true
#      echo "Check FAILED, correcting ..."
#      echo "____SET____"
#    fi
#    chown -v "${DEFAULT_OWNER_USER}":"${DEFAULT_OWNER_GROUP}" "$file"
#  fi

  # An SUID or SGID file?

  unset suid_file
  # `$perms == ???s*` matching e.g. `-rwsr-xr-x` is equivalent to `-u "$file"`
  [[ "$perms" == ???s* ]] && suid_file=true

  unset sgid_file
  # `$perms == ??????s*` matching e.g. `-rwx--s--x` is equivalent to `-g "$file"`
  [[ "$perms" == ??????s* ]] && sgid_file=true

  # TBD Grepping each failed file is not very efficient
  if [[ "$suid_file" == true ]] && ! grep -F --line-regexp --quiet "$file" "${SUID_WHITELIST}" || \
     [[ "$sgid_file" == true ]] && ! grep -F --line-regexp --quiet "$file" "${SGID_WHITELIST}"; then
    if [[ ! $check_failed_fatally ]]; then
      check_failed_fatally=true
      cat << HEREDOC
Check FAILED...
* Ensure that no rogue programs have been introduced into the system.
* Add legitimate items to the white list(s):
** SUID: to "$SUID_WHITELIST"
** SGID: to "$SGID_WHITELIST"
HEREDOC
    fi
    [[ "$suid_file" == true ]] && printf 'SUID: '
    [[ "$sgid_file" == true ]] && printf 'SGID: '
    echo "$file"
  fi
done <& "${COPROC[0]}"
wait "$_co_pid"
if [[ $check_failed_fatally ]]; then
  exit 1
fi
#if [[ ! $check_failed ]]; then
#  echo "Check PASSED"
#fi
printf "\n\n"
