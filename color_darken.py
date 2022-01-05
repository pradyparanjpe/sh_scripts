#!/usr/bin/env python3
# -*- coding: utf-8; mode: python; -*-

from typing import Dict, Tuple
from argparse import ArgumentParser
from psprint import print


def cli():
    """
    Parse command line

    """
    parser = ArgumentParser()
    parser.add_argument('color', type=str, help='input color')
    return vars(parser.parse_args())


def darken(color: Tuple[int, int, int], space: int) -> str:
    """
    darken colors within space

    """
    out_color = ['#']
    lightest = max(color)
    darkest = min(color)
    for pigment in color:
        col_t = pigment + space - darkest - lightest
        out_color.append(f'{col_t:02x}' if space == 0xff else f'{col_t:1x}')
    return ''.join(out_color)


def invert(color: Tuple[int, int, int], space: int) -> str:
    """
    Invert colors w.r.t. space

    """
    out_color = ['#']
    for pigment in color:
        col_i = space - pigment
        out_color.append(f'{col_i:02x}' if space == 0xff else f'{col_i:1x}')
    return ''.join(out_color)


def transform(color: str) -> Dict[str, str]:
    """
    Transform to:
        1: invert (rgb<->cmy)
        2: shift (lrlglb<->drdhdb)
    """
    transformation = {}
    if color[0] == "#":
        color = color[1:]
    if len(color) == 6:
        color_rgb = (int(color[:2], base=16),
                     int(color[2:4], base=16),
                     int(color[4:], base=16))
        space = 0xff
    else:
        color_rgb = (int(color[0], base=16),
                     int(color[1], base=16),
                     int(color[2], base=16))
        space = 0xf
    transformation['invert'] = invert(color_rgb, space)
    transformation['shift'] = darken(color_rgb, space)
    return transformation


def main():
    """
    Main routine call

    """
    input_args = cli()
    print(transform(input_args['color']), iterate=True)


if __name__ == "__main__":
    main()
