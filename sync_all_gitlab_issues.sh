#!/usr/bin/env bash
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
    rok="\033[0;31;40m"  # red on black
    gok="\033[0;32;40m"  # green
    yok="\033[0;33;40m"  # yellow
    bok="\033[0;34;40m"  # blue
    dod="\033[m"         # default on default
    config_file=
    pull=false
    verbose=false
    very_verbose=false
    block=default
    local_url=
    local_token=
    local_projects=
    remote_url=
    remote_token=
    remote_projects=
    usage="
    usage: ${0} [-h]
    usage: ${0} [--help]
    usage: ${0} [[*Optional Arguments] ...] CONFIG_YAML
"
    help_msg="${usage}

    DESCRIPTION:
    Synchronize issues for all gitlab projects.
    A multi-wrapper for
    ${bok}https://pypi.org/project/gitlab-issues-sync/${dod}


    Help Arguements:
    -h\t\t\t\tprint usage message and exit
    --help\t\t\tprint this help message and exit

    Optional Arguments:
    -f|--pull\t\t\tCopy from remote to local in config file (default: push)
    -v|--verbose\t\tPrint information inferred from configuration file
    -V|--very-verbose\t\tPrint secrets in information (assumes -v)
    -b BLOCK|--block BLOCK\tSync BLOCK from config file {default: 'default'}

    Positional Arguments:
    CONFIG_YAML\t\t\tYaml file with configuration as described below

    Configuration format${dod} (${yok}yaml${dod}):
    \t${yok}BLOCK${dod}:
    \t  ${yok}local${dod}:
    \t    ${yok}url${dod}: ${bok}https://gitlab.com${dod}
    \t    ${yok}token${dod}: ${rok}<secret-token>${dod}
    \t    ${yok}projects${dod}: 11 12 13
    \t  ${yok}remote${dod}:
    \t    ${yok}url${dod}: ${bok}https://www.example.com${dod}
    \t    ${yok}token${dod}: ${rok}<secret-token>${dod}
    \t    ${yok}projects${dod}: 101 102 103
    \t    ${gok}# comment${dod}
    \t    ${gok}# inline comments \033[1;32;40mWILL${gok} pollute value${dod}
    \t    ${gok}# yaml indentation: 2 spaces${dod}
"
}

unset_vars() {
    unset rok
    unset gok
    unset yok
    unset bok
    unset dod
    unset pull
    unset verbose
    unset very_verbose
    unset block
    unset config_file
    unset local_url
    unset local_token
    unset local_projects
    unset remote_url
    unset remote_token
    unset remote_projects
    unset help_msg
    unset usage
}

cli () {
    if [ $# = 0 ]; then
        clean_exit 1 "${usage}"
    fi
    while [ $# -gt 0 ]; do
        case "${1}" in
            -h)
                clean_exit 0 "${usage}"
                ;;
            --help)
                clean_exit 0 "${help_msg}"
                ;;
            -f|--pull)
                pull=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -V|--very-verbose)
                verbose=true
                very_verbose=true
                shift
                ;;
            -b|--block|-b=*|--block=*)
                if [ ! "${1#*=}" = "${1}" ]; then
                    block="$(echo "$1" | cut -d "=" -f 2)"
                else
                    shift
                    block="${1}"
                fi
                shift
                ;;
            *)
                if [ -n "${config_file}" ]; then
                    clean_exit 1 "Bad positional argument ${rok}${1}${dod}
                    ${usage}"
                fi
                config_file="${1}"
                shift
                ;;
        esac
    done
    if [ -z "${config_file}" ]; then
        clean_exit 2 "${rok}Configuration file${dod} not provided\n${usage}"
    fi
}

# Copied [ and possibly edited ] this function from
# https://gist.github.com/pkuczynski/8665367
parse_yaml () {
    s='[[:space:]]*'
    w='[a-zA-Z0-9_]*'
    fs=$(echo @|tr @ '\034')
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  "${1}" |
        awk -F"$fs" '{
            indent = length($1)/2;
            vname[indent] = $2;
            for (i in vname) {
                if (i > indent) {
                    delete vname[i]
                }
            }
            if (length($3) > 0) {
                vn="";
                for (i=0; i<indent; i++) {
                    vn=(vn)(vname[i])("_")
                }
                printf("%s%s=\"%s\"\n", vn, $2, $3);
            }
        }'
    unset s
    unset w
    unset fs
    unset prefix
}

pick_yaml () {
    eval "$(parse_yaml "${1}")"
    local_url="${block}_local_url"
    local_token="${block}_local_token"
    local_projects="${block}_local_projects"
    remote_url="${block}_remote_url"
    remote_token="${block}_remote_token"
    remote_projects="${block}_remote_projects"
    if [ -z "${!local_url}" ]; then
        clean_exit 1 "Error: ${rok}${local_url}${dod} couldn't be inferred"
    fi
    if [ -z "${!local_token}" ]; then
        clean_exit 1 "Error: ${rok}${local_token}${dod} couldn't be inferred"
    fi
    if [ -z "${!local_projects}" ]; then
        clean_exit 1 "Error: ${rok}${local_projects}${dod} \
couldn't be inferred"
    fi
    if [ -z "${!remote_url}" ]; then
        clean_exit 1 "Error: ${rok}${remote_url}${dod} couldn't be inferred"
    fi
    if [ -z "${!remote_token}" ]; then
        clean_exit 1 "Error: ${rok}${remote_token}${dod} couldn't be inferred"
    fi
    if [ -z "${!remote_projects}" ]; then
        clean_exit 1 "Error: ${rok}${remote_projects}${dod} \
couldn't be inferred"
    fi
}

# Affirm python gitlab-issues-sync
affirm_py_gitlab () {
    if ! command -v pip >/dev/null 2>&1; then
        clean_exit 127 "Install ${rok}python3-pip${dod} and try again"
    fi
    if ! command -v python >/dev/null 2>&1; then
        clean_exit 127 "Install ${rok}python3${dod} and try again"
    fi
    pyver="$(python --version | cut -d " " -f 2 | cut -d "." -f 1)"
    if [ ! "${pyver}" -eq "3" ]; then
        clean_exit 127 "Wrong version of python found: ${rok}${pyver}${dod}. \
Use python3"
    fi
    if ! command -v gitlab-issues-sync >/dev/null 2>&1; then
        pip install -U colored
        pip install -U gitlab-issues-sync
    fi
}

loop_sync_api () {
    if $verbose; then
        printf "${bok}local_url${dod}: %s\n" "${!local_url}"

        if $very_verbose; then
            printf "${bok}local_token${dod}: ${rok}%s${dod}\n" \
                "${!local_token}"
        else
            # shellcheck disable=SC2059
            printf "${bok}local_token${dod}: ${yok}<HIDDEN>${dod}\n"
        fi
        printf "${bok}local_projects${dod}: %s\n" "${!local_projects}"
        printf "${bok}remote_url${dod}: %s\n" "${!remote_url}"

        if $very_verbose; then
            printf "${bok}remote_token${dod}: ${rok}%s${dod}\n" \
                "${!remote_token}"
        else
            # shellcheck disable=SC2059
            printf "${bok}remote_token${dod}: ${yok}<HIDDEN>${dod}\n"
        fi
        printf "${bok}remote_projects${dod}: %s\n" "${!remote_projects}"
    fi
    local_count=$(echo "${!local_projects}" | wc -w )
    remote_count=$(echo "${!remote_projects}" | wc -w )
    if [ "$local_count" != "$remote_count" ]; then
        clean_exit 1 "Number of remote and local projects doesn't match."
    fi
    # shellcheck disable=SC2086
    set -- ${!local_projects}
    index=0
    while [ $# -gt 0 ]; do
        index=$((index + 1))
        remote="$(echo "${!remote_projects}"| cut -d " " -f "${index}")"
        if $pull; then
            gitlab-issues-sync -i "${!remote_url}" -o "${!local_url}" \
                               "${remote}" "${1}" "${!remote_token}" \
                               "${!local_token}"
        else
            gitlab-issues-sync -i "${!local_url}" -o "${!remote_url}" \
                               "${1}" "${remote}" "${!local_token}" \
                               "${!remote_token}"
        fi
        shift
    done
    unset index
    unset remote
}

main () {
    check_dependencies "git" "gitlab-issues-sync" "python" "pip"
    set_vars
    affirm_py_gitlab
    cli "$@"
    pick_yaml "${config_file}"
    loop_sync_api
    clean_exit
}

main "$@"

