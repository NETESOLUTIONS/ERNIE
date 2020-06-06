#!/usr/bin/env bash
echo "6.1.13 Audit SUID executables"
echo "6.1.14 Audit SGID executables"

readonly SUID_WHITELIST="${ABSOLUTE_SCRIPT_DIR}/server-whitelists/SUID-whitelist.txt"
readonly SGID_WHITELIST="${ABSOLUTE_SCRIPT_DIR}/server-whitelists/SGID-whitelist.txt"

echo "____CHECK____"
echo "Scanning all drives, excluding ${exclude_dirs[*]}. Please, wait..."
printf -v exclude_dir_option -- '-not -path *%s/* ' "${exclude_dirs[@]}"

unset check_failed
readonly GREP_PIPELINE_INDEX=3
# `find -xdev`: don't descend directories on other filesystems
# `find -perm /{bits}`: *any* of the permission bits mode are set for the file.
# shellcheck disable=SC2086 # Don't quote `exclude_dir_option` to expand it into multiple params
coproc { df --local --output=target \
  | tail -n +2 \
  | xargs -I '{}' find '{}' ${exclude_dir_option} -xdev -type f -perm "/u=s,g=s" -print 2> /dev/null;
}
# As of Bash 4, `COPROC_PID` has to be saved before it gets reset on process termination
_co_pid=$COPROC_PID
while IFS= read -r file; do
  if [[ -u "$file" ]] && ! grep -F --line-regexp --quiet "$file" "${SUID_WHITELIST}" || \
     [[ -g "$file" ]] && ! grep -F --line-regexp --quiet "$file" "${SGID_WHITELIST}"; then
    if [[ ! $check_failed ]]; then
      check_failed=true
      cat << HEREDOC
Check FAILED...
* Ensure that no rogue programs have been introduced into the system.
* Add legitimate items to the white list(s):
** SUID: to "$SUID_WHITELIST"
** SGID: to "$SGID_WHITELIST"
HEREDOC
    fi
    [[ -u "$file" ]] && printf 'SUID: '
    [[ -g "$file" ]] && printf 'SGID: '
    echo "$file"
  fi
done <& "${COPROC[0]}"
wait "$_co_pid"
if [[ $check_failed ]]; then
  exit 1
else
  echo "Check PASSED"
  printf "\n\n"
fi