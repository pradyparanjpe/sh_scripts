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
        if builtin command -v "${dep}" >/dev/null 2>&1; then
            return
        fi
    done
    clean_exit 127 "none of $* found"
}

check_dependencies() {
    for dep in "$@"; do
        if ! builtin command -v "${dep}" >/dev/null 2>&1; then
            clean_exit 127 "${dep} not found"
        fi
    done
}
