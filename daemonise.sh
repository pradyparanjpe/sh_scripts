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

# Daemonise
printf "Are you Sure[y/N] ?"
read -r response;

case "$response" in
    [Yy]*)
        nohup "$*" 0<&- >/dev/null 2>/dev/null &
        ;;
    *)
        exit 0
        ;;
esac

echo "daemonised $1";
exit;
