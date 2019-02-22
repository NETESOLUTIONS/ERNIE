#!/usr/bin/env bash
set -e
set -o pipefail
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
  case $(uname) in
    Darwin) local sed_options="-i '' -E" ;;
    Linux) local sed_options="--in-place --regexp-extended" ;;
  esac

  # If a line matches just copy it to the `h`old space then `s`ubstitute the value.
  # On the la`$`t line: e`x`change hold space and pattern space then check if the latter is empty. If it's not empty, it
  # means the substitution was already made. If it's empty, that means no match was found so replace the pattern space
  # with the desired variable=value then append to the current line in the hold buffer. Finally, e`x`change again.
  sed ${sed_options} "/^$1/{
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
}" $3
}