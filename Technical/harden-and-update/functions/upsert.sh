#!/usr/bin/env bash

####################################################################################################################
# Update or insert a property value in a file. The inserted line could be appended or prepended.
#
# Arguments:
#   $1     file
#   $2     key: an ERE expression. It is matched at the beginning of a file line: as `^{key}`.
#          When key = `^` no matching is done and the replacement line is *prepended*.
#   $3     replacement line
#
# Returns:
#   None
#
# Examples:
#   upsert /etc/ssh/sshd_config 'IgnoreRhosts ' 'IgnoreRhosts yes'
#   upsert /etc/ssh/sshd_config '#*Banner ' 'Banner /etc/issue.net'
#   upsert /etc/logrotate.d/syslog ^ /var/log/cron
#
# See https://superuser.com/questions/590630/sed-how-to-replace-line-if-found-or-append-to-end-of-file-if-not-found
####################################################################################################################
upsert() {
  local file="$1"
  # Escape all `/` as `\/`
  local -r key="${2//\//\/}"
  local value="$3"
  echo "${file}/'${key}' := '${value}'"
  if [[ -s "$file" ]]; then
    # Escape all `/` as `\/`
    value="${value//\//\/}"

    backup "$file"

    if [[ "$key" == "^" ]]; then
      # no matching is done and the replacement line is *prepended*

      sed --in-place "1i${value}" "$file"
    else
      # If a line matches just copy it to the hold space (`h`) then substitute the value (`s`).
      #
      # On the last line (`$`): exchange (`x`) hold space and pattern space then check if the latter is empty. If it's
      # empty, that means no match was found so replace the pattern space with the desired value (`s`) then append
      # (`H`) to the current line in the hold buffer. If it's not empty, it means the substitution was already made.
      #
      # Finally, exchange again (`x`).
      sed --in-place --regexp-extended "/^${key}/{
          h
          s/${key}.*/${value}/
        }
        \${
          x
          /^\$/{
            s//${value}/
            H
          }
          x
        }" "$file"
    fi
  else
    # No file or empty file
    echo -e "$value" > "$file"
  fi
}
