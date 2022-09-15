#!/usr/bin/env python3
import numpy as np
import subprocess
import shutil
import sys
import glob
import regex as re
from astropy.coordinates import SkyCoord
from astropy.table import Table


def write_skymodel (ra, dec, model, outname = None):

    print(f'writing the skymodel for: {model}')

    if outname:
        with open(outname, 'w') as skymodel:
            skymodel.write ('# (Name, Type, Ra, Dec, I, MajorAxis, MinorAxis, Orientation) = format\n')
            for i in range(len(model)):
                # the angles RA and DEC should be sexigesimal coordinates, which for 
                # RA is in hours, minutes, seconds (format "XXhYYmZZs") and for
                # DEC is in degrees, minutes, seconds (format "XXdYYmZZs").
                # These should be formatted as strings. If, instead, the angles are
                # given in decimal degrees (floats), a conversion to the previous format is applied.
                if isinstance( (ra, dec), (str, str) ):
                    sra = ra
                    sdec = dec
                else:
                    cosd = 3600.*np.cos(np.deg2rad(dec))
                    s = SkyCoord(ra-model[i,0]/cosd,dec+model[i,1]/3600,unit='degree')
                    s = s.to_string(style='hmsdms')
                    sra = s.split()[0]
                    sdec = s.split()[1]
                sra = sra.replace('h',':').replace('m',':').replace('s','')
                sdec = sdec.replace('d','.').replace('m','.').replace('s','')
                print('ME%d, GAUSSIAN, %s, %s, %f, %f, %f, %f'%(i,sra,sdec,model[i,2],\
                      model[i,3],model[i,3]*model[i,4],np.rad2deg(model[i,5])))
                skymodel.write('ME%d, GAUSSIAN, %s, %s, %f, %f, %f, %f\n'%(i,sra,sdec,model[i,2],\
                               model[i,3],model[i,3]*model[i,4],np.rad2deg(model[i,5])))

################## skynet ##############################

def main (MS, delayCalFile):

    ## make sure the parameters are the correct format
    # MS is assumed to be of the form:
    # /path/to/MS/{observation_id}_*
    # We are only interested in {observation_id} here,
    # and discard the rest.

    # {observation_id} should start with either 'S', 'L', 'I'
    # followed by a number of digits
    if not re.search(r'\/([SLI]\d+)\_', MS):
        ValueError(f"{MS} does not contain a valid observation ID")
    MS = MS.rstrip('/')
    tmp = MS.split('/')[-1]
    MS_src = tmp.split('_')[0]

    ## get flux from best_delay_calibrators.csv
    t = Table.read( delayCalFile, format='csv' )
    ## find the RA column

    mycols = t.colnames
    # Check if the skymodel uses a LBCS-format catalogue,
    # which has coordinates in columns 'RA' and 'DEC',
    # or if it uses a LoTSS catalogue, which has its
    # coordinates in columns called 'RA_LOTSS' and 'DEC_LOTSS'
    if (('RA' in mycols) and ('DEC' in mycols)):
        ra_col = 'RA'
        de_col = 'DEC'
    else:
        ra_col = 'RA_LOTSS'
        de_col = 'DEC_LOTSS'
    src_ids = t['Source_id']

    src_names = []
    for src_id in src_ids:
        if isinstance(src_id, str):
            # Check if the name comes from the LoTSS catalogue
            if src_id.startswith('I'):
                val = str(src_id)
            # Check if the name is the gaussian ID
            elif MS_src.startswith('S'):
                val = 'S'+str(src_id)
            # In this case the name is the LBCS observation ID
            # and starts with an 'L'
            else:
                val = str(src_id)
                if MS_src.startswith('S'):
                    val = 'S'+str(src_id)
                else:
                    val = str(src_id)
        else:
            val = src_id
        src_names.append(val)
    src_idx = [ i for i, val in enumerate(src_names) if MS_src == val ][0]

    # get the coordinate values and the flux from the skymodel
    # and convert the flux from mJy to Jy.
    ra = t[ra_col].data[src_idx]
    dec = t[de_col].data[src_idx]
    smodel = t['Total_flux'].data[src_idx]*1.0e-3

    print('generating point model')
    point_model = np.array( [ [0.0,0.0,smodel,0.1,0.0,0.0] ] )
    write_skymodel (ra,dec,point_model,MS+'/skymodel')

    # run makesourcedb to generate sky
    # makesourcedb will update an existing skymodel
    # by adding its output to it, so if a sky directory
    # is already present it has to be removed first.
    shutil.rmtree('{MS}/sky', ignore_errors=True) # ignore the exception if {MS}/sky doesn't exist
    makesourcedb_out = subprocess.run(['makesourcedb',
                                       f'in={MS}/skymodel',
                                       f'out={MS}/sky',
                                       'format=<'] ,
                                       capture_output=True, text=True)
    print("makesourcedb output:", makesourcedb_out.stdout)
    print("makesourcedb error:", makesourcedb_out.stderr)


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Skynet script to handle LBCS calibrators.")

    parser.add_argument('MS', type=str, help='Measurement set for which to run skynet')
    parser.add_argument('--delay-cal-file', required=True, type=str,help='delay calibrator information')

    args = parser.parse_args()

    main( args.MS, delayCalFile=args.delay_cal_file )
