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

# wget multiple threads
while getopts ":ht:l:" optname; do
        case $optname in
                "h")
                        echo -e "Usage: wget_multithreaded.sh [arguments] ...\n"
                        echo -e "Arguments:"
                        echo -e "  -t N \t\t\tinitiate N threads";
                        echo -e "  -l STRING \t\tSave log in STRING.wget_log\n";
                        echo -e "All trailing arguments are passed on to wget";
                        exit 0;
                        ;;
                "t")
                        count=$OPTARG
                        ;;
                "l")
                        logfilename=$OPTARG
                        ;;
                "?")
                        echo "Illegal option \"$OPTARG\""
                        exit 1
                        ;;
                ":")
                        echo "No Threads specified, using 1 thread"
                        count=1
                        ;;
                *)
                        "Error while Processing options";
                        ;;
        esac
done

shift $((OPTIND - 1));

if [[ -z $count ]]; then 
        echo "No thread count specified, using 1";
        count=1;
fi

if [[ -z $logfilename ]]; then
        logfilename=/dev/stdout;
else
        logfilename="$logfilename.wget_log"
fi

for (( i=0; i<$count; i++ )); do
        wget -r -np -N $@ &>>$logfilename &
done;

exit;
