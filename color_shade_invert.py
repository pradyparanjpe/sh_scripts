#!/usr/bin/env python3
# -*- coding: utf-8; mode: python; -*-
#
# Copyright 2020-2022 Pradyumna Paranjape
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
"""
Convert hex-coded color to
   - Inverted hex coded
   - Darkened color
   - Darkened inverted color
"""

from argparse import ArgumentParser, RawDescriptionHelpFormatter
from typing import Dict, List, Sequence, Tuple, Union

from psprint import print


class ColorInvertError(Exception):
    """
    Base Error
    """
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


class Color():
    """
    Color (default representation as RGB)

    Attributes:
        red: red (0-255)
        green: green (0-255)
        blue: blue (0-255)

    Args:
        color: str: hex color string: of the form #fff or #ffffff OR \
            Tuple[int, int, int]: RGB int of the form (255, 255, 255)
        space: int: inherited color space (15 or 255)

    """
    def __init__(self, color: Union[str, Sequence[int]], space: int = None):
        if isinstance(color, str):
            color = color.strip("#")
            if len(color) >= 6:
                red = int(color[:2], base=16)
                green = int(color[2:4], base=16)
                blue = int(color[4:6], base=16)
                alpha = int(color[6:] or 'ff', base=16)
                self.space = space or 0xff
            else:
                red = int(color[0], base=16) * 0x10
                green = int(color[1], base=16) * 0x10
                blue = int(color[2], base=16) * 0x10
                alpha = int(color[3:] or 'f', base=16)
                self.space = space or 0xf
        elif isinstance(color, Sequence):
            red, green, blue = color[:3]
            alpha = color[4] if len(color) == 4 else 0xff
            self.space = space or 0xff
        self.red = red * alpha // self.space
        self.green = green * alpha // self.space
        self.blue = blue * alpha // self.space

    def __iter__(self):
        """
        Iterate over red, green, blue
        """
        return self.red, self.green, self.blue

    @property
    def rgb(self) -> Tuple[int, int, int]:
        return self.red, self.green, self.blue

    @rgb.setter
    def rgb(self, color: Tuple[int, int, int]):
        self.__init__(color)

    @property
    def hex(self) -> str:
        """
        Convert hex - string to color.
        Reprocates meth:`color2hex`

        Returns:
            color tuple
        """
        hex_str = ['#']
        if self.space == 0xff:
            for pig in self.__iter__():
                hex_str.append(f'{min(pig, self.space):02x}')
            return ''.join(hex_str)
        for pig3 in tuple(round(pig / 0x10) for pig in self.__iter__()):
            hex_str.append(f'{min(pig3, self.space):1x}')
        return ''.join(hex_str)

    @hex.setter
    def hex(self, color: str):
        self.__init__(color)

    def max(self) -> int:
        return max(self.red, self.green, self.blue)

    def min(self) -> int:
        return min(self.red, self.green, self.blue)

    def shade(self) -> 'Color':
        """
        change color shade.
        """
        out_color: List[int] = []
        lightest = self.max()
        darkest = self.min()
        for pigment in self.__iter__():
            out_color.append(pigment + 0xff - darkest - lightest)
        return Color(out_color, space=self.space)

    def invert(self) -> 'Color':
        """
        Invert color.
        """
        out_color: List[int] = []
        for pigment in self.__iter__():
            out_color.append(0xff - pigment)
        return Color(out_color, space=self.space)  # type: ignore


def transform(hexcolor: str) -> Dict[str, str]:
    """
    Transform color to:
        1: invert (rgb<->cmy)
        2: shade (lrlglb<->drdhdb)
        3: shade invert (lrlglb<->dcdmdy)

    Args:
        color: hex string of form `#RRGGBB[AA]` or `#RGB[A]`

    Returns:
        Dictionary of inversions and shade-shifts
    """
    transformation: Dict[str, str] = {}
    color = Color(hexcolor)
    transformation['original'] = color.hex
    transformation['invert'] = color.invert().hex
    transformation['shade'] = color.shade().hex
    transformation['shade invert'] = color.invert().shade().hex
    return transformation


def cli():
    """
    Parse command line

    """
    description = f'''Transform color to:
    1. invert color
    2. invert color
    3. invert color and shade

Format of input color:
    1. #RGB
    2. #RGBA
    3. #RRGGBB
    4. #RRGGBBAA

    R: Red, G: Green, B: Blue, A: Alpha (hex)
    '''
    parser = ArgumentParser(description=description,
                            formatter_class=RawDescriptionHelpFormatter)
    parser.add_argument('color', type=str, help='input color')
    return vars(parser.parse_args())


def main():
    """
    Main routine call

    """
    input_args = cli()
    print(transform(input_args['color']), iterate=True)


if __name__ == "__main__":
    main()
