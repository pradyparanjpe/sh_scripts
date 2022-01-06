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

# Clear Cache

# This must be run strictly as root

. "$(dirname "${0}")/common.sh" || exit 127

set_vars() {
    confirmed=
    old_b=
    old_c=
    new_f=
    new_b=
    new_c=
    rok="\033[0;31;40m"  # red on black
    gok="\033[0;32;40m"  # green
    yok="\033[0;33;40m"  # yellow
    bok="\033[0;34;40m"  # blue
    dod="\033[m"         # default on default
    usage="
    usage:
    ${0} -h
    ${0} --help
    ${0} [-y|--assumeyes] [-n|--assumeno]"
    help_msg="${usage}

    DESCRIPTION:
    Clear cache by passing '3' to ${rok}/proc/sys/vm/drop_caches${dod}
    After confirmation, ${rok}super-user${dod} privileges will be requested.

    Optional Arguements:
    -h\t\t\tprint usage message and exit
    --help\t\tprint this help message and exit
    -y|--assumeyes\tdon't prompt, assume yes to all
    -n|--assumeno\tdon't prompt, assume no to all
    "
}


unset_vars() {
    unset confirmed
    unset old_b
    unset old_c
    unset new_f
    unset new_b
    unset new_c
    unset rok
    unset gok
    unset yok
    unset bok
    unset dod
    unset yn
    unset help_msg
    unset usage
}


vst() {
    val="$(vmstat -S M | sed -n 3p | sed -r 's/\W+/ /g' | cut -d " " -f 5,6,7)"
    printf "%s" "$val"
    unset val
}


show_free () {
    printf "Free\tBuffer\tCache\n"
    IFS=" " read -r new_f new_b new_c << EOF
$(vst)
EOF
    printf "${1}%s\t%s\t%s\n\n${dod}" "${new_f}" "${new_b}" "${new_c}"
}

clear_buff() {
    old_b="${new_b}"
    old_c="${new_c}"
    # shellcheck disable=SC2059
    printf "${gok}Clearing Buffers${dod}\n"
    sync
    echo 3 > /proc/sys/vm/drop_caches
    printf "Buffers Cleared\n\n"
    show_free "${bok}"
    printf "${yok}Cleared %sM buffers " "$((old_b - new_b))"
    printf "and %sM cache${dod}\n" "$((old_c - new_c))"
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
            -y|--assumeyes)
                confirmed=true
                shift
                ;;
            -n|--assumeno)
                confirmed=false
                shift
                ;;
            *)
                clean_exit 2 "${usage}"
                ;;
        esac
    done
}

main() {
    check_dependencies "vmstat"
    set_vars
    cli "$@"
    show_free "${rok}"
    if [ "${confirmed}" = false ]; then
        clean_exit
    elif [ -z "${confirmed}" ]; then
        printf "Clear Buffers? [yes/NO]: "
        read -r yn
        case "$yn" in
            [Yy]*)
                confirmed=true
                ;;
            *)
                clean_exit
                ;;
        esac
    fi
    if [ "$(id -u)" -ne 0 ]; then
        exec sudo su -c "sh $0 -y"
    fi
    clear_buff
    clean_exit
}

main "$@"
