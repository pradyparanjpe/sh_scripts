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
Convert color:
   - Invert color
   - Invert shade
   - Invert color and shade
"""

from argparse import ArgumentParser, RawDescriptionHelpFormatter
from typing import Dict, List, Sequence, Tuple, Union


class ColorInvertError(Exception):
    """Base Error"""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


class Color():
    """
    Color (default representation as RGBA)

    Attributes:
        red: red (0-255)
        green: green (0-255)
        blue: blue (0-255)

    Args:
        color: str: hex color string: of the form #fff[f] or #ffffff[ff] OR
            Tuple[int, ...]: RGBA int of the form (255, 255, 255, 255).
            Alpha, the fourth component is assumed to be max if unavailable.
        space: int: color space (15 or 255)

    """
    def __init__(self, color: Union[str, Sequence[int]], space: int = None):
        if isinstance(color, str):
            try:
                if 'rgb' in color:
                    self.parsergb(color)
                    self.space = space or 0xff
                    return
                self.parsehex(color, space)
            except Exception as err:
                raise ColorInvertError('Bad color string format') from err
        elif isinstance(color, Sequence):
            self.red, self.green, self.blue = color[:3]
            self.space = space or 0xff
            self.alpha = color[-1] if len(color) == 4 else None

    def __iter__(self):
        """Iterate over red, green, blue."""
        return self.red, self.green, self.blue

    def __str__(self) -> str:
        """User-friendly output."""
        return self.hex

    @property
    def hex(self) -> str:
        """Hex-coded color"""
        hex_str = ['#']
        if self.space == 0xff:
            for pig in self.__iter__():
                hex_str.append(f'{min(pig, self.space):02x}')
            if self.alpha is not None:
                hex_str.append(f'{min(self.alpha, self.space):02x}')
            return ''.join(hex_str)
        for pig3 in tuple(round(pig / 0x10) for pig in self.__iter__()):
            hex_str.append(f'{min(pig3, self.space):1x}')
        if self.alpha is not None:
            hex_str.append(f'{min(self.alpha, self.space):1x}')
        return ''.join(hex_str)

    @hex.setter
    def hex(self, color: str):
        self.__init__(color)

    @property
    def rgba(self) -> Tuple[int, ...]:
        """RGBA-codeed Color"""
        return tuple([pig for pig in self.__iter__()] +
                     [0xff if self.alpha is None else self.alpha])

    @rgba.setter
    def rgba(self, color: Tuple[int, ...]):
        self.__init__(color)

    @property
    def shade(self) -> 'Color':
        """Invertred color shade"""
        out_color: List[int] = []
        lightest = self.max()
        darkest = self.min()
        for pigment in self.__iter__():
            out_color.append(pigment + 0xff - darkest - lightest)
        if self.alpha is not None:
            out_color.append(self.alpha)
        return Color(out_color, space=self.space)

    @property
    def invert(self) -> 'Color':
        """Inverted color"""
        out_color: List[int] = []
        for pigment in self.__iter__():
            out_color.append(0xff - pigment)
        if self.alpha is not None:
            out_color.append(self.alpha)
        return Color(out_color, space=self.space)

    def parsergb(self, color: str):
        """
        Parse rgba-coded color of the form rgba(r, g, b, a) or rgb(r, g, b).

        Args:
            color: color string
        """
        color_tup = color.split('(')[1].split(')')[0]
        if 'rgba' in color:
            red_str, green_str, blue_str, alpha_str = color_tup.split(',')
            self.alpha = int(alpha_str)
        else:
            red_str, green_str, blue_str = color_tup.split(',')
            self.alpha = None
        self.red = int(red_str)
        self.green = int(green_str)
        self.blue = int(blue_str)

    def parsehex(self, color: str, space: int = None):
        """
        Parse hex-coded color of the form [#]RGB[A] or [#]RRGGBB[AA].

        Args:
            color: color string
        """
        color = color.strip("#")
        if len(color) >= 6:
            self.red = int(color[:2], base=16)
            self.green = int(color[2:4], base=16)
            self.blue = int(color[4:6], base=16)
            self.alpha = int(color[6:], base=16) if color[6:] else None
            self.space = space or 0xff
        else:
            self.red = int(color[0], base=16) * 0x10
            self.green = int(color[1], base=16) * 0x10
            self.blue = int(color[2], base=16) * 0x10
            self.alpha = int(color[3:], base=16) if color[3:] else None
            self.space = space or 0xf

    def max(self) -> int:
        """Maximum of the three pigments max(r, g, b)"""
        return max(self.red, self.green, self.blue)

    def min(self) -> int:
        """Minimum of the three pigments min(r, g, b)"""
        return min(self.red, self.green, self.blue)


def cli():
    """
    Parse command line

    """
    description = '''Transforms from COLOR:
    1. invert color
    2. invert shade
    3. invert color and shade

Useful while converting style sheets to/from dark mode.

Format of COLOR:
    Remember to quote '#', '()' OR skip \\#, \\(, \\).

    1. [#]RGB[A]
    2. [#]RRGGBB[AA]
        []: Optional, R: Red, G: Green, B: Blue, A: Alpha (hex) [0 -> f]

    3. rgb(r, g, b)
    4. rgba(r, g, b, a)
        r: Red, g: Green, b: Blue, a: Alpha (integers) [0 -> 255]'''
    parser = ArgumentParser(description=description,
                            formatter_class=RawDescriptionHelpFormatter)
    parser.add_argument(dest='color',
                        metavar='COLOR',
                        type=str,
                        help='input color')
    parser.add_argument('-g',
                        '--gtk',
                        action='store_true',
                        help='display colors in a GTK+ 3 window')
    return vars(parser.parse_args())


def print_colors(color: Color):
    """Print colors to STDOUT."""
    print('Original:', color)
    print('Shade:', color.shade)
    print('Invert:', color.invert)
    print('Shade Invert:', color.invert.shade)


def gui(color: Color):
    """Show colors in GUI window."""
    import gi
    gi.require_version('Gtk', '3.0')
    gi.require_version('Gdk', '3.0')
    # import failures are caught later
    from gi.repository import Gdk, Gtk  # type: ignore

    class ColorUI(Gtk.Window):
        """User interface displaying all transformed colors."""
        def __init__(self, color: Color):
            self.color = color
            super().__init__()
            self.init_ui()
            self.connect('destroy', Gtk.main_quit)
            self.set_default_size(200, 200)

        def init_ui(self):
            """Initialize other UI elements"""
            grid = Gtk.Grid()
            self.put_colors(grid)
            self.add(grid)
            self.show_all()

        def color_panel(self, color_type: str, color: Color):
            """
            Panel with Colored area and label

            Args:
                color_type: Type of color being painted
                color: The Color
            """
            rgba = Gdk.RGBA()
            rgba.parse(f'rgba{color.rgba}')

            vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            button = Gtk.Button(expand=True)
            label = Gtk.Label(label=color_type, expand=False)

            color_area = Gtk.DrawingArea()
            color_area.connect("draw", self.on_draw, {"color": rgba})

            button.add(color_area)

            button.connect('clicked', self.on_click, color_type, color)
            vbox.pack_start(button, True, True, 0)
            vbox.pack_end(label, False, False, 0)

            vbox.set_hexpand(True)

            return vbox

        def put_colors(self, grid: Gtk.Grid):
            """Place All 4 colors on the UI grid"""
            original_box = self.color_panel('Original', color=self.color)
            invert_box = self.color_panel('Invert', color=self.color.invert)
            shade_box = self.color_panel('Shade', color=self.color.shade)
            ishade_box = self.color_panel('Shade Invert',
                                          color=self.color.shade.invert)
            grid.attach(original_box, 0, 0, 1, 1)
            grid.attach(invert_box, 1, 0, 1, 1)
            grid.attach(shade_box, 0, 1, 1, 1)
            grid.attach(ishade_box, 1, 1, 1, 1)

        def on_draw(self, widget: Gtk.Widget, cr, data: Dict[str, Gdk.RGBA]):
            context = widget.get_style_context()

            width = widget.get_allocated_width()
            height = widget.get_allocated_height()
            Gtk.render_background(context, cr, 0, 0, width, height)

            r, g, b, a = data["color"]
            cr.set_source_rgba(r, g, b, a)
            cr.rectangle(0, 0, width, height)
            cr.fill()

        def on_click(self, _, color_type, color):
            cb = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)
            cb.set_text(color.hex, -1)
            cb.store()
            print(f'{color_type}:', color.hex)

    display = ColorUI(color)
    display.show()
    Gtk.main()


def main():
    """Main routine call."""
    input_args = cli()
    color = Color(input_args['color'])
    if input_args['gtk']:
        try:
            gui(color)
        except Exception as err:
            print_colors(color)
            raise ColorInvertError('Error displaying GTK window') from err
    else:
        print_colors(color)


if __name__ == "__main__":
    main()
