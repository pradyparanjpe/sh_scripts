#!/usr/bin/env sh
# -*- coding: utf-8; mode: shell-script -*-
#
# Copyright 2021, 2022 Pradyumna Paranjape
# This file is part of Prady_sh_scripts.
#
# Prady_sh_scripts is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Prady_sh_scripts is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Prady_sh_scripts. If not, see <https://www.gnu.org/licenses/>.


# Launch numpy-imported (i)python


if [ -f "${PYTHONSTARTUP}" ]; then
    inherit_str="$(cat PYTHONSTARTUP)"
fi

OLD_PYTHONSTARTUP="${PYTHONSTARTUP}"
PYTHONSTARTUP="$(mktemp)"

# imports
{ \
    echo "${inherit_str}"; \
    echo "from psprint import print"; \
    echo "print('imported:', mark='info')"
    echo "print('psprint as print', mark='list', indent=1)"
    echo "import numpy as np"; \
    echo "print('numpy as np', mark='list', indent=1)"
} >> "${PYTHONSTARTUP}"

export PYTHONSTARTUP

# launch
if builtin command -v ipython >/dev/null 2>&1; then
    ipython
    exit_code=$?
else
    python3
    exit_code=$?
fi

# clean up
rm -rf "${PYTHONSTARTUP}"

if [ -n "${OLD_PYTHONSTARTUP}" ]; then
    PYTHONSTARTUP="${OLD_PYTHONSTARTUP}"
    export PYTHONSTARTUP
else
    unset PYTHONSTARTUP
fi
unset OLD_PYTHONSTARTUP
unset inherit_str

exit ${exit_code}