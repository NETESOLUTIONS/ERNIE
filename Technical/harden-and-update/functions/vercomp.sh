#!/usr/bin/env bash

########################################################################################################################
# Compares semantic versions
# Courtesy: https://stackoverflow.com/a/4025065/534217
#
# Arguments:
#   $1 semantic version 1
#   $2 semantic version 2
#
# Returns:
#   0 =
#   1 >
#   2 <
#
# Examples:
#   1 = 1
#   2.1 < 2.2
#   3.0.4.10 > 3.0.4.2
#   4.08 < 4.08.01
#   3.2.1.9.8144 > 3.2
#   3.2 < 3.2.1.9.8144
#   1.2 < 2.1
#   2.1 > 1.2
#   5.6.7 = 5.6.7
#   1.01.1 = 1.1.1
#   1.1.1 = 1.01.1
#   1 = 1.0
#   1.0 = 1
#   1.0.2.0 = 1.0.2
#   1..0 = 1.0
#   1.0 = 1..0
########################################################################################################################
vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}
export -f vercomp