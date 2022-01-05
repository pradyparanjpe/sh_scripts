#!/usr/bin/env sh
# -*- coding:utf-8 -*-
#
# Copyright 2020-2021-2022 Pradyumna Paranjape
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
# Files in this project contain regular utilities and aliases for linux (Fc34)

# countdown timer


. "./common.sh" || exit 127

set_vars () {
    max_bar=$(($(tput cols)-30))
    byob="\033[93;40m"
    yob="\033[1;33;40m"
    brob="\033[91;40m"
    rob="\033[1;31;40m"
    bgob="\033[92;40m"
    gob="\033[1;32;40m"
    hltime="\033[m"
    colors=1
    resolution=1
    progress=
    period=
    as_time=
    usage="
    usage:
    ${0} -h
    ${0} --help
    ${0} [-p|progress] [-u N|--update N] [-t|--time] PERIOD
"
    help_msg="${usage}

    DESCRIPTION:
    Display a countdown timer on STDOUT, that updates every second

    Optional Arguments
    -h\t\t\tPrint command usage guide and exit
    --help\t\tPrint this detailed message and exit
    -b|--bland\t\tPrint bland (without colours) output
    -p|--progress\tShow progress bar
    -t|--time\t\tTreat the positional argument as target time
    -u N|--update N\tUpdate every N seconds

    Positional Argument
    PERIOD\t\tPeriod in seconds to count down.
    \t\t\t[This is parsed using \033[0;31m$(which date)\033[m]
    "
}

unset_vars () {
    unset max_bar
    unset byob
    unset brob
    unset bgob
    unset yob
    unset rob
    unset gob
    unset colors
    unset resolution
    unset progress
    unset period
    unset as_time
    unset usage
    unset help_msg
    unset hltime
}

cli () {
    while test $# -gt 0; do
        case ${1} in
            -h)
                clean_exit 0 "${usage}"
                ;;
            --help)
                clean_exit 0 "${help_msg}"
                ;;
            -b|--bland)
                unset colors
                shift
                ;;
            -p|--progress)
                progress=1
                shift
                ;;
            -u|--update)
                shift
                resolution="${1}"
                shift
                ;;
            -t|--time)
                as_time=1
                shift
                ;;
            *)
                if [ -n "${period}" ]; then
                    period="${period} ${1}"
                else
                    period="${1}"
                fi
                shift
                ;;
        esac
    done
    if [ -z "${period}" ]; then
        clean_exit 2 "${usage}"
    fi
}

get_period () {
    period=$(($(date --date="${period}" +"%s") - $(date +"%s"))) \
        || clean_exit $?
}

color_hl () {
        if [ "${1}" -lt 600 ]; then  # 10 minutes
            if [ "${1}" -lt 60 ]; then  # 1 minute
                if [ "${1}" -lt 10 ]; then  # 10 seconds
                    if [ "${1}" -lt 5 ]; then  # 5 seconds
                        hltime="${brob}"
                    else
                        hltime="${rob}"
                    fi
                    resolution=1
                else
                    hltime="${yob}"
                fi
            else
                hltime="${byob}"
            fi
        elif [ "${1}" -ge 3600 ]; then  # more than 1 hour
            if [ "${1}" -ge 86400 ]; then   # more than 1 day
                hltime="${bgob}"
            else
                hltime="${gob}"
            fi
        else
            hltime="\033[m"
        fi
}

disp_count () {
    # shellcheck disable=SC2086
    if [ "$period" -lt 1 ]; then
        clean_exit 1 "We don't have a time-machine"
    fi
    max_period="${period}"
    # shellcheck disable=SC2086
    while [ "$period" -gt 0 ]; do
        period=$((period - resolution))
        if [ ${period} -le 0 ]; then
            resolution=$((period + resolution))
        fi
        if [ -n "$colors" ]; then
            color_hl "${period}"
            printf "${hltime}%21s seconds" "$((period + resolution))"
        else
            printf "%21s seconds" "$((period + resolution))"
        fi
        bar_len=$((period*max_bar/max_period))
        if [ -n "${progress}" ]; then
            printf " "
            printf "%${bar_len}s" | tr " " "_"
            printf "%$((max_bar-bar_len))s"
        fi
        sleep "${resolution}"
        # shellcheck disable=SC2059
        if [ -n "${progress}" ]; then
            # shellcheck disable=SC2059
            printf "$( printf "%$((max_bar+30))s" " " | tr " " "\b" )"
        else
            printf "$( printf "%29s" " " | tr " " "\b" )"
        fi
    done
    printf "\033[m\a"
    unset max_period
    unset bar_len
}

main() {
    check_dependencies "date"
    set_vars
    cli "$@"
    if [ -n "${as_time}" ]; then
        get_period "${period}"
    fi
    disp_count "${period}"
    clean_exit
}

main "$@"
