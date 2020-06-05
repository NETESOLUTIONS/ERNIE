#!/usr/bin/env bash
echo "6.1.11 Ensure no unowned files or directories exist"
echo "6.1.12 Ensure no ungrouped files or directories exist"
echo "____CHECK____"
if [[ $exclude_dirs ]]; then
  echo "Excluding: ${exclude_dirs[*]}"
  printf -v EXCLUDE_DIR_OPTION -- '-not -path *%s/* ' "${exclude_dirs[@]}"
fi

unset issues_found
# -xdev Don't descend directories on other filesystems
# shellcheck disable=SC2086 # Expanding EXCLUDE_DIR_OPTION into multiple parameters
df --local --output=target \
  | tail -n +2 \
  | xargs -I '{}' find '{}' ${EXCLUDE_DIR_OPTION} -xdev -type f \( -nouser -or -nogroup \) -ls \
  | while read -r inode blocks perms number_of_links_or_dirs owner group size month day time_or_year filename; do
    if [[ ! $issues_found ]]; then
      echo "Check FAILED"
      echo "____SET____"
      issues_found=true
    fi

#    echo -e "$filename $owner $group $size $month $day $time_or_year" | tee -a ownership_issues.log
    chown -v "${DEFAULT_OWNER_USER}":"${DEFAULT_OWNER_GROUP}" "$filename"
  done
# df --local -P | awk {'if (NR!=1) print $6'}