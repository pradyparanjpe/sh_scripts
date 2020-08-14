#!/usr/bin/env bash
# -*- coding:utf-8; mode:shell-script -*-

systemd-analyse plot > "${HOME}/Org/${uname -n}_startup.svg"
