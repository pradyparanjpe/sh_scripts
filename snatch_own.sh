#!/usr/bin/env sh
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

set_var() {
    # Variables
    robber="$(logname)"
    syndicate=
    recurse=false
    verbose=false
    usage="usage: $0 [-h|--help] [-R] [-v] [-u|--user ROBBER] \
[-g|--group SYNDICATE] TARGET"
    help_msg="

Snatch Ownership

Optional Arguments
-h|--help\t\tprint this message and exit
-R\t\t\tapply recursive
-v\t\t\tverbose outout
-u|--user ROBBER\tgive ownership to ROBBER [default: ${robber}]
-g|--group SYNDICATE\tgroup ownership [default: ROBBER's primary]

Positional Argument

target

"
}

unset_var () {
    unset robber
    unset syndicate
    unset recurse
    unset verbose
    unset help_msg
    unset usage
}

clean_exit() {
    unset_var
    if [ -z "$1" ]; then
       exit 0
    else
        exit "${1}"
    fi
}

get_cli() {
    [ $# -eq 0 ] && printf "%s\n" "$usage" >&2 && clean_exit 1
    while test $# -ge 1; do
        case $1 in
            -h|--help)
                printf "%s\n" "${usage}"
                # shellcheck disable=SC2059
                printf "${help_msg}\n"
                clean_exit;
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
                target="${target}${1}"
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
        printf "%s\n" "${usage}" >&2
        clean_exit 1
    fi

    if [ ! -e "${target}" ]; then
        printf "  [ERROR] Confirm that %s exists.\n" "${target}" >&2
        clean_exit 127
    fi

    if ! id -u "${robber}" >> /dev/null; then
        printf "[ERROR]   Confirm that the %s exists.\n" "${robber}" >&2
        clean_exit 127
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
    set_var
    get_cli "$@"
    sanity_check
    prep_command
}

main "$@"
clean_exit
