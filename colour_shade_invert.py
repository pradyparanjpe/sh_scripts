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
Convert colour:
   - Invert colour
   - Invert shade
   - Invert colour and shade
"""

from argparse import ArgumentParser, RawDescriptionHelpFormatter
from typing import Dict, List, Sequence, Tuple, Union


class ColourInvertError(Exception):
    """Base Error"""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


class Colour():
    """
    Colour (default representation as RGBA)

    Attributes:
        red: red (0-255)
        green: green (0-255)
        blue: blue (0-255)

    Args:
        colour: str: hex colour string: of the form #fff[f] or #ffffff[ff] OR
            Tuple[int, ...]: RGBA int of the form (255, 255, 255, 255).
            Alpha, the fourth component is assumed to be max if unavailable.
        space: int: colour space (15 or 255)

    """

    def __init__(self, colour: Union[str, Sequence[int]], space: int = None):
        if isinstance(colour, str):
            try:
                if 'rgb' in colour:
                    self.parsergb(colour)
                    self.space = space or 0xff
                    return
                self.parsehex(colour, space)
            except Exception as err:
                raise ColourInvertError('Bad colour string format') from err
        elif isinstance(colour, Sequence):
            self.red, self.green, self.blue = colour[:3]
            self.space = space or 0xff
            self.alpha = colour[-1] if len(colour) == 4 else None

    def __iter__(self):
        """Iterate over red, green, blue."""
        return self.red, self.green, self.blue

    def __str__(self) -> str:
        """User-friendly output."""
        return self.hex

    @property
    def hex(self) -> str:
        """Hex-coded colour"""
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
    def hex(self, colour: str):
        self.__init__(colour)

    @property
    def rgba(self) -> Tuple[int, ...]:
        """RGBA-codeed colour"""
        return tuple([pig for pig in self.__iter__()] +
                     [0xff if self.alpha is None else self.alpha])

    @rgba.setter
    def rgba(self, colour: Tuple[int, ...]):
        self.__init__(colour)

    @property
    def shade(self) -> 'Colour':
        """Invertred colour shade"""
        out_colour: List[int] = []
        lightest = self.max()
        darkest = self.min()
        for pigment in self.__iter__():
            out_colour.append(pigment + 0xff - darkest - lightest)
        if self.alpha is not None:
            out_colour.append(self.alpha)
        return Colour(out_colour, space=self.space)

    @property
    def invert(self) -> 'Colour':
        """Inverted colour"""
        out_colour: List[int] = []
        for pigment in self.__iter__():
            out_colour.append(0xff - pigment)
        if self.alpha is not None:
            out_colour.append(self.alpha)
        return Colour(out_colour, space=self.space)

    def parsergb(self, colour: str):
        """
        Parse rgba-coded colour of the form rgba(r, g, b, a) or rgb(r, g, b).

        Args:
            colour: colour string
        """
        colour_tup = colour.split('(')[1].split(')')[0]
        if 'rgba' in colour:
            red_str, green_str, blue_str, alpha_str = colour_tup.split(',')
            self.alpha = int(alpha_str)
        else:
            red_str, green_str, blue_str = colour_tup.split(',')
            self.alpha = None
        self.red = int(red_str)
        self.green = int(green_str)
        self.blue = int(blue_str)

    def parsehex(self, colour: str, space: int = None):
        """
        Parse hex-coded colour of the form [#]RGB[A] or [#]RRGGBB[AA].

        Args:
            colour: colour string
        """
        colour = colour.strip("#")
        if len(colour) >= 6:
            self.red = int(colour[:2], base=16)
            self.green = int(colour[2:4], base=16)
            self.blue = int(colour[4:6], base=16)
            self.alpha = int(colour[6:], base=16) if colour[6:] else None
            self.space = space or 0xff
        else:
            self.red = int(colour[0], base=16) * 0x10
            self.green = int(colour[1], base=16) * 0x10
            self.blue = int(colour[2], base=16) * 0x10
            self.alpha = int(colour[3:], base=16) if colour[3:] else None
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
    description = '''Transforms from COLOUR:
    1. invert colour
    2. invert shade
    3. invert colour and shade

Useful while converting style sheets to/from dark mode.

Format of COLOUR:
    Remember to quote '#', '()' OR skip \\#, \\(, \\).

    1. [#]RGB[A]
    2. [#]RRGGBB[AA]
        []: Optional, R: Red, G: Green, B: Blue, A: Alpha (hex) [0 -> f]

    3. rgb(r, g, b)
    4. rgba(r, g, b, a)
        r: Red, g: Green, b: Blue, a: Alpha (integers) [0 -> 255]'''
    parser = ArgumentParser(description=description,
                            formatter_class=RawDescriptionHelpFormatter)
    parser.add_argument(dest='colour',
                        metavar='COLOUR',
                        type=str,
                        help='input colour')
    parser.add_argument('-g',
                        '--gtk',
                        action='store_true',
                        help='display colours in a GTK+ 3 window')
    return vars(parser.parse_args())


def print_colours(colour: Colour):
    """Print colours to STDOUT."""
    print('Original:', colour)
    print('Invert:', colour.invert)
    print('Shade:', colour.shade)
    print('Shade Invert:', colour.invert.shade)


def gui(colour: Colour):
    """Show colours in GUI window."""
    import gi
    gi.require_version('Gtk', '3.0')
    gi.require_version('Gdk', '3.0')
    # import failures are caught later
    from gi.repository import Gdk, Gtk  # type: ignore

    class ColourUI(Gtk.Window):
        """User interface displaying all transformed colours."""

        def __init__(self, colour: Colour):
            self.colour = colour
            super().__init__()
            self.init_ui()
            self.connect('destroy', Gtk.main_quit)
            self.set_default_size(200, 200)

        def init_ui(self):
            """Initialize other UI elements"""
            grid = Gtk.Grid()
            self.put_colours(grid)
            self.add(grid)
            self.show_all()

        def colour_panel(self, colour_type: str, colour: Colour):
            """
            Panel with Coloured area and label

            Args:
                colour_type: Type of colour being painted
                colour: The Colour
            """
            rgba = Gdk.RGBA()
            rgba.parse(f'rgba{colour.rgba}')

            vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            button = Gtk.Button(expand=True)
            label = Gtk.Label(label=colour_type, expand=False)

            colour_area = Gtk.DrawingArea()
            colour_area.connect("draw", self.on_draw, {"colour": rgba})

            button.add(colour_area)

            button.connect('clicked', self.on_click, colour_type, colour)
            vbox.pack_start(button, True, True, 0)
            vbox.pack_end(label, False, False, 0)

            vbox.set_hexpand(True)

            return vbox

        def put_colours(self, grid: Gtk.Grid):
            """Place All 4 colours on the UI grid"""
            original_box = self.colour_panel('Original', colour=self.colour)
            invert_box = self.colour_panel('Invert', colour=self.colour.invert)
            shade_box = self.colour_panel('Shade', colour=self.colour.shade)
            ishade_box = self.colour_panel('Shade Invert',
                                           colour=self.colour.shade.invert)
            grid.attach(original_box, 0, 0, 1, 1)
            grid.attach(invert_box, 1, 0, 1, 1)
            grid.attach(shade_box, 0, 1, 1, 1)
            grid.attach(ishade_box, 1, 1, 1, 1)

        def on_draw(self, widget: Gtk.Widget, cr, data: Dict[str, Gdk.RGBA]):
            context = widget.get_style_context()

            width = widget.get_allocated_width()
            height = widget.get_allocated_height()
            Gtk.render_background(context, cr, 0, 0, width, height)

            r, g, b, a = data["colour"]
            cr.set_source_rgba(r, g, b, a)
            cr.rectangle(0, 0, width, height)
            cr.fill()

        def on_click(self, _, colour_type, colour):
            cb = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)
            cb.set_text(colour.hex, -1)
            cb.store()
            print(f'{colour_type}:', colour.hex)

    display = ColourUI(colour)
    display.show()
    Gtk.main()


def main():
    """Main routine call."""
    input_args = cli()
    colour = Colour(input_args['colour'])
    if input_args['gtk']:
        try:
            gui(colour)
        except Exception as err:
            print_colours(colour)
            raise ColourInvertError('Error displaying GTK window') from err
    else:
        print_colours(colour)


if __name__ == "__main__":
    main()
