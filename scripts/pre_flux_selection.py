#!/usr/bin/env python3
# -*- coding: utf-8 -*-

__author__ = "Jurjen de Jong"

from argparse import ArgumentParser
import pandas as pd
from astropy.table import Table
import os
from casacore.tables import table
from numpy import pi
from astropy.coordinates import SkyCoord
from astropy import units as u


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
    for i, row in df.reset_index().iterrows():
        if abs(row['sourcedir'].ra-phase_centre.ra).value < 1.25 and abs(row['sourcedir'].dec-phase_centre.dec).value < 1.25:
            indices.append(i)
    df = df.iloc[indices][['RA', 'DEC', 'Peak_flux', 'Total_flux']]
    df['Source_id'] = range(len(df))

    return df


def argparse():
    """
    Argument parser
    """
    parser = ArgumentParser()
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