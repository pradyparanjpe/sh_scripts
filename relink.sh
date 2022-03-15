#!/usr/bin/env sh
# -*- coding: utf-8; mode: shell-script; -*-
#
# Copyright 2021, 2022 Pradyumna Paranjape
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


# shellcheck disable=SC1091
. "$(dirname "${0}")/common.sh" || exit 5


set_vars() {
    link_dir=
    mod_pat=
    new_str=
    verbose=
    mock=true
    safe=false
    lstars=
    lslinks=
    usage="
    ${0} -h
    ${0} --help
    ${0} [-v|--verbose] [-c|--commit] LINK_DIR MOD_PAT [NEW_STR]
    "
    help_msg="${usage}

    DESCRIPTION:
    Re-link (soft) all link-files in LINK_DIR by replacing MOD_PAT
    with NEW_STR. The default behaviour is to dry-simulate the
    process and show a verbose output of proposed changes. If
    NEW_STR is not supplied (safe), all prospective affected files
    are shown. Changes will be committed (written) only if NEW_STR
    and -c flag are supplied. Blank NEW_STR may be supplied as \"\".


    Positional Arguments:
    LINK_DIR:\t\tDirectory in which links are located
    MOD_PAT:\t\tPattern in link-targets to be altered
    NEW_STR:\t\tReplace MOD_PAT by NEW_STR if given

    Optional Arguments:
    -h\t\t\tDisplay usage message and exit
    --help\t\tDisplay this help message and exit
    -m|--mock\t\tDo not perform action, only mock (assumes verbose)
    -v|--verbose\tDisplay verbose outputs
    "
    load_default_config || true
}


unset_vars() {
    unset usage
    unset help_msg
    unset link_dir
    unset mod_pat
    unset new_str
    unset verbose
    unset safe
    unset mock
    unset lstars
    unset lslinks
}


mod_link() {
    if ${verbose} || ${mock}; then
        link_f="$(posix_rename "${1}" "${link_dir}/")"
        if ! ${safe}; then
            old_tar="\033[0;31m${2}\033[0m"
            new_tar="\033[0;32m\
$(posix_rename "${2}" "${mod_pat}" "${new_str}")\033[0m"
            # shellcheck disable=SC2059
            printf "${link_f} ! ${old_tar} => ${new_tar}\n"
        else
            old_tar="\033[0;31m${2}\033[0m"
            # shellcheck disable=SC2059
            printf "${link_f} => ${old_tar}\n"
        fi
    fi
    if ! (${mock} || ${safe}); then
        ln -sf "$(posix_rename "${2}" "${mod_pat}" "${new_str}")" "${1}"
    fi
}

modify() {
    if ${verbose} || ${mock}; then
        printf "Subject Directory: %s\n" "${link_dir}"
        printf "Pattern to modify: %s\n" "${mod_pat}"
        printf "New string: %s\n\n" "${new_str}"
    fi
    if [ ! -d "${link_dir}" ]; then
        clean_exit 1 "Directory ${link_dir} not found"
    fi
    for lnf in "${link_dir}"/*; do
        target="$(readlink "${lnf}")"
        [ -z "${target}" ] && continue
        [ "${target#*${mod_pat}}" = "${target}" ] && continue
        if [ -z "${lslinks}" ]; then
            lslinks="${lnf}"
        else
            lslinks="${lslinks} ${lnf}"
        fi
        if [ -z "${lstars}" ]; then
            lstars="${target}"
        else
            lstars="${lstars} ${target}"
        fi
    done
    if [ -z "${lstars}" ]; then
        return
    fi
    while [ ! "${lstars}" = "${lstars#* }" ]; do
        tarword="${lstars%% *}"
        linkword="${lslinks%% *}"
        lstars="${lstars#* }"
        lslinks="${lslinks#* }"
        mod_link "${linkword}" "${tarword}"
    done
    tarword="${lstars%% *}"
    linkword="${lslinks%% *}"
    lstars="${lstars#* }"
    lslinks="${lslinks#* }"
    mod_link "${linkword}" "${tarword}"
    unset tarword
    unset linkword
}


bad_args() {
    printf "    Bad Positional Arguments\n"
    count=0
    # shellcheck disable=SC2068
    for poswd in ${@}; do
        count="$(( count + 1 ))"
        printf "    %s: %s\n" "${count}" "${poswd}"
    done
    unset count
    unset poswd
    clean_exit 1 "${usage}"
}


cli() {
    if [ $# -eq 0 ]; then
        clean_exit 0 "${usage}"
    fi
    pos=
    pos_orig=
    while test $# -gt 0; do
        case "${1}" in
            -h|--help)
                shift 1
                clean_exit 0 "${help_msg}"
                ;;
            -c|--commit)
                mock=false
                shift 1
                ;;
            -v|--verbose)
                verbose=true
                shift 1
                ;;
            *)
                if [ -z "${pos}" ]; then
                    pos="${1}"
                else
                    pos="${pos} ${1}"
                fi
                shift 1
        esac
    done
    pos_orig="${pos}"
    num_args="$(printf "%s" "$pos" | wc -w)"
    [ "${num_args}" -gt 3 ] && bad_args "${pos}"
    [ "${num_args}" -lt 2 ] && bad_args "${pos}"
    [ "${num_args}" -eq 2 ] && mock=true && safe=true
    link_dir="${pos%% *}"
    link_dir="${link_dir%/}"  # remove trailing /
    pos="${pos#* }"
    mod_pat="${pos%% *}"
    pos="${pos#* }"
    new_str="${pos}"
    [ -z "${mod_pat}" ] && bad_args "${pos_orig}"
    unset num_args
    unset pos_orig
    unset pos
}


main() {
    set_vars
    cli "$@"
    modify
    unset_vars
}

main "$@"
