#!/usr/bin/env sh
# -*- coding:utf-8 -*-
#
# Copyright 2020-2022 Pradyumna Paranjape
#
# This file is part of Prady_sh_scripts.
# Prady_sh_scripts is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Prady_sh_scripts is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Prady_sh_scripts.  If not, see <https://www.gnu.org/licenses/>.
#
# Files in this project contain regular utilities and aliases for linux (fc34)


set_vars() {
    verbose=false
    O_IFS="$IFS"
    srcdir=
    object=
    destin="${PWD}"
    mk_par=false
    usage="usage: $0 [-h|--help] [-p|--parents] [-v|--verbose] OBJECT

    or: $0 <optional arguments> SOURCE OBJECT DESTIN
    or: $0 <optional arguments> DESTIN
"
    help_msg="
Move object from SOURCE to DESTIN and leave a soft link at SOURCE


Optional Arguments:

-h|--help\tprint this message and exit
-p|--parents\tmake parent paths if they don't exist
-v|--verbose\tprint verbose


Optional Positional Argument:

DESTIN\t\tfuture parent path of object [default: ${destin}]
SOURCE\t\tfuture link parent [default: guessed from OBJECT]


Required Positional Argument:

OBJECT\t\tname of object to move and link {<file>|<directory>|...}
"
}


unset_vars() {
    IFS="$O_IFS"
    unset verbose
    unset O_IFS
    unset srcdir
    unset object
    unset destin
    unset mk_par
    unset usage
    unset help_msg
}


clean_exit() {
    unset_vars
    if [ -n "${1}" ] && [ "${1}" -ne "0" ]; then
        if [ -n "${2}" ]; then
            # shellcheck disable=SC2059
            printf "${2}\n" >&2
        fi
        # shellcheck disable=SC2086
        exit ${1}
    fi
    if [ -n "${2}" ]; then
        # shellcheck disable=SC2059
        printf "${2}\n"
    fi
    exit 0
}

cli() {
    [ $# -eq 0 ] && clean_exit 0 "{usage}"
    pos=
    while test $# -gt 0; do
        case $1 in
            -v|--verbose)
                verbose=true
                shift
                ;;
            -p|--parents)
                mk_par=true
                shift
                ;;
            -h|--help)
                printf "%s\n" "${usage}"
                # shellcheck disable=2059
                printf "${help_msg}\n"
                unset pos
                clean_exit 0
                ;;
            *)
                if [ -z "${pos}" ]; then
                    pos="${1}"
                else
                    pos="${pos} ${1}"
                fi
                shift
                ;;
        esac
    done
    if [ -z "${pos}" ]; then
        unset pos
        clean_exit 1 "No positional arguments found.\n\n${usage}\n"
    fi
    # shellcheck disable=SC2086 # setting $* to $pos
    set -- $pos
    case $# in
        1)
            object="${pos}"
            ;;
        2)
            IFS=" " read -r object destin << EOF
${pos}
EOF
            IFS="$O_IFS"
            ;;
        3)
            IFS=" " read -r source object destin << EOF
${pos}
EOF
            IFS="$O_IFS"
            ;;
        *)
            unset pos
            clean_exit 1 "bad usage\nsource: $source\nobject: $object\n\
destin: $destin\n${usage}"
            ;;
    esac
    unset pos
}


auto_complete() {
    # are paths rooted?
    object="$(realpath "${object}")"
    if [ -z "${srcdir}" ]; then
        srcdir="$(dirname "${object}")"
    fi
    srcdir="$(realpath "${srcdir}")"
    destin="$(realpath "${destin}")"

    if $mk_par; then
        mkdir -p "${srcdir}" || clean_exit $?
        mkdir -p "${destin}" || clean_exit $?
    fi
}


sanity() {
    if [ "${srcdir}" = "${destin}" ]; then
        printf "source and distination are both %s\n" "${srcdir}"
        printf "nothing to be done\n"
        clean_exit 0
    fi
    if [ ! -d "${srcdir}" ]; then
        clean_exit 127 "Directory '${srcdir}' doesn't exist. try -p option"
    fi
    if [ ! -d "${destin}" ]; then
        clean_exit 127 "Directory '${destin}' doesn't exist. try -p option"
    fi
    if [ ! -e "${object}" ]; then
        clean_exit 127 "'${object}' doesn't exist."
    fi
}


commands() {
    obj_name="$(basename "${object}")"
    if $verbose; then
        printf "mv -v %s -t %s\n" "${object}" "${destin}"
        printf "ln -s %s/%s %s/%s\n" "${destin}" \
               "${obj_name}" "${srcdir}" "${obj_name}"
    fi
    if $verbose; then
        mv "${object}" -t "${destin}"  || clean_exit $?
    else
        mv -v "${object}" -t "${destin}" || clean_exit $?
    fi
    ln -s "${destin}/${obj_name}" "${srcdir}/${obj_name}"
    unset obj_name
}


main() {
    set_vars
    cli "$@"
    auto_complete
    sanity
    commands
}

main "$@"
clean_exit 0
