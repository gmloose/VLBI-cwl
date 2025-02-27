#!/usr/bin/env python3
# -*- coding: utf-8 -*-

__author__ = "Jurjen de Jong"

import os
from argparse import ArgumentParser

import pandas as pd
from numpy import pi
from astropy import units as u
from astropy.coordinates import SkyCoord
from astropy.table import Table
from casacore.tables import table


def is_csv(file_path):
    """
    Checks if the given file is a CSV file based on its extension.

    Args:
        file_path: The path to the file to check.

    Returns: True if the file has a .csv extension, False otherwise.
    """
    if os.path.isfile(file_path):
        return file_path.lower().endswith('.csv')
    return False


def ra_dec_to_iltj(ra_deg, dec_deg):
    """
    Convert RA/DEC to ILTJ source name format: ILTJhhmmss.ss±ddmmss.s

    Args:
        ra_deg: Right Ascension in degrees
        dec_deg: Declination in degrees

    Returns: Source name in ILTJhhmmss.ss±ddmmss.s format
    """
    # Convert RA from degrees to hours
    ra_hours = ra_deg / 15
    ra_h = int(ra_hours)
    ra_m = int((ra_hours - ra_h) * 60)
    ra_s = ((ra_hours - ra_h) * 60 - ra_m) * 60

    # Convert DEC to degrees, minutes, seconds
    dec_sign = "+" if dec_deg >= 0 else "-"
    dec_deg_abs = abs(dec_deg)
    dec_d = int(dec_deg_abs)
    dec_m = int((dec_deg_abs - dec_d) * 60)
    dec_s = ((dec_deg_abs - dec_d) * 60 - dec_m) * 60

    # Format output string
    source_name = f"ILTJ{ra_h:02}{ra_m:02}{ra_s:05.2f}{dec_sign}{dec_d:02}{dec_m:02}{dec_s:04.1f}"

    return source_name


def get_phase_centre(ms):
    """
    Get phase centre from MeasurementSet

    Args:
        ms: MeasurementSet

    Returns: Phase centre
    """
    t = table(ms + '::FIELD', ack=False)
    phasedir = t.getcol("PHASE_DIR").squeeze()
    phasedir *= 180 / pi
    phasedir_coor = SkyCoord(ra=phasedir[0] * u.degree, dec=phasedir[1] * u.degree, frame='fk5')
    return phasedir_coor


def select_bright_sources(phase_centre: list = None, catalogue: str = None, fluxcut: float = None):
    """
    Select sources from catalogue above flux density threshold
    Args:
        catalogue: Catalogue file name
        fluxcut: Flux density cut

    Returns:

    """
    if is_csv(catalogue):
        df = pd.read_csv(catalogue)
    else:
        df = Table.read(catalogue).to_pandas()

    df = df[df['Peak_flux'] > fluxcut]
    df['sourcedir'] = SkyCoord(ra=df['RA'].to_numpy() * u.degree, dec=df['DEC'].to_numpy() * u.degree)

    indices = []
    sourceid = []
    for i, row in df.reset_index().iterrows():
        if abs(row['sourcedir'].ra-phase_centre.ra).value < 1.25 and abs(row['sourcedir'].dec-phase_centre.dec).value < 1.25:
            indices.append(i)
            sourceid.append(ra_dec_to_iltj(row['RA'], row['DEC']))

    df = df.iloc[indices]
    df['Source_id'] = sourceid
    df = df[['Source_id','RA', 'DEC', 'Peak_flux', 'Total_flux']]

    return df


def argparse():
    """
    Argument parser
    """
    parser = ArgumentParser("Pre-select sources based on Flux density.")
    parser.add_argument('--ms', type=str, help='Measurement set to read phase centre from.')
    parser.add_argument('--catalogue', type=str, help='Catalog to select candidate calibrators from.')
    parser.add_argument('--fluxcut', type=float, help='Flux density cut in mJy', default=0.0)
    return parser.parse_args()


def main():
    args = argparse()

    phase_centre = get_phase_centre(args.ms)
    out_df = select_bright_sources(phase_centre, args.catalogue, args.fluxcut)
    out_df.to_csv("bright_cat.csv", index=False)


if __name__ == '__main__':
    main()
