#!/usr/bin/env bash

########################################
# Update or insert a value in a file
# Arguments:
#   $1  key: an ERE expression. It is matched at the beginning of a file line: as `^{key}`.
#   $2  replacement value
#   $3  file
# Returns:
#   None
# Examples:
#   upsert 'IgnoreRhosts ' 'IgnoreRhosts yes' /etc/ssh/sshd_config
#   upsert '#*Banner ' 'Banner /etc/issue.net' /etc/ssh/sshd_config
# See https://superuser.com/questions/590630/sed-how-to-replace-line-if-found-or-append-to-end-of-file-if-not-found
########################################
upsert() {
  # Escape all `/` as `\/`
  local -r key="${1//\//\/}"
  local value="$2"
  local -r file="$3"

  if [[ -s "$file" ]]; then
    # Escape all `/` as `\/`
    value="${value//\//\/}"

    backup "$file"

    # If a line matches just copy it to the hold space (`h`) then substitute the value (`s`).
    #
    # On the last line (`$`): exchange (`x`) hold space and pattern space then check if the latter is empty. If it's not
    # empty, it means the substitution was already made. If it's empty, that means no match was found so replace the
    # pattern space with the desired variable=value then append to the current line in the hold buffer.
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
  else
    # No file or empty file
    echo "$value" > "$file"
  fi
}