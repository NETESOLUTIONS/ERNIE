#!/usr/bin/env bash

########################################
# Update or insert a value in a file
# Arguments:
#   $1  line prefix expression (ERE)
#   $2  replacement
#   $3  file
# Returns:
#   None
# Examples:
#   upsert 'foo=' 'foo=bar' file
#   upsert '#*foo=' 'foo=bar' /tmp/test
# See https://superuser.com/questions/590630/sed-how-to-replace-line-if-found-or-append-to-end-of-file-if-not-found
########################################
upsert() {
  local file="$3"
  backup "$file"

  # If a line matches just copy it to the hold space (`h`) then substitute the value (`s`).
  # On the last line (`$`): exchange (`x`) hold space and pattern space then check if the latter is empty. If it's not
  # empty, it means the substitution was already made. If it's empty, that means no match was found so replace the
  # pattern space with the desired variable=value then append to the current line in the hold buffer. Finally,
  # exchange again (`x`).
  sed --in-place --regexp-extended "/^$1/{
h
s/$1.*/$2/
}
\${
x
/^\$/{
s//$2/
H
}
x
}" "$file"
}