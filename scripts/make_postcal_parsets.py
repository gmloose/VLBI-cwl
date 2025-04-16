import pandas as pd
from argparse import ArgumentParser
from os.path import basename


def parse_args():
    """
    Command line argument parser

    Returns: parsed arguments
    """

    parser = ArgumentParser(description='Make selfcal parsets')
    parser.add_argument('--ms', nargs="+", help='Input MS', default=None)
    parser.add_argument('--polygon_info', type=str, help='Polygon information CSV')
    return parser.parse_args()


def main():
    """
    Main function
    """

    args = parse_args()

    df = pd.read_csv(args.polygon_info)
    facets = sorted(args.ms)

    for row in df.iterrows():
        idx = row[1]['idx'][idx]
        center = row[1]['dir'][idx]
        ms = facets[idx]
        parset=f"""
msin={ms}
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