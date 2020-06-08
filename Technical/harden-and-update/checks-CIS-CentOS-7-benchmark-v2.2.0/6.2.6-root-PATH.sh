#!/usr/bin/env bash
set -e
set -o pipefail
echo "6.2.6 Ensure root PATH Integrity"
echo -e "____CHECK____"
if [[ "$PATH" == *::* ]]; then
  echo "Check FAILED, correct this!"
  echo "Empty Directory in PATH \(::\)"
  exit 1
fi

if [[ "${PATH: -1}" == ":" ]]; then
  echo "Check FAILED, correct this!"
  echo "Trailing ':' in PATH"
  exit 1
fi

_IFS="$IFS"; IFS=':'
for item in $PATH; do
  if [[ "$item" == "." ]]; then
    echo "PATH contains ."
    echo "Check FAILED, correct this!"
    exit 1
  fi

  if [[ ! -d $item ]]; then
    echo "$item is not a directory"
    echo "Check FAILED, correct this!"
    exit 1
  fi

  dirperm=$(ls -ldH "$item" | cut -f1 -d"" "")
  if [ "$(echo "$dirperm" | cut -c6)" != "-" ]; then
    echo "Group Write permission set on directory $item"
    echo "Check FAILED, correct this!"
    exit 1
  fi
  if [ "$(echo "$dirperm" | cut -c9)" != "-" ]; then
    echo "Other Write permission set on directory $item"
    echo "Check FAILED, correct this!"
    exit 1
  fi

  dirown=$(ls -ldH "$item" | awk '{print $3}')
  if [ "$dirown" != "root" ]; then
    echo "$item is not owned by root"
    echo "Check FAILED, correct this!"
    exit 1
  fi
done
IFS="$_IFS"
echo "Check PASSED"
printf "\n\n"