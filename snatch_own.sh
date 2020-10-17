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

# Clear Cache

# This must be run strictly as root

[[ "$UID" -eq 0 ]] || exec sudo su -c "bash $0 $@"

USAGE_MESSAGE="$0
Snatch Ownership of Files

usage:
$0 [-h|--help] [-R] [-v] [-u|--user ROBBER] TARGET

Optional Arguments
-h|--help\t\tPrint this message and exit
-R\t\t\tApply recursive
-v\t\t\tVerbose outout
-u|--user ROBBER\tGive ownership to ROBBER

Positional Argument

TARGET
"

[[ $# -eq 0 ]] && echo -e "$USAGE_MESSAGE" && exit 0

# Variables

ROBBER="$(logname)"
RECURSE=false
VERBOSE=false

while test $# -ge 1; do
    case $1 in
        -h|--help)
            echo -e "${USAGE_MESSAGE}"
            exit 0;
            ;;
        -R)
            RECURSE=true
            ${VERBOSE} && echo "[VERBOSE] SET RECURSIVE"
            shift 1
            ;;
        -v)
            VERBOSE=true
            ${VERBOSE} && echo "[VERBOSE] SET VERBOSE"
            shift 1
            ;;
        -u|--user)
            shift 1
            ROBBER="$1"
            ${VERBOSE} && echo "[VERBOSE] SET ROBBER $ROBBER"
            shift 1
            ;;
        *)
            TARGET="${TARGET}${1}"
            shift 1
            ;;
    esac
done

[[ -z "${TARGET}" ]] && echo -e "${USAGE_MESSAGE}" && exit 0

[[ ! -e "${TARGET}" ]] \
    && echo -e "  [ERROR] Confirm that ${TARGET} exists." \
    && exit 2

CLI="chown ${ROBBER}"
${RECURSE} && CLI="${CLI} -R"
${VERBOSE} \
    && CLI="${CLI} -v"\
    && echo "[VERBOSE] Snatching ownership of ${TARGET} to ${ROBBER}"\
    && echo -e "executing\n$CLI $TARGET"
${CLI} ${TARGET}


ROBBER=
VERBOSE=
RECURSE=
CLI=
