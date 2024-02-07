#!/usr/bin/env python
import argparse
import math

import casacore.tables as ct


def main(ms: str, box_size: float = 2.5):
    """Generates a DS9 region file that is used to subtract a LoTSS skymodel from the data.

    Args:
        ms (str): a MeasurementSet to obtain the phase center from.
        box_size (float): size in degrees of the box outside which to subtract LoTSS. Defaults to 2.5 deg.

    Returns:
        None
    """
    if type(ms) is not str:
        raise ValueError("Expected a single MeasurementSet.")
    with ct.table(ms + "::FIELD") as field:
        phasedir = field.getcol("PHASE_DIR").squeeze()
        phasedir_deg = phasedir * 180.0 / math.pi
        # RA, DEC, Size, Rotation
        regionstr = (
            "fk5\nbox({ra:f},{dec:f},{size:f},{size:f},0.0) # color=green".format(
                ra=phasedir_deg[0], dec=phasedir_deg[1], size=float(box_size)
            )
        )
    with open("boxfile.reg", "w") as f:
        f.write(regionstr)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Make a box outside of which to subtract LoTSS."
    )
    parser.add_argument(
        "ms", type=str, help="A MeasurementSet containing the relevant phase centre."
    )
    parser.add_argument(
        "box_size",
        type=float,
        default=2.5,
        help="Size of the sides of the subtract box in degrees.",
    )

    args = parser.parse_args()
    main(args.ms, box_size=args.box_size)
