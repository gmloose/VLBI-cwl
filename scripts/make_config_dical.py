#!/usr/bin/env python3
# -*- coding: utf-8 -*-

__author__ = "Jurjen de Jong"

from argparse import ArgumentParser
import re
from os import path

import numpy as np
import pandas as pd

import casacore.tables as ct


def make_config(phasediff, ms):
    """
    Make config for facetselfcal

    Args:
        phasediff: phasediff score
        ms: MeasurementSet
    """

    filename = parse_source_from_h5(ms)

    # Get time array
    with ct.table(ms, readonly=True, ack=False) as t:
        time = np.unique(t.getcol('TIME'))

    deltime = np.abs(time[1]-time[0])

    if phasediff<0.03:
        solint_scalarphase_1 = max(deltime, 8)
        solint_scalarphase_2 = max(deltime, 16)
        solint_scalarphase_3 = max(deltime, 64)
        solint_scalarcomplex = max(deltime, 1800)

        smoothness_constraint_0 = 10.0
        smoothness_constraint_1 = 2.0
        smoothness_constraint_2 = 10.0
        smoothness_constraint_3 = 20.0
        smoothness_constraint_4 = 20.0

    elif phasediff<0.1:
        solint_scalarphase_1 = max(deltime, 16)
        solint_scalarphase_2 = max(deltime, 32)
        solint_scalarphase_3 = max(deltime, 128)
        solint_scalarcomplex = max(deltime, 2400)

        smoothness_constraint_0 = 20.0
        smoothness_constraint_1 = 2.0
        smoothness_constraint_2 = 10.0
        smoothness_constraint_3 = 20.0
        smoothness_constraint_4 = 25.0

    else:
        solint_scalarphase_1 = max(deltime, 32)
        solint_scalarphase_2 = max(deltime, 64)
        solint_scalarphase_3 = max(deltime, 256)
        solint_scalarcomplex = max(deltime, 3600)

        smoothness_constraint_0 = 20.0
        smoothness_constraint_1 = 3.0
        smoothness_constraint_2 = 15.0
        smoothness_constraint_3 = 25.0
        smoothness_constraint_4 = 40.0

    avgstep = deltime//solint_scalarphase_1

    resetsols_list = "[None,'alldutch','core',None,None]"
    antennaconstraint_list = "['alldutch',None,None,None,None]"
    soltype_list = "['scalarphasediff','scalarphase','scalarphase','scalarphase','scalarcomplexgain']"
    solint_list = f"['4min','{int(solint_scalarphase_1)}s','{int(solint_scalarphase_2)}s','{int(solint_scalarphase_3)}s','{int(solint_scalarcomplex)}s']"
    smoothnessconstraint_list = f"[{smoothness_constraint_0},{smoothness_constraint_1},{smoothness_constraint_2},{smoothness_constraint_3},{smoothness_constraint_4}]"
    soltypecycles_list = f'[0,0,0,1,3]'
    smoothnessreffrequency_list = "[120.0,120.0,120.0,120.0,0.0]"
    smoothnessspectralexponent_list = "[-1.0,-1.0,-1.0,-1.0,-1.0]"
    uvmin = 40000
    stop = 20
    imsize = 1600

    config=f"""imagename                       = "{filename}"
phaseupstations                 = "core"
forwidefield                    = True
docircular                      = True
autofrequencyaverage            = True
update_multiscale               = True
skipbackup                      = True
soltypecycles_list              = {soltypecycles_list}
soltype_list                    = {soltype_list}
smoothnessconstraint_list       = {smoothnessconstraint_list}
smoothnessreffrequency_list     = {smoothnessreffrequency_list}
smoothnessspectralexponent_list = {smoothnessspectralexponent_list}
solint_list                     = {solint_list}
uvmin                           = {uvmin}
imsize                          = {imsize}
resetsols_list                  = {resetsols_list}
antennaconstraint_list          = {antennaconstraint_list}
paralleldeconvolution           = 1024
stop                            = {stop}
parallelgridding                = 6
channelsout                     = 12
fitspectralpol                  = 5
"""
    if avgstep>1:
        config+=f"""avgtimestep                     = {avgstep}
"""
        config += f"""avgfreqstep                     = {avgstep}
    """

    # write to file
    with open(filename+".config.txt", "w") as f:
        f.write(config)

    print("CREATED: "+filename+".config.txt")


def parse_source_from_h5(h5):
    """
    Parse output name
    (From lofar_facet_selfcal)
    """
    h5 = path.basename(h5)

    def apply_common_replacements(name):
        # Common replacements for stripping suffixes/prefixes
        replacements = [
            ("merged_", ""), ("addCS_", ""), ("selfcalcycl", ""), ("selfcalcycle", ""),
            (".ms", ""), (".copy", ""), (".phaseup", ""), (".h5", ""), (".dp3", ""),
            ("-concat", ""), (".phasediff", ""), ("_uv", ""), ("scalarphasediff0_sky", "")
        ]
        for old, new in replacements:
            name = name.replace(old, new)
        return re.sub(r'(\D)\d{3}_', '', name)

    if 'ILTJ' in h5:
        matches = re.findall(r'ILTJ\d+\.\d+\+\d+\.\d+_L\d+', h5)
        if not matches:
            matches = re.findall(r'ILTJ\d+\.\d+\+\d+\.\d+', h5)
            if not matches:
                return apply_common_replacements(h5)
        return matches[0]

    elif 'selfcalcycle' in h5:
        match = re.search(r'selfcalcycle\d+_(.*?)\.', h5)
        return match.group(1) if match else apply_common_replacements(h5)

    else:
        return apply_common_replacements(h5)


def get_phasediff(ms, phasediff_output):
    """
    Get phasediff score

    Args:
        ms: MeasurementSet.
        phasediff_output: Path to the Phase-diff CSV output.

    Returns:
        solint: Solution interval in minutes.
    """

    phasediff = pd.read_csv(phasediff_output)
    sourceid = parse_source_from_h5(ms.split("/")[-1])

    for col in ['Source_id', 'source']:  # Handling possible column variations (versions)
        if col in phasediff.columns:
            return phasediff[phasediff[col].apply(parse_source_from_h5) == sourceid]['spd_score'].min()

    raise ValueError("Expected column 'Source_id' or 'source' not found in phasediff_output.")


def parse_args():
    """
    Command line argument parser

    Returns: parsed arguments
    """

    parser = ArgumentParser(description='Make parameter configuration file for facetselfcal.')
    parser.add_argument('--ms', type=str, help='MeasurementSet')
    parser.add_argument('--phasediff_output', type=str, help='Phasediff CSV output')
    return parser.parse_args()


def main():
    """
    Main function
    """

    args = parse_args()

    phasediff = get_phasediff(args.ms, args.phasediff_output)
    make_config(phasediff, args.ms)


if __name__ == "__main__":
    main()
