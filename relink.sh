#!/usr/bin/env bash
# -*- coding: utf-8; mode: shell-script; -*-
#
# Copyright 2021 Pradyumna Paranjape
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


function set_vars() {
    usage="
    usage: ${0} [-h|--help] [-v|--verbose] [-c|--commit] LINK_DIR MOD_PAT [NEW_STR]
    "
    help_msg="
    ${usage}
    Description:

    Re-link (soft) all link-files in LINK_DIR by replacing MOD_PAT
    with NEW_STR. The default behaviour is to dry-simulate the
    process and show a verbose output of proposed changes. If
    NEW_STR is not supplied (safe), all prospective affected files
    are shown. Changes will be committed (written) only if NEW_STR
    and -c flag are supplied. Blank NEW_STR may be supplied as "".


    Positional Arguments:

    LINK_DIR:\tDirectory in which links are located
    MOD_PAT:\tPattern in link-targets to be altered
    NEW_STR:\tReplace MOD_PAT by NEW_STR if given

    Optional Arguments:

    -h|--help:\tDisplay this help message and exit
    -m|--mock:\tDo not perform action, only mock (assumes verbose)
    -v|--verbose:\tDisplay verbose outputs
    "
    link_dir=
    mod_pat=
    new_str=
    verbose=
    mock=true
    safe=false
    pos=()
    lstars=()
    lslinks=()
}


function unset_vars() {
    usage=
    help_msg=
    link_dir=
    mod_pat=
    new_str=
    verbose=
    safe=
    mock=
    pos=()
    lstars=()
    lslinks=()
}


function modify() {
    if ${verbose} || ${mock}; then
        echo -e "Subject Directory: ${link_dir}"
        echo -e "Pattern to modify: ${mod_pat}"
        echo -e "New string: ${new_str}\n"
    fi
    [[ ! -d "${link_dir}" ]] && echo "Directory ${link_dir} not found" && exit 1
    for lnf in "${link_dir}"/*; do
        target="$(readlink "${lnf}")"
        [[ -z ${target} ]] && continue
        [[ ! ${target} =~ ${mod_pat} ]] && continue
        lslinks+=("${lnf}")
        lstars+=("${target}")
    done
    for idx in "${!lstars[@]}"; do
        if ${verbose} || ${mock}; then
            link_f="${lslinks[idx]/${link_dir}\//}"
            if ! ${safe}; then
                old_tar="\033[0;31m${lstars[idx]}\033[0m"
                new_tar="\033[0;32m${lstars[idx]/${mod_pat}/${new_str}}\033[0m"
                echo -e "${link_f} ! ${old_tar} => ${new_tar}"
            else
                old_tar="\033[0;31m${lstars[idx]}\033[0m"
                echo -e "${link_f} => ${old_tar}"
            fi
        fi
        if ! (${mock} || ${safe}); then
            ln -sf "${lstars[idx]/${mod_pat}/${new_str}}" "${lslinks[idx]}"
        fi
    done
}


function bad_args() {
    pos_args=("${@}")
    echo -e "    Bad Positional Arguments\n"
    for idx in "${!pos_args[@]}"; do
        echo "    $(( idx + 1 )): ${pos_args[idx]}"
    done
    echo -e "${usage}"
    exit 1
}


function cli() {
    [[ $# -eq 0 ]] && echo -e "${usage}" && exit 0
    while test $# -gt 0; do
        case "${1}" in
            -h|--help)
                shift 1
                echo -e "${help_msg}"
                exit 0
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
                pos+=("${1}")
                shift 1
        esac
    done
    [[ ${#pos[*]} -gt 3 ]] && bad_args "${pos[@]}"
    [[ ${#pos[*]} -lt 2 ]] && bad_args "${pos[@]}"
    [[ ${#pos[*]} -eq 2 ]] && mock=true && safe=true
    link_dir=${pos[0]%/}
    mod_pat=${pos[1]}
    new_str=${pos[2]}
    [[ -z "${mod_pat}" ]] &&  bad_args "${pos[@]}"
}


function main() {
    set_vars
    cli "$@"
    modify
    unset_vars
}

main "$@"

