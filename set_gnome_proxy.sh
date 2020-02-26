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

# set unset gnome proxy to ccmb

if $(gsettings get org.gnome.system.proxy.http enabled) ; then
	gsettings set org.gnome.system.proxy mode 'none';
	gsettings set org.gnome.system.proxy.http enabled false;
	gsettings set org.gnome.system.proxy.http host '';
	gsettings set org.gnome.system.proxy.https host '';
	gsettings set org.gnome.system.proxy.ftp host '';
	gsettings set org.gnome.system.proxy.http use-authentication false;
	gsettings set org.gnome.system.proxy.http authentication-user '';
	gsettings set org.gnome.system.proxy.http authentication-password '';
##	zenity --info --text="Proxy Disabled" --title="Proxy toggle"
    notify-send "Proxy Disabled";
	echo "Proxy disabled";
else
	gsettings set org.gnome.system.proxy mode 'manual';
	gsettings set org.gnome.system.proxy.http enabled true;
	gsettings set org.gnome.system.proxy.http host '192.168.1.101';
	gsettings set org.gnome.system.proxy.https host '192.168.1.101';
	gsettings set org.gnome.system.proxy.ftp host '192.168.1.101';
	gsettings set org.gnome.system.proxy.http port 8080;
	gsettings set org.gnome.system.proxy.https port 8080;
	gsettings set org.gnome.system.proxy.http use-authentication true;
	gsettings set org.gnome.system.proxy.http authentication-user 'pradyparanjpe';
	gsettings set org.gnome.system.proxy.http authentication-password 'C036498$';
##	zenity --info --text='Proxy Enabled' --title='Proxy toggle';
	echo "Proxy Enabled";
    notify-send "Proxy Enabled";
fi;
exit;
