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

# Scan Up Nodes

if [[ -z $1 ]]; then
    range=0;
    startip=2;
    stopip=254;
else
    range=$1;
    if [[ -z $2 ]]; then
        startip=2;
        stopip=254;
    else
        startip=$2;
        if [[ -z $3 ]]; then
            stopip=254;
        else
            stopip=$3;
        fi;
    fi;
fi;

echo -e "Scanning 192.168.$range.$startip to 192.168.$range.$stopip.\nThe following ip addresses are up.";

for testip in $(seq $startip $stopip); do
    isdown=`ping -c 1 "192.168.$range.$testip" -w 1 -q`;

	if [[ $isdown =~ "100%" ]]; then
        :;
    else printf "$testip\t";
    fi;

done;

printf "\n";
exit;
