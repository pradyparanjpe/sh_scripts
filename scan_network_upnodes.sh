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

# Scan Up Nodes


. "$(dirname "${0}")/common.sh" || exit 127


set_vars() {
    ip_range=0
    startip=2
    stopip=254
    down=false
    usage="
    usage:
    $0 IPRANGE STARTIP STOPIP"
    help_msg="${usage}

    DESCRIPTION:
    ping ip in 192.168.IPRANGE.* and report responding nodes

    Positional Arguments:
    IPRANGE\tpenultimate 8 bits [default=${ip_range}]
    STARTIP\tstarting node to scan [default=${startip}]
    STOPIP\tlast node to scan [default=${stopip}]

    Optional Arguments:
    -h\t\tPrint usage and exit
    --help\tPrint this help message and exit
    -d|--down\tPrint 'down' IPs as !down!
"
}

unset_vars() {
    unset ip_range
    unset startip
    unset stopip
    unset help_msg
    unset down
    unset usage
}


cli () {
    pos=
    while [ $# -gt 0 ]; do
        case "$1" in
            -h)
                unset pos
                clean_exit 0 "${usage}"
                ;;
            --help)
                unset pos
                clean_exit 0 "${help_msg}"
                ;;
            -d|--down)
                down=true
                shift 1
                ;;
            *)
                if [ -n "${pos}" ]; then
                    pos="${pos} ${1}"
                else
                    pos="${1}"
                fi
                shift 1
                ;;
        esac
    done
    # shellcheck disable=SC2086  # virbatim
    set -- $pos
    case $# in
        3)
            read -r ip_range startip stopip << EOF
$*
EOF
            ;;
        2)
            read -r ip_range startip << EOF
$*
EOF
            ;;
        1)
            ip_range="${1}"
            ;;
        0)
            ;;
        *)
            clean_exit 1 "${usage}"
            ;;
    esac
    if [ "$ip_range" -gt 255 ] || [ "$ip_range" -lt 0 ]; then
        clean_exit 1 "bad IPRANGE: ${ip_range}"
    fi
    if [ "$stopip" -gt 255 ] || [ "$stopip" -lt 0 ]; then
        clean_exit 1 "bad STOPIP: ${stopip}"
    fi
    if [ "$startip" -gt "${stopip}" ] || [ "$startip" -lt 0 ]; then
        clean_exit 1 "bad STARTIP: ${startip}"
    fi
    unset pos
}

scan () {
    printf "Scanning 192.168.%s.%s to 192.168.%s.%s\n" "${ip_range}" \
           "${startip}" "${ip_range}" "${stopip}"
    printf "The following ip addresses are up:\n"
    if ${down}; then
        printf "OR !down!:\n"
    fi
    printf ""

    for testip in $(seq "$startip" "$stopip"); do
        isdown="$(ping -c 1 "192.168.${ip_range}.${testip}" -w 1 -q)";
        if [ "${isdown#*100}" = "${isdown}" ]; then
            printf "%s\t" "${testip}";
        elif ${down}; then
            printf "!%s!\t" "${testip}";
        fi;
    done;
    printf "\n"
}

main() {
    set_vars
    cli "$@"
    scan
    clean_exit
}

main "$@"
