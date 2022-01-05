#! /usr/bin/env sh
# -*- coding: utf-8; mode: shell-script; -*-
#
# Copyright 2020-2022 Pradyumna Paranjape
#
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
#


. "./common.sh" || exit 127


set_vars() {
    usage="
    usage: $0 [-h]
    usage: $0 [--help]
    usage: $0 [server-name] [remote]
"
    help_msg="${usage}

    DESCRIPTION:
    Connect to openvpn server with credentials
    "
    remote_targets="192.168.1.104"
}

unset_vars() {
    unset remote_targets
    unset help_msg
}

vpn_disconnect() {
    for target in $1; do
        echo "un-routing ${target}"
        sudo route del "${target}"
    done
    echo "new routes:"
    route
    echo "Stopping VPN connection"
    sudo systemctl stop openvpn-client@"${2}"
    unset target
}

vpn_connect() {
    echo "Starting VPN connection"
    sudo systemctl start openvpn-client@"${2}"
    sleep 5;
    for target in $1; do
        echo "routing ${target} to tun0"
        sudo route add "${target}" dev tun0
        if ping "${target}" -c 2; then
            echo "${target} is up"
        else
            echo "${target} is not responding"
        fi
    done
    echo "new routes"
    route
    unset target
}

cli () {
    while test $# -gt 0; do
        case "${1}" in
            --help)
                # shellcheck disable=SC2059
                clean_exit 0 "${help_msg}"
                ;;
            *)
                # shellcheck disable=SC2059
                clean_exit 1 "${usage}"
                ;;
        esac done
}

main() {
    check_dependencies "route" "systemctl"
    echo "connecting remote: $*"
    echo "openvpn-client@${1} is:"
    if systemctl is-active openvpn-client@"${1}"; then
        vpn_disconnect "${remote_targets}" "${1}"
    else
        vpn_connect "${remote_targets}" "${1}"
    fi
    clean_exit 0
}

main "$@"
