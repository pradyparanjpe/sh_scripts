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

# shellcheck disable=SC1091
. "$(dirname "${0}")/common.sh" || exit 127

set_vars() {
    # Variables
    robber="$(logname)"
    syndicate=
    recurse=false
    verbose=false
    usage="
    usage:
    ${0} -h
    ${0} --help
    ${0} [-R] [-v] [-u|--user ROBBER] [-g|--group SYNDICATE] TARGET
"
    help_msg="${usage}

    Snatch Ownership

    Optional Arguments
    -h\t\t\t\tprint usage message and exit
    --help\t\t\tprint this message and exit
    -R\t\t\t\tapply recursive
    -v\t\t\t\tverbose outout
    -u|--user ROBBER\t\tgive ownership to ROBBER [default: ${robber}]
    -g|--group SYNDICATE\tgroup ownership [default: ROBBER's primary]

    Positional Argument

    TARGET\t\t\tTARGET to be robbed
"
}

unset_vars () {
    unset robber
    unset syndicate
    unset recurse
    unset verbose
    unset help_msg
    unset usage
}

get_cli() {
    [ $# -eq 0 ] && clean_exit 1 "$usage"
    while test $# -ge 1; do
        case $1 in
            -h)
                clean_exit 0 "${usage}"
                ;;
            --help)
                clean_exit 0 "${help_msg}";
                ;;
            -R)
                recurse=true
                ${verbose} && printf "[verbose] set recursive\n"
                shift 1
                ;;
            -v)
                verbose=true
                ${verbose} && printf "[verbose] set verbose\n"
                shift 1
                ;;
            -u|--user)
                shift 1
                robber="$1"
                ${verbose} && printf "[verbose] %s is robber\n" "$robber"
                shift 1
                ;;
            -g|--group)
                shift 1
                syndicate="$1"
                ${verbose} && printf "[verbose] %s is syndicate\n" "$syndicate"
                shift 1
                ;;
            *)
                if [ -z "${target}" ]; then
                    target="${1}"
                else
                    target="${target} ${1}"
                fi
                shift 1
                ;;
        esac
    done
    if [ -z "$syndicate" ]; then
        syndicate="$(groups "${robber}" | cut -d ":" -f 2 | cut -d " " -f 2)"
    fi
}

sanity_check () {
    if [ -z "${target}" ]; then
        clean_exit 1 "{usage}"
    fi

    if [ ! -e "${target}" ]; then
        clean_exit 127 "[ERROR] Confirm that ${target} exists."
    fi

    if ! id -u "${robber}" >> /dev/null; then
        clean_exit 127 "[ERROR] Confirm that the ${robber} exists."
    fi
}


prep_command () {
    cli="chown ${robber}:${syndicate}"
    if ${recurse}; then
        cli="${cli} -R"
    fi
    if ${verbose}; then
        cli="${cli} -v"
        printf "[verbose] Snatching ownership of %s to %s:%s\n" \
"${target}" "${robber}" "${syndicate}"
        printf "executing\n%s %s" "$cli" "$target"
    fi
    sudo su -c "${cli} ${target}"
    unset cli
}


main () {
    set_vars
    get_cli "$@"
    sanity_check
    prep_command
    clean_exit
}

main "$@"
