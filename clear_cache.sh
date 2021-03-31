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

# Clear Cache

# This must be run strictly as root


name_colors() {
rok="\033[0;31;40m"  # red on black
gok="\033[0;32;40m"  # green
yok="\033[0;33;40m"  # yellow
bok="\033[0;34;40m"  # blue
dod="\033[m"         # default on default
}


vst() {
    val="$(vmstat -S M | sed -n 3p | sed -r 's/\W+/ /g' | cut -d " " -f 5,6,7)"
    printf "%s" "$val"
    unset val
}


clean_up() {
    unset oldf
    unset old_b
    unset old_c
    unset newf
    unset new_b
    unset new_c
    unset rok
    unset gok
    unset yok
    unset bok
    unset dod
    unset yn
}

clear_buff() {
    echo "Old:"
    printf "Free\tBuffer\tCache\n"
    IFS=" " read -r old_f old_b old_c << EOF
$(vst)
EOF
    printf "${rok}%s\t%s\t%s\n\n" "${old_f}" "${old_b}" "${old_c}"
    # shellcheck disable=SC2059
    printf "${gok}Clearing Buffers${dod}\n"
    sync; echo 3 > /proc/sys/vm/drop_caches
    printf "Buffers Cleared\n\n"
    echo "New:"
    printf "Free\tBuffer\tCache\n"
    IFS=" " read -r new_f new_b new_c << EOF
$(vst)
EOF
    printf "${bok}%s\t%s\t%s\n\n" "${new_f}" "${new_b}" "${new_c}"
    printf "${yok}Cleared %sM buffers " "$((old_b - new_b))"
    printf "and %sM cache${dod}\n" "$((old_c - new_c))"
}

main() {
    if [ "$(id -u)" -ne 0 ]; then
        exec sudo su -c "sh $0 $*"
    fi
    # confirmation
    printf "Clear Buffers? [yes/no]: "
    read -r yn
    case "$yn" in
        [Yy]*)
            name_colors
            clear_buff
            clean_up
            ;;
    esac
}

main "$@"
