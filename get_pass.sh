#!/usr/bin/env sh
# -*- coding: utf-8; mode: shell-script -*-
#
# Copyright 2021 Pradyumna Paranjape
# This file is part of Prady_sh_scripts.
#
# Prady_sh_scripts is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Prady_sh_scripts is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Prady_sh_scripts.  If not, see <https://www.gnu.org/licenses/>.


# This serves as a helper script for providing secrets


set_vars () {
    instance=
    usage="
    usage: ${0} -h
    usage: ${0} --help
    usage: ${0} [Optional Arguments*] INSTANCE
"
    help_msg="${usage}

    DESCRIPTION: |
      Fetch password from password-store


    Optional Arguments: |
      -h\t\t\tprint usage message and exit
      --help\t\t\tprint this help message and exit


    Optional Positional Argument: |
      INSTANCE\tfetch password from password store for INSTANCE
"
}

unset_vars() {
    unset help_msg
    unset usage
    unset instance
}

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

fail () {
    printf " failed"
    clean_exit 1 "failed: %s\n" "${1}"
}

cli () {
    while [ $# -gt 0 ]; do
        case "${1}" in
            -h)
                # shellcheck disable=SC2059
                clean_exit 0 "${usage}"
                ;;
            --help)
                # shellcheck disable=SC2059
                clean_exit 0 "${help_msg}"
                ;;
            *)
                if [ -z "${instance}" ]; then
                    instance="${1}"
                else
                    instance="${instance} ${1}"
                fi
                shift
                ;;
        esac
    done
    if [ -z "${instance}" ]; then
        clean_exit 1 "Error: instance not specified\n"
    fi
}

get_pass () {
    git -C "${PASSWORD_STORE_DIR:-${HOME}/.password-store}" pull \
        1>/dev/null 2>&1
    pass show "${instance}" | head -n 1
}

main() {
    set_vars
    cli "$@"
    get_pass
    clean_exit
}

main "$@"
