#!/usr/bin/env sh
# -*- coding:utf-8 -*-
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
# Files in this project contain regular utilities and aliases for linux (fc34)


set_vars() {
    task="dry"
    rroot="${PWD}"
    conf="${rroot}/migrate"
    stale="https://github.com/${USER}"
    rnew=
    all_repos=
    usage="
    usage: \0 [-h|--help]
    usage: \0 [-r ROOT|--root ROOT] [-c CONF|--conf CONF] \
[-s STALE|--stale STALE] [-f|--fetch|-n NEW|--new NEW|-u|--unadd|-p|--push]
    "
    help_msg="
    ${usage}

    DESCRIPTION:
    Migrate by copying all repositories and all their branches and pushing them
    Default action is to read configuration file and list known values
    With NEW argument, \033[1m$ git remote add NEW/repo.git is executed\033[m

    Optional Arguments
    -h\t\t\t\tprint usage message and exit
    --help\t\t\tprint this detailed help message and exit
    -r ROOT|--root ROOT\t\troot directory for all git repos [default: ${rroot}]
    -c CONF|--conf CONF\t\tconfituration file naming repos [default: ${conf}]
    -s STALE|--stale STALE\tbase url of github repository [default: ${stale}]
    -n NEW|--new NEW\t\tadd remote base url of new repository
    -p|--push\t\t\tpush to new repo [default: id to fetch]
    -f|--fetch\t\t\tfetch from STALE repo
    -u|--unadd\t\t\tundo addition of new repository remote

    CONF regex pattern: (OLD_REPO_NAME(.git)?(:NEW_REPO_NAME(.git)?)?\\\n)*
    if NEW_REPO_NAME is not provided, OLD_REPO_NAME is used

    Example ./migrate:

        myRepo1.git:myrepo1
        myrepo2

    "

}

unset_vars() {
    unset help_msg
    unset usage
    unset all_repos
    unset rnew
    unset stale
    unset conf
    unset rroot
    unset task
}

clean_exit() {
    unset_vars
    if [ -z "${1}" ]; then
        exit 0
    else
        # shellcheck disable=SC2086
        exit $1
    fi
    return
}

cli () {
    while test $# -gt 0; do
        case "${1}" in
            -h)
                # shellcheck disable=SC2059
                printf "${usage}\n"
                clean_exit
                ;;
            --help)
                # shellcheck disable=SC2059
                printf "${help_msg}\n"
                clean_exit
                ;;
            -f|--fetch)
                task="fetch"
                shift
                ;;
            -u|--unadd)
                task="unadd"
                shift
                ;;
            -p|--push)
                task="push"
                shift
                ;;
            -r|--root|-r=*|--root=*)
                if [ ! "${1#*=}" = "${1}" ]; then
                    rroot="$(echo "$1" | cut -d "=" -f 2)"
                else
                    shift
                    rroot="${1}"
                fi
                shift
                ;;
            -c|--conf|-c=*|--conf=*)
                if [ ! "${1#*=}" = "${1}" ]; then
                    conf="$(echo "$1" | cut -d "=" -f 2)"
                else
                    shift
                    conf="${1}"
                fi
                shift
                ;;
            -s|--stale|-s=*|--stale=*)
                if [ ! "${1#*=}" = "${1}" ]; then
                    stale="$(echo "$1" | cut -d "=" -f 2)"
                else
                    shift
                    stale="${1}"
                fi
                shift
                ;;
            -n|--new|-n=*|--new=*)
                if [ ! "${1#*=}" = "${1}" ]; then
                    rnew="$(echo "$1" | cut -d "=" -f 2)"
                else
                    shift
                    rnew="${1}"
                    task='add'
                fi
                shift
                ;;
            *)
                # shellcheck disable=SC2059
                printf "${usage}\n"
                clean_exit 1
                ;;
        esac
    done
}

printvars () {
    printf "task: %s\n" "${task}"
    printf "rroot: %s\n" "${rroot}"
    printf "conf: %s\n" "${conf}"
    printf "stale: %s\n" "${stale}"
    printf "rnew: %s\n" "${rnew}"
    printf "all repos: %s\n" "${all_repos}"
}

pull_each () {
    # 1: path 2: url
    printf "%s -> %s\n" "$2" "$1"
    mkdir -p "${1}"
    git clone "${2}" "${1}"
    git -C "${1}" branch -r | grep -v '\->' | while read -r remote; do
        git -C "${1}" branch --track "${remote#origin/}" "$remote";
    done
    git -C "${1}" fetch --all
    git -C "${1}" pull --all
    unset reponame
}

add_each () {
    # 1: path 2: reponame
    git -C "${1}" remote add "pushout" "${rnew}/${2}.git"
    git -C "${1}" remote -v
}

push_each () {
    # 1: path
    git -C "${1}" push --all pushout
}

pull_all () {
    for reponame in ${all_repos}; do
        printf "pulling %s\n" "${reponame%:*}"
        pull_each "${rroot}/${reponame%:*}" "${stale}/${reponame%:*}.git"
    done
    unset reponame
}

add_all () {
    for reponame in ${all_repos}; do
        add_each "${rroot}/${reponame%:*}" "${reponame#*:}"
        printf "new remote: %s\n" "${rnew}/${reponame#*:}.git"
    done
    unset reponame
}

push_all () {
    for reponame in ${all_repos}; do
        push_each "${rroot}/${reponame%:*}"
        printf "pushed %s\n" "${reponame#*:}"
    done
    unset reponame
}

remove_all () {
    for reponame in ${all_repos}; do
        git -C "${rroot}/${reponame%:*}" remote -v remove "pushout";
    done
    unset reponame
}

discover() {
    while read -r reponame; do
        oldname="$(echo "${reponame}" | cut -d ":" -f 1)"
        oldname="${oldname%.git}"
        newname="$(echo "${reponame}" | cut -d ":" -f 2)"
        newname="${newname%.git}"
        if [ -z "${all_repos}" ]; then
            all_repos="${oldname}:${newname}"
        else
            all_repos="${all_repos} ${oldname}:${newname}"
        fi
    done < "${conf}"
    unset reponame
    unset oldname
    unset newname
}

main () {
    set_vars
    cli "$@"
    discover
    case "${task}" in
        fetch)
            pull_all
            clean_exit
            ;;
        add)
            if [ -z "${rnew}" ]; then
                printf "Provide new url base using -n NEW\n"
                clean_exit 1
            fi
            add_all
            clean_exit
            ;;
        unadd)
            remove_all
            clean_exit
            ;;
        push)
            push_all
            clean_exit
            ;;
        *)
            printvars
            clean_exit
            ;;
    esac
    clean_exit
}

main "$@"
