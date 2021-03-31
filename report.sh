#!/usr/bin/env bash
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


# This script facilities plotting of a ledger register report.  If you
# use OS/X, and have AquaTerm installed, you will probably want to set
# LEDGER_TERM to "aqua".
#
# Examples of use:
#
#   report -j -M reg food            # plot monthly food costs
#   report -J reg checking           # plot checking account balance

[[ -z "${LEDGER_TERM}" ]] && LEDGER_TERM="x11 persist"
[[ -z "${INFILE}" ]] && INFILE="${EXPENDLOG}";
resolution=$(xrandr | sed -n /\*/p | awk '{print $1}');

(cat <<EOF; ledger -f "${INFILE}" -J "$@") \
    | gnuplot -persist -geometry "${resolution}"
  set terminal ${LEDGER_TERM};
  set yrange [ 0 :  ];
  set xdata time;
  set grid;
  set timefmt "%Y-%m-%d";
  plot "-" using 1:2 with lp;
EOF
