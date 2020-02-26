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

[[ `whoami` != "root" ]] && echo "Run with Root Privileges" && exit 1
read -p "Clear Buffers? [yes/no]: " yn
case $yn in
    [Yy]*) echo "Preparing ...";
        echo -e "\nFree\tBuffer\tCache\033[0;31m";
        vmstat -S M | sed -n 3p | sed -r 's/\W+/ /g' | cut -d " " -f 5,6,7 | sed -e "s/ /, /g";
        old=(`vmstat -S M | sed -n 3p | sed -r 's/\W+/ /g' | cut -d " " -f 5,6,7`);
        echo -e "\033[0;32m\nClearing Buffers ...\033[m";
        sync; echo 3 > /proc/sys/vm/drop_caches;
        echo -e "Buffers Cleared";
        echo -e "\nFree\tBuffer\tCache\033[0;34m";
        vmstat -S M | sed -n 3p | sed -r 's/\W+/ /g' | cut -d " " -f 5,6,7 | sed -e "s/ /, /g";
        new=(`vmstat -S M | sed -n 3p | sed -r 's/\W+/ /g' | cut -d " " -f 5,6,7`);
        echo -e "\n\033[0;33mCleared $((${old[1]}-${new[1]})) M buffers & $((${old[2]}-${new[2]})) M cache";
        echo -e "\033[m";
        ;;
    *) echo "exitting";
        exit
        ;;
esac;
