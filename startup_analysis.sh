#!/usr/bin/env bash
# -*- coding:utf-8; mode:shell-script -*-

org_dir="${HOME}/Org"
mkdir -p "${org_dir}"
systemd-analyze plot > "${org_dir}/$(uname -n)_startup.svg"
