#!/usr/bin/env bash
# -*- coding:utf-8 -*-
#
# Copyright 2020 Pradyumna Paranjape
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
# Files in this project contain regular utilities and aliases for linux (Fc31)

function set_var() {
    # Variables
    ROBBER="$(logname)"
    SYNDICATE=
    RECURSE=false
    VERBOSE=false
    USAGE_MESSAGE="$0:
Snatch Ownership

usage:
$0 [-h|--help] [-R] [-v] [-u|--user ROBBER] [-g|--group SYNDICATE] TARGET

Optional Arguments
-h|--help\t\tPrint this message and exit
-R\t\t\tApply recursive
-v\t\t\tVerbose outout
-u|--user ROBBER\tGive ownership to ROBBER [default: ${ROBBER}]
-g|--group SYNDICATE\tGroup ownership [default: ROBBER's primary]

Positional Argument

TARGET
"
}

function unset_var () {
    ROBBER=
    VERBOSE=
    RECURSE=
    SYNDICATE=
    CLI=
}

function get_cli() {
    [[ $# -eq 0 ]] && echo -e "$USAGE_MESSAGE" && exit 0
    while test $# -ge 1; do
        case $1 in
            -h|--help)
                echo -e "${USAGE_MESSAGE}"
                exit 0;
                ;;
            -R)
                RECURSE=true
                ${VERBOSE} && echo "[VERBOSE] SET RECURSIVE"
                shift 1
                ;;
            -v)
                VERBOSE=true
                ${VERBOSE} && echo "[VERBOSE] SET VERBOSE"
                shift 1
                ;;
            -u|--user)
                shift 1
                ROBBER="$1"
                ${VERBOSE} && echo "[VERBOSE] SET ROBBER $ROBBER"
                shift 1
                ;;
            -g|--group)
                shift 1
                SYNDICATE="$1"
                ${VERBOSE} && echo "[VERBOSE] SET SYNDICATE $SYNDICATE"
                shift 1
                ;;
            *)
                TARGET="${TARGET}${1}"
                shift 1
                ;;
        esac
    done
    [[ -z $SYNDICATE ]] && SYNDICATE="$(groups ${ROBBER} | cut -d ":" -f 2 \
| cut -d " " -f 2)"
}

function sanity_check () {
    [[ -z "${TARGET}" ]] && echo -e "${USAGE_MESSAGE}" && exit 0
    [[ ! -e "${TARGET}" ]] \
        && echo -e "  [ERROR] Confirm that ${TARGET} exists." >&2 \
        && exit 2

    if ! id -u "${ROBBER}" >> /dev/null; then
        echo -e "[ERROR]   Confirm that the ${ROBBER} exists" >&2
        exit 1
    fi
}


function prep_command () {
    CLI="chown ${ROBBER}:${SYNDICATE}"
    ${RECURSE} && CLI="${CLI} -R"
    ${VERBOSE} \
        && CLI="${CLI} -v"\
        && echo "[VERBOSE] Snatching ownership of ${TARGET} to\
 ${ROBBER}:${SYNDICATE}"\
        && echo -e "executing\n$CLI $TARGET"
}

function main () {
    set_var
    get_cli "$@"
    sanity_check
    prep_command
    sudo su -c "${CLI} ${TARGET}"
    unset_var
}

main "$@"
