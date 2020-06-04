#!/usr/bin/env bash
echo "6.2.10 Ensure users' dot files are not group or world writable"
echo -e "____CHECK____"

unset check_failed
while read -r user dir; do
  for file in "$dir"/.[A-Za-z0-9]*; do
    if [[ ! -h "$file" && -f "$file" ]]; then
      # if file exists and is not a symbolic link

      perm=$(ls -ld "$file" | cut -f1 -d" ")
      if [ $(echo $perm | cut -c6) != "-" ]; then
        echo "Group Write permission set on file $file"
        echo "Check FAILED, correct this!"
        check_failed=true
      fi
      if [ $(echo $perm | cut -c9) != "-" ]; then
        echo "Other Write permission set on file $file"
        echo "Check FAILED, correct this!"
        check_failed=true
      fi
    fi
  done
done < <(grep -E -v '(root|sync|halt|shutdown)' /etc/passwd \
    | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }')
[[ $check_failed == true ]] && exit 1
echo "Check PASSED"

printf "\n\n"