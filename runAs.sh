#!/usr/bin/env sh
# -*- coding:utf-8 -*-
#
# Copyright 2020-2021 Pradyumna Paranjape
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


set_vars () {
    otherUser=
    otherIP=
    execCmd=
    posStr=
    titleStr=
    interactive=true
    usage="usage: $0 [-h] [--help] [-u USER|--user USER] [-i IP|--ip IP] [-p PROG|--ip PROG] [EXECSTR]"
    help_msg="
    ${usage}

    Description:
    Run PROGRAM as USER at REMOTEIP using ssh -X tunnel (or waypipe)

    Optional Args:

    -h\t\t\tDisplay usage command and exit
    --help\t\tDisplay this detailed help message and exit
    -n|--non-interactive\tDo not prompt for missing items
    -u USER|--user USER\tUsername
    -i IP|--ip IP\t[IP/Web] address
    -p PROG|--p PROG\t program to run

    Positional Args:

    EXECSTR\t\tRemote program string of the form [PROGRAM:][USER][@REMOTEIP]
    "
}

unset_vars () {
    unset otherUser
    unset otherIP
    unset execCmd
    unset posStr
    unset titleStr
    unset interactive
    unset usage
    unset help_msg
}

clean_exit () {
    if [ -z "${1}" ]; then
        unset_vars
        exit 0
    else
        if [ -n "${2}" ] && [ -n "${interactive}" ]; then
            zenity --title="${titleStr}" --info --text="${2}";
        fi
        unset_vars
        # shellcheck disable=SC2086
        exit ${1}
    fi
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
            -n|--non-interactive)
                unset interactive
                shift
                ;;
            -u|--user|-u=*|--user=*)
                if [ ! "${1#*=}" = "${1}" ]; then
                    otherUser="$(echo "$1" | cut -d "=" -f 2)"
                else
                    shift
                    otherUser="${1}"
                fi
                shift
                ;;
            -i|--ip|-i=*|--ip=*)
                if [ ! "${1#*=}" = "${1}" ]; then
                    otherIP="$(echo "$1" | cut -d "=" -f 2)"
                else
                    shift
                    otherIP="${1}"
                fi
                shift
                ;;
            -p|--program|-p=*|--program=*)
                if [ ! "${1#*=}" = "${1}" ]; then
                    execCmd="$(echo "$1" | cut -d "=" -f 2)"
                else
                    shift
                    execCmd="${1}"
                fi
                shift
                ;;
            *)
                if [ -z "${posStr}" ]; then
                    posStr="${1}"
                else
                    posStr="${posStr} ${1}"
                fi
                shift
                ;;
        esac
    done
}

parse_positional() {
    if [ -z "${otherUser}" ]; then
        otherUser="$(printf "%s" "${1#*:}" | cut -d "@" -f 1)"
        if [ "${otherUser}" = "${1}" ]; then
            otherUser=
        fi
    fi
    if [ -z "${otherIP}" ]; then
        otherIP="${1#*@}"
        if [ "${otherIP}" = "${1}" ]; then
            otherIP=
        fi
    fi
    if [ -z "${execCmd}" ]; then
        execCmd="${1%%:*}"
        if [ "${execCmd}" = "${otherUser}@${otherIP}" ]; then
            execCmd=
        fi
    fi
}

contextInterpretUser () {
    if [ -z "${otherUser}" ]; then
        # User hasn't entered the name, interpret context
        currUser="$(whoami)";
        for testUser in $KNOWN_USERS; do  # declare and export KNOWN_USERS
            if id -u "$testUser" >/dev/null 2>&1 && \
                [ "${otherUser}" != "${currUser}" ]; then
                otherUser="${testUser}";
                break
            fi
        done
    fi
}

prompt_vars() {
    if [ -z "${interactive}" ]; then
        return
    fi
    titleStr="${otherUser}@${otherIP}:${execCmd}"
    if [ -z "${otherUser}" ]; then
        otherUser=$(zenity --title="Run ${titleStr}" --text="Username:" --entry);
    fi
    titleStr="${otherUser}@${otherIP}:${execCmd}"
    if [ -z "${otherIP}" ]; then
        # Check if second positional argument is supplied
        otherIP=$(zenity --title="Run ${titleStr}" --text="IP Address:" --entry);
    fi
    titleStr="${otherUser}@${otherIP}:${execCmd}"
    if [ -z "${execCmd}" ]; then
        execCmd=$(zenity --title="Run ${titleStr}" --text="Application to open" --entry);
    fi
}

x_proto() {
    protocol="$(loginctl show-session "$(loginctl | awk '/tty/ {print $1}')" -p Type | cut -d "=" -f 2)"
    if [ "${protocol}" = "wayland" ]; then
        # check availability of waypipe
        #use waypipe
        if ! command -v "waypipe" >/dev/null 2>&1; then
            unset protocol
            clean_exit 127 "Wayland display Server requires waypipe at both sides"
        fi
        # execCmd="waypipe ssh ${otherUser}@${otherIP} nohup ${execCmd} 1>/dev/null 2>&1 &"
        execCmd="waypipe ssh ${otherUser}@${otherIP} nohup ${execCmd} 1>/dev/null 2>&1"
    else
        execCmd="ssh -X ${otherUser}@${otherIP} nohup ${execCmd} 1>/dev/null 2>&1 &"
    fi
    unset protocol
    # return
}

test_access () {
    # test user
    titleStr="${otherUser}@${otherIP}:${execCmd}"
    if [ -z "${otherUser}" ]; then
        # Couldn't find suitable user
        clean_exit 126 "Couldn't run as a blank user, throwing...";
    fi
    # test cmd
    if [ -z "${execCmd}" ]; then
        clean_exit 0 "No command supplied, exitting...";
    fi
    # test ip
    if [ -z "${otherIP}" ]; then
        # Couldn't find IP, falling back
        otherIP="127.0.0.1";
    fi
    # test session
    titleStr="${otherUser}@${otherIP}:${execCmd}"
    if ! ssh "${otherUser}@${otherIP}" "exit"; then
        clean_exit 127 "confirm existance and key";
    fi;
}

run_cmd () {
    echo "Running command \"${execCmd}\""
    ${execCmd} 1>/dev/null 2>&1 &
    clean_exit
}

main () {
    set_vars
    cli "$@"
    parse_positional "${posStr}"
    prompt_vars
    contextInterpretUser
    test_access
    x_proto
    run_cmd
    clean_exit 0
}

main "$@"
