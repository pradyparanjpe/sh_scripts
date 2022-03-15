#!/usr/bin/env sh
#-*- coding: utf-8; mode: shell-script; -*-
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

# common functions used by all shell scripts


clean_exit() {
    if [ -n "${1}" ] && [ "${1}" -ne "0" ]; then
        if [ -n "${2}" ]; then
            # shellcheck disable=SC2059
            printf "${2}\n" >&2
        fi
        # shellcheck disable=SC2086
        exit ${1}
    fi
    if [ -n "${2}" ]; then
        # shellcheck disable=SC2059
        printf "${2}\n"
    fi
    exit 0
}


check_one() {
    for dep in "$@"; do
        if command -v "${dep}" >/dev/null 2>&1; then
            return
        fi
    done
    clean_exit 127 "none of [$*] found"
}

check_dependencies() {
    for dep in "$@"; do
        if ! command -v "${dep}" >/dev/null 2>&1; then
            clean_exit 127 "'${dep}' not found"
        fi
    done
}

posix_rename() {
    # $1: target strings
    # $2: substring to be replaced
    # $3: substring to put
    if [ "${2}" = "${3}" ]; then
        printf "%s" "${1}"
        return
    fi
    if [ ! "${2#*${3}}" = "${2}" ]; then
        temp="$(posix_rename "${1}" "${2}" "___")"
        target="$(posix_rename "${temp}" "___" "${3}")"
        printf "%s" "${target}"
        return
    fi
    target="${1}"
    while [ ! "${target}" = "${target#*${2}}" ]; do
        target="${target%%${2}*}${3}${target#*${2}}"
    done
    printf "%s" "${target}"
}


load_default_config() {
    # load default settings from XDG_CONFIG_HOME/sh_scripts/config.sh
    var_before="$(mktemp)"

    set > "${var_before}"
    if [ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/sh_scripts/config.sh" ]; then
        . "${XDG_CONFIG_HOME:-${HOME}/.config}/sh_scripts/config.sh" || return
    else
        rm -f "${var_before}"
        return
    fi
    var_after="$(mktemp)"
    var_default="$(mktemp)"
    set > "${var_after}"

    prefix="$(basename "${0%%.sh}")"
    new_vars="$(diff "${var_before}" "${var_after}" | cut -d ' ' -f 2)"
    script_vars="$(printf "%s" "${new_vars}" | grep "${prefix}" | tr -d "'")"

    for var in $script_vars; do
        printf "%s\n" "${var#*${prefix}_}" >> "${var_default}"
    done

    # shellcheck disable=SC1090
    . "${var_default}"

    # sanitize
    rm -f "${var_before}"
    rm -f "${var_after}"
    rm -f "${var_default}"

    for var in $new_vars; do
        if [ ! "${var%%=*}" = "${var}" ]; then
            unset "${var%%=*}"
        fi
    done

    unset var_before
    unset var_after
    unset var_default
    unset var
    unset new_vars
    unset script_vars
    unset prefix
}
