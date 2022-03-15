#!/usr/bin/env sh
# -*- coding: utf-8; mode: shell-script; -*-
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

# retreive, display and/or set current time

# shellcheck disable=SC1091
. "$(dirname "${0}")/common.sh" || exit 127

set_vars() {
    ssl_root="$(realpath ./)"
    keyname="$(hostname)"
    validity=10
    conf=
    create_conf=false
    usage="usage:
    ${0} -h
    ${0} --help
    ${0} [Optional Arguments ...] -t|--template [SSL_ROOT]
    ${0} [Optional Arguments ...] SSL_ROOT"
    help_msg="${usage}

DESCRIPTION:
    Generate SSL certificate key-pairs

Optional Arguments:
    -h\t\t\t\tPrint usage message and exit
    --help\t\t\tPrint this help message and exit
    -t|--template\t\tWrite configuration file template and exit.
    -k KEY|--key KEY\t\tKey base [default: \033[0;32;40m${keyname}\033[m]
    -c CONF|--conf CONF\t\tConfiguration file path [default: SSL_ROOT/KEY.conf]
    -y YEARS|--years YEARS\tValidity in years [default: ${validity}]


Optional Positional Argument:
    SSL_ROOT\t\t\tRoot for keys [default: \033[0;32;40m${ssl_root}\033[m]"
    load_default_config || true
}

unset_vars() {
    unset help_msg
    unset usage
    unset validity
    unset conf
    unset create_conf
    unset keyname
    unset ssl_root
}

resolve_paths () {
    validity="$(printf %.0f "$(echo "${validity} * 365.25" | bc -lq)")"
    if [ -z "${conf}" ]; then
        conf="${keyname}.conf"
    fi
    ssl_root="$(realpath "${ssl_root}")"
}

dump_template () {
    conf_template="
[req]
days                = 3652
serial              = 0
distinguished_name  = req_distinguished_name
req_extensions      = v3_req
prompt              = no


[req_distinguished_name]
countryName         =
stateOrProvinceName =
localityName        =
organizationName    = Personal
commonName          = $(hostname)
emailAddress        = $(whoami)@$(hostname)


[v3_req]
basicConstraints    = CA:FALSE
keyUsage            = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName      = @alt_names


[alt_names]
DNS.1               = $(hostname)
IP.1                = 127.0.0.1
"
    resolve_paths
    conf_file="${ssl_root}/${conf}"
    if [ -f "${conf_file}" ]; then
        clean_exit 65 "File '${conf_file}' already exists, not over-writing."
    fi
    printf "%s" "${conf_template}" > "${conf_file}"
    unset conf_template
    unset conf_file
}

generate_anew () {
    conf_file="${ssl_root}/${conf}"

    if [ ! -f "${conf_file}" ]; then
        clean_exit 65 "Configuration ${conf_file} is missing"
    fi

    key_file="${ssl_root}/${keyname}.key"
    crt_file="${ssl_root}/${keyname}.crt"
    csr_file="${ssl_root}/${keyname}.csr"

    if [ ! -f "${key_file}" ]; then
        printf "Generating new key: %s\n" "${key_file}"
        openssl genrsa -out "${key_file}" 2048 || clean_exit 65
    fi

    openssl req -new \
            -out "${csr_file}" \
            -key "${key_file}" \
            -config "${conf_file}" || clean_exit 65

    openssl x509 -req \
            -days "${validity}" \
            -in "${csr_file}" \
            -signkey "${key_file}" \
            -out "${crt_file}" \
            -extensions v3_req \
            -extfile "${conf_file}" || clean_exit 65

    openssl x509 \
            -in "${crt_file}" \
            -out "${ssl_root}/${keyname}.pem" \
            -outform PEM || clean_exit 65

    printf "Created new pair\n"
    printf "    certificate file: %s\n" "${crt_file}"
    printf "    with key: %s\n" "${key_file}"

    unset csr_file
    unset crt_file
    unset key_file
    unset conf_file
}

display_cert () {
    openssl x509 -text -noout -in "${ssl_root}/${keyname}.crt"
}

cli () {
    if [ $# = 0 ]; then
        clean_exit 1 "${help_msg}"
    fi
    while test $# -gt 0; do
        case "${1}" in
            -h)
                clean_exit 0 "${usage}"
                ;;
            --help)
                clean_exit 0 "${help_msg}"
                ;;
            -t|--template)
                create_conf=true
                shift
                ;;
            -k|--key|-k=*|--key=*)
                if [ ! "${1#*=}" = "${1}" ]; then
                    keyname="$(printf "%s" "$1" | cut -d "=" -f 2)"
                else
                    shift
                    keyname="${1}"
                fi
                shift
                ;;
            -c|--conf|-c=*|--conf=*)
                if [ ! "${1#*=}" = "${1}" ]; then
                    conf="$(printf "%s" "$1" | cut -d "=" -f 2)"
                else
                    shift
                    conf="${1}"
                fi
                shift
                ;;
            -y|--years|-y=*|--years=*)
                if [ ! "${1#*=}" = "${1}" ]; then
                    validity="$(printf "%s" "$1" | cut -d "=" -f 2)"
                else
                    shift
                    validity="${1}"
                fi
                shift
                ;;
            *)
                ssl_root="${1}"
                shift
                ;;
        esac
    done
}

main() {
    check_dependencies "openssl" "bc"
    set_vars
    cli "$@"
    resolve_paths
    if $create_conf; then
        dump_template
    else
        generate_anew
        display_cert
    fi
    clean_exit
}


main "$@"
