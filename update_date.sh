#!/usr/bin/env sh
# -*- coding: utf-8; mode: shell-script; -*-
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

# retreive, display and/or set current time

# shellcheck disable=SC1091
. "$(dirname "${0}")/common.sh" || exit 127

set_vars() {
    set_time=
    current_time=
    source="gnu.org"
    usage="usage:
    ${0} -h
    ${0} --help
    ${0} [Optional Arguments ...] [SOURCE]"
    help_msg="${usage}

DESCRIPTION:
    Retreive current date and optionally, set current date.
    Further, \033[0;31;40msuper-user\033[m privilege is requested to set time.
    This is especially useful from behind a proxy server.

Optional Arguments:
    -h\t\t\t\tPrint usage message and exit
    --help\t\t\tPrint this help message and exit
    -s|--set-time\t\tSet time [default: offer interactively]
    -g|--get-time\t\tGet time (don't offer to set time)
    -m TIME|--manual TIME\tPass TIME manually


Optional Positional Argument:
    SOURCE\t\t\tsource domain [default: \033[0;32;40m${source}\033[m]"
    load_default_config || true
}

unset_vars() {
    unset help_msg
    unset usage
    unset source
    unset current_time
    unset set_time
}

get_time() {
    current_time="$(curl -H 'Cache-Control:no-cache' -sI ${source} | \
                    grep '^Date:' | cut -d' ' -f3-6)Z"
    if [ "${current_time}" = "Z" ]; then
        clean_exit 1 "Date couldn't be retreived, \
check the domain \033[3;40;31m${source}\033[m"
    fi
}

cli () {
    while test $# -gt 0; do
        case "${1}" in
            -h)
                clean_exit 0 "${usage}"
                ;;
            --help)
                clean_exit 0 "${help_msg}"
                ;;
            -g|--get-time)
                set_time=false
                shift
                ;;
            -s|--set-time)
                set_time=true
                shift
                ;;
            -m|--manually|-m=*|--manually=*)
                if [ ! "${1#*=}" = "${1}" ]; then
                    current_time="$(printf "%s" "$1" | cut -d "=" -f 2)"
                else
                    shift
                    current_time="${1}"
                fi
                shift
                source="${USER}"
                ;;
            *)
                source="${1}"
                shift
                ;;
        esac
    done
}

main() {
    check_dependencies "curl"
    set_vars
    cli "$@"
    if [ -z "${current_time}" ]; then
        get_time
    fi
    printf "\033[4;36;40m%s\033[m: " "${source}"
    date -d "${current_time}"
    if [ "${set_time}" = false ]; then
        clean_exit 0
    elif [ -z "${set_time}" ]; then
        printf "Set time? [yes/NO]: "
        read -r yn
        case "$yn" in
            [Yy]*)
                set_time=true
                ;;
            *)
                clean_exit
                ;;
        esac
    fi
    if [ "$(id -u)" -ne 0 ]; then
        exec sudo su -c "sh $0 -m '${current_time}' -s"
    fi
    date --set="${current_time}"
    clean_exit
}

main "$@"
