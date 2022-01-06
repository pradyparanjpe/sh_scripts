#!/usr/bin/env sh
#-*- coding: utf-8; mode: shell-script; -*-

clean_exit() {
    unset_vars
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
