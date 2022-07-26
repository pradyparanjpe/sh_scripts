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
# Files in this project contain regular utilities and aliases for linux (Fc36)

# countdown timer

# shellcheck disable=SC1091
. "$(dirname "${0}")/common.sh" || exit 127

set_cmds() {
    # shellcheck disable=SC2034
    denial="
    THIS *DOES* NOTHING.

    [WITH CAUTION]: All commands can be sequentially executed. This WILL fail.

    This script only lists commands necessary to be run to updates. Fc36."
    # shellcheck disable=SC2034

    dnf_cmd="sudo su -l -c \"dnf --refresh -y update\""
    # shellcheck disable=SC2034

    # shellcheck disable=SC2154
    # shellcheck disable=SC2034
    clamav_cmd="sudo su -l -c \"all_proxy=\${all_proxy} freshclam\""

    cargo_cmd="cargo-install-update install-update --all && cargo-cache -a"
    # use pspman rather (when fixed)
    # shellcheck disable=SC2034

    spacemacs_cmd="git -C \"\${XDG_DATA_HOME:-\${HOME}/.local/share}\
/pspman/src/spacemacs/\" pull"

    # shellcheck disable=SC2034
    nvim_cmd="nvim +CocUpdate +PlugUpdate"

    # shellcheck disable=SC2034
    emacs_cmd="emacs \
--batch \
-l \"\${XDG_CONFIG_HOME:-\${HOME}/.config}/emacs/init.el\" \
--eval=\"(configuration-layer/update-packages t)\" \
--kill"

    all_cmds="dnf_cmd clamav_cmd cargo_cmd spacemacs_cmd nvim_cmd emacs_cmd"
}

set_vars() {
    usage="
    usage:
    ${0} -h
    ${0} --help
    ${0} [-e|--execute]
"
    help_msg="${usage}

    DESCRIPTION:
    Display commands necessary to execute updates.

    Optional Arguments
    -h\t\t\tPrint command usage guide and exit
    --help\t\tPrint this detailed message and exit
    -e|--execute\tExecute all commands sequentially

    "
    execute=false
    set_cmds
    load_default_config || true
}

unset_vars() {
    unset denial
    for cmd in $all_cmds; do
        unset "${cmd}"
    done
    unset cmd
    unset all_cmds
    unset execute
    unset help_msg
    unset usage
}

cmd_printer () {
    # $1: name, $2: cmd
    printf "%s:\n" "${1}"
    val="$(posix_var_expand "${1}")"
    printf "\t%s\n\n" "${val}"
}

exec_str () {
    # $1: cmd_var
    cmd="$(posix_var_expand "${1}")"
    # shellcheck disable=SC2086
    printf "\n\n\n%s\n\n" "${cmd}"
    eval ${cmd} || clean_exit 127 "${1} Updates Failed."
}

executer () {
    for cmd in ${all_cmds}; do
        exec_str "${cmd}"
    done
}

informer () {
    cmd_printer "denial"
    for cmd in ${all_cmds}; do
        cmd_printer "${cmd}"
    done
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
            -e|--execute)
                execute=true
                shift
                ;;
            *)
                clean_exit 2 "${usage}"
                ;;
        esac
    done
}

main() {
    check_dependencies "cargo-cache" "cargo-install-update" "dnf" "emacs" \
                       "freshclam" "git" "nvim"
    set_vars
    cli "$@"
    if ${execute}; then {
        executer
    }
    else {
        informer
    }
    fi
    clean_exit
}

main "$@"
