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


function contextInterpretUser {
    availUsers=( "pradyumna" "prady" "coder" );
    for otherUser in "${availUsers[@]}"; do
        if [[ $otherUser != $1 && -d "/home/$otherUser" ]]; then
            echo "$otherUser";
        fi
    done
    echo "";
}

# Interpret user and ip from options
while getopts "u:i:c:" opt; do
    case ${opt} in
        u )
            otherUser="${OPTARG}";
            ;;
        i )
            otherIP="${OPTARG}";
            ;;
        c )
            execCmd="${OPTARG}";
    esac;
done;

shift "$((OPTIND -1))";

# Check if positional first argument is supplied
[[ -z $otherUser ]] && otherUser="$(echo "$1" | cut -d "@" -f 1)";

if [[ -z $otherIP ]]; then
    otherIP="$(echo "$1" | cut -d "@" -f 2)";
    [[ "$otherIP" == "$otherUser" ]] && otherIP="";
    if [[ $otherUser == *.*.*.* || $otherUser == "localhost" ]]; then
        otherIP="$otherUser";
        otherUser="";
    fi
fi
shift $((OPTIND -1));

if [[ -z $otherIP ]]; then
    # Check if second positional argument is supplied
    otherIP=$1;
    if [[ "$otherIP" == "$otherUser" ]]; then
        otherIP=$(zenity --title="Run at remote" --text="IP Address:" --entry);
    fi
fi

if [[ -z $otherUser ]]; then
    # Ask for other User's name
    otherUser=$(zenity --title="Run as other user" --text="Username:" --entry);
fi
if [[ -z $otherUser ]]; then
    # User hasn't entered the name, interpret context
    currUser=$(whoami);
    otherUser=$(contextInterpretUser $currUser);
fi
if [[ -z $otherUser ]]; then
    # Still, can't find suitable user
    zenity --title="Run as user" --info --text="Couldn't run as a blank user, throwing...";
    exit 127;
fi

titlestr="Run as $otherUser";
if [[ -z "$otherIP" || "$otherIP" == "0.0.0.0" || $"otherIP" == "localhost" || "$otherIP" =~ "127.0.0" ]]; then
    true;
else
    titlestr=$titlestr" from $otherIP";
fi

if [[ "${otherIP}x" == "x" ]]; then
    otherIP="127.0.0.1";
fi

echo "user: \"$otherUser\" @ ip: \"$otherIP\"";

# check if other user is accessible
ssh -X $otherUser@$otherIP "exit";
if [[ $? != 0 ]]; then
    zenity --title="Run as user" --info --text="could not run as $otherUser, confirm existance and key";
    exit 127;
fi;


if [[ -z $execCmd ]]; then
    execCmd=$2;
fi

if [[ -z $execCmd ]]; then
    execCmd=$(zenity --title="$titlestr" --text="Application to open" --entry);
fi
if [[ -z $execCmd ]]; then
	exit 0;
else
	ssh -X $otherUser@$otherIP "nohup $execCmd 2>&1 1>/dev/null &" 2>&1 1>/dev/null;
	err=$?;
	if [[ $err == 0 ]]; then
		echo "exitted with error $err";
	fi
fi
exit $err;
