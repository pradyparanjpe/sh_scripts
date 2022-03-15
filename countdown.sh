#!/usr/bin/env sh
# -*- coding:utf-8; mode: shell-script -*-
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


# shellcheck disable=SC1091
. "$(dirname "${0}")/common.sh" || exit 127

set_vars () {
    max_bar=$(($(tput cols)-30))
    byob="\033[93;40m"
    yob="\033[1;33;40m"
    brob="\033[91;40m"
    rob="\033[1;31;40m"
    bgob="\033[92;40m"
    gob="\033[1;32;40m"
    hltime="\033[m"
    colors=true
    resolution=1
    notify=false
    progress=false
    period=
    as_time=false
    usage="
    usage:
    ${0} -h
    ${0} --help
    ${0} [-p|progress] [-n|--notify] [-u N|--update N] [-t|--time] PERIOD
"
    help_msg="${usage}

    DESCRIPTION:
    Display a countdown timer on STDOUT, that updates every second

    Optional Arguments
    -h\t\t\tPrint command usage guide and exit
    --help\t\tPrint this detailed message and exit
    -b|--bland\t\tPrint bland (without colours) output
    -n|--notify\t\tSend desktop notification
    -p|--progress\tShow progress bar
    -t|--time\t\tTreat the positional argument as target time
    -u N|--update N\tUpdate every N seconds

    Positional Argument
    PERIOD\t\tPeriod in seconds to count down.
    \t\t\t[This is parsed using \033[0;31m$(which date)\033[m]
    "
    load_default_config || true
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
    unset notify
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
                colors=false
                shift
                ;;
            -n|--notify)
                notify=true
                shift
                ;;
            -p|--progress)
                progress=true
                shift
                ;;
            -u|--update)
                shift
                resolution="${1}"
                shift
                ;;
            -t|--time)
                as_time=true
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
    if [ "$(( resolution * 2 ))" -gt "${period}" ]; then
        resolution=1
    fi
    while [ "$period" -gt 0 ]; do
        if ${colors}; then
            color_hl "${period}"
            printf "${hltime}%21s seconds " "${period}"
        else
            printf "%21s seconds " "${period}"
        fi
        if ${progress}; then
            bar_len=$(( period * max_bar / max_period ))
            blank_len=$(( max_bar - bar_len ))
            printf "%${bar_len}s" | tr " " "_"
            printf "%${blank_len}s"
        fi
        printf "\r"
        sleep "${resolution}"
        period=$(( period - resolution ))
        if [ "$(( resolution * 2 ))" -gt "${period}" ]; then
            resolution=1
        fi
    done
    printf "\033[m\a"
    if ${notify} && [ -n "${DISPLAY}" ]; then
        notify-send "Countdown ${max_period} seconds"
    fi
    unset max_period
    unset bar_len
    unset blank_len
}

main() {
    check_dependencies "date" "tr"
    set_vars
    cli "$@"
    if ${as_time}; then
        get_period "${period}"
    fi
    disp_count "${period}"
    clean_exit
}

main "$@"
