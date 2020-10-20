#!/usr/bin/env bash
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


function set_var() {
    verbose=
    source=
    destin="${PWD}"
    object=
    obj_name=
    pos=( )
    reverse=false
    mk_par=false
    mv_cmd="mv"
    ln_cmd="ln -s"
    usage="usage: $0 [-h|--help] [-p|--path] [-r|--reverse]

$0 SOURCE OBJECT DESTIN
$0 OBJECT DESTIN
$0 OBJECT

move object from SOURCE to DESTIN and leave a soft link at SOURCE


Required Positional Argument:

OBJECT\t\tname of object to move and link (file|directory|...)


Optional Positional Argument:

DESTIN\t\tfuture parent path of object [default: ${destin}]
SOURCE\t\tcurrent parent path (linked in future) [default: guessed from OBJECT]


Optional Arguments:

-h|--help\tprint this message and exit
-p|--path\tmake directory paths if they don't exist
-r|--reverse\tmove object from DESTIN to SOURCE and leave a link at DESTIN
-v|--verbose\tprint verbose
"
}


function rem_var() {
    verbose=
    source=
    destin=
    object=
    obj_name=
    pos=
    reverse=
    mk_par=
    mv_cmd=
    ln_cmd=
    usage=
}


function cli() {
    [[ $# -eq 0 ]] && echo -e "${usage}" && exit 0
    while test $# -gt 0; do
        case $1 in
            -r|--reverse)
                reverse=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -p|--path)
                mk_par=true
                shift
                ;;
            -h|--help)
                echo -e "${usage}"
                exit 0
                ;;
            *)
                pos+=( "$1" )
                shift
                ;;
        esac
    done
    case ${#pos[*]} in
        1)
            object=${pos[0]}
            ;;
        2)
            object=${pos[0]}
            destin=${pos[1]}
            ;;
        3)
            source=${pos[0]}
            object=${pos[1]}
            destin=${pos[2]}
            ;;
        *)
            echo "bad usage"
            echo "source: $source"
            echo "object: $object"
            echo "destin: $destin"
            echo -e "$usage"
            exit 1
            ;;
    esac
}


function auto_complete() {
    # are paths rooted?
    if [[ "${object}" != /* ]]; then
        object="${PWD}/${object}"
    fi
    if [[ -z "${source}" ]]; then
        source="$(dirname $object)"
    elif [[ "${source}" != /* ]]; then
        source="${PWD}/${source}"
    fi
    if [[ "${destin}" != /* ]]; then
        destin="${PWD}/${destin}"
    fi

    if $reverse; then
        echo "reverse directions"
        temp=$destin
        destin=$source
        source=$temp
        temp=
    fi

    if $mk_par; then
        mkdir -p "${source}" || exit $?
        mkdir -p "${destin}" || exit $?
    fi
}


function sanity() {
    if [[ "${source}" == "${destin}" ]]; then
        echo -e "source and distination are both ${source}"
        echo -e "nothing to be done"
        exit 0
    fi
    if [[ ! -d "${source}" ]]; then
        echo "Directory '${source}' doesn't exist. try -p option" >&2
        exit 2
    fi
    if [[ ! -d "${destin}" ]]; then
        echo "Directory '${destin}' doesn't exist. try -p option" >&2
        exit 2
    fi
    if [[ ! -e "${object}" ]]; then
        echo "${object} doesn't exist." >&2
        exit 2
    fi
}


function commands() {
    if $verbose; then
        mv_cmd="${mv_cmd} -v"
    fi
    obj_name=$(echo "${object}" | rev |cut -d / -f 1 | rev)
    if $verbose; then
        echo -e "${mv_cmd} ${object} ${destin}"
        echo -e "${ln_cmd} ${destin}/${obj_name} ${source}/."
    fi
    ${mv_cmd} "${object}" "${destin}" \
        && ${ln_cmd} "${destin}/${obj_name}" "${source}"
}


function main() {
    set_var
    cli $@
    auto_complete
    sanity
    commands
    rem_var
}

main $@
