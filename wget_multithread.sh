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

# wget multiple threads

set_vars() {
    threads=1
    logfilename=/dev/stdout
    usage="Usage: wget_multithreaded.sh [-h] [-t] ..."
    help_msg="
Optional Arguments:
-t N\t\tinitiate N threads [default: ${threads}]
-l STRING\tSave log in STRING.wget_log [defailt: ${logfilename}]

All trailing arguments are passed on to wget
"
}

unset_vars() {
    unset usage
    unset help_msg
}

clean_exit() {
    unset_vars
    if [ -z "$1" ]; then
        exit 0;
    else
        exit "$1"
    fi
}


cli () {
    while getopts ":ht:l:" optname; do
        case $optname in
            "h"|"help")
                printf "%s\n" "${usage}"
                # shellcheck disable=SC2059
                printf "${help_msg}"
                clean_exit
                ;;
            "t")
                threads=$OPTARG
                ;;
            "l")
                logfilename="${OPTARG}.wget_log"
                ;;
            "?")
                echo "Illegal option \"$OPTARG\""
                clean_exit 1
                ;;
            ":")
                echo "No Threads specified, using 1 thread"
                threads=1
                ;;
            *)
                "Error while Processing options";
                ;;
        esac
    done
    shift $((OPTIND - 1));
}

call() {
    for _ in $(seq 0 "${threads}"); do
        wget -r -np -N "$@" >>"$logfilename" 2>&1 &
    done;
    unset _
}

main () {
    set_vars
    cli "$@"
    call "$@"
}

main "$@"
clean_exit
