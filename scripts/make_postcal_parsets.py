#!/usr/bin/env python3
import pandas as pd
from argparse import ArgumentParser
from os.path import basename


def parse_args():
    """
    Command line argument parser

    Returns: parsed arguments
    """

    parser = ArgumentParser(description='Make selfcal parsets')
    parser.add_argument('--msin', nargs="+", help='Input MS', default=None)
    parser.add_argument('--polygon_info', type=str, help='Polygon information CSV')
    return parser.parse_args()


def main():
    """
    Main function
    """

    args = parse_args()

    df = pd.read_csv(args.polygon_info)
    facets = sorted(args.msin)
    dirnums = [d.replace("Dir","") for d in df['dir_name']]

    for idx, ms in enumerate(facets):
        facetnum = ms.split("-")[0].replace("facet_","")
        dirnum = dirnums.index(facetnum)
        center = df['dir'][dirnum]
        parset=f"""
msin={basename(ms)}
msout=selfcal_{basename(ms)}
steps=[ps,avg,beam]
avg.type=averager
avg.timeresolution=32
avg.freqresolution='390.56kHz'
msout.storagemanager='dysco'
ps.type=phaseshift
ps.phasecenter={center}
beam.type=applybeam
beam.direction=[]
beam.updateweights=True
"""
        # write to file
        with open("selfcal_" + basename(ms) + ".txt", "w") as f:
            f.write(parset)


if __name__ == "__main__":
    main()