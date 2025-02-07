#!/usr/bin/env python
from argparse import ArgumentParser

from regions import Regions

def calculate_image_size(ras, decs, padding):
    width_ra = max(ra) - min(ra)
    width_dec = max(ra) - min(ra)

    pix_size_deg = args.pixel_size / 3600
    imwidth, imheight = width_ra / pix_size_deg, width_dec / pix_size_deg
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
    width, height = calculate_image_size(ra, dec)
    with open("bouding_box.csv", "w") as f:
        f.write(f"{width},{height}")

if __name__ == "__main__":
    main()
