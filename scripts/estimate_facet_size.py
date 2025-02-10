#!/usr/bin/env python
from argparse import ArgumentParser

from regions import Regions
import numpy as np

def calculate_image_size(ras, decs, pixel_size, padding: float = 1.0):
    width_ra = abs(max(ras) - min(ras))
    width_dec = max(decs) - min(decs)
    dec_centre = (min(decs) + max(decs)) / 2

    pix_size_deg = pixel_size / 3600
    imwidth, imheight = width_ra * np.cos(np.deg2rad(dec_centre)) / pix_size_deg, width_dec / pix_size_deg
    return padding * imwidth, padding * imheight

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
        "--padding", type=float, help="Padding factor to pad the calculated image size with. This allows some extra freedom in tweaking the final image size."
    )
    args = parser.parse_args()

    reg = Regions.read(args.region, format="ds9")
    ra = reg[0].vertices.ra.value
    dec = reg[0].vertices.dec.value
    width, height = calculate_image_size(ra, dec, args.pixel_size, args.padding)
    with open("bouding_box.txt", "w") as f:
        f.write(f"{width} {height}")

if __name__ == "__main__":
    main()
