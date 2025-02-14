#!/usr/bin/env python
import json
from argparse import ArgumentParser

import numpy as np
from regions import Regions


def calculate_image_size(ras, decs, pixel_size, padding: float = 1.0):
    width_ra = abs(max(ras) - min(ras))
    width_dec = max(decs) - min(decs)
    dec_centre = (min(decs) + max(decs)) / 2

    pix_size_deg = pixel_size / 3600
    imwidth, imheight = (
        width_ra * np.cos(np.deg2rad(dec_centre)) / pix_size_deg,
        width_dec / pix_size_deg,
    )

    imsize = max(imwidth, imheight)
    blavg = 1.5e3 * 60000.0 * 2.0 * 3.1415 * 1.5 / (24.0 * 60.0 * 60 * imsize)
    return int(padding * imwidth), int(padding * imheight), blavg


def main():
    parser = ArgumentParser(
        description="Estimate the required image size based on a given pixel size and DS9 region file."
    )
    parser.add_argument(
        "--region", type=str, help="DS9 region file describing the facet."
    )
    parser.add_argument(
        "--pixel_size", type=float, help="Pixel size of the image to be made."
    )
    parser.add_argument(
        "--padding",
        type=float,
        default=1.0,
        help="Padding factor to pad the calculated image size with. This allows some extra freedom in tweaking the final image size.",
    )
    args = parser.parse_args()

    reg = Regions.read(args.region, format="ds9")
    ra = reg[0].vertices.ra.value
    dec = reg[0].vertices.dec.value
    width, height, blavg = calculate_image_size(ra, dec, args.pixel_size, args.padding)
    with open("bounding_box.json", "w") as f:
        json.dump({"width": width, "height": height, "blavg": blavg}, f)


if __name__ == "__main__":
    main()
