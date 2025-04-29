#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb  3 11:15:16 2025

@author: pwcc62
"""

from astropy.table import Table
from astropy import units as u
import matplotlib.pyplot as plt
import argparse
import os

##example input below
##python3 astrometry.py --crossmatch_fits "/home/pwcc62/AGN_outflows/Bootes_nonAGN/bootes_final_cross_match_catalogue-v1.0.fits" 
#--source_fits "test_source_catalouge.fits" --ra1 "optRA" --ra2 "RA_bdsf" --dec1 "optDec" --dec2 "DEC_bdsf" --error 5

#DR1 = Table.read('/home/pwcc62/AGN_outflows/Bootes_FITS/bootes_optIR_catalogue_full.fits')
#source_cat = Table.read('/home/pwcc62/Bootes/test_source_catalog.fits')

def astrometry(crossmatch_fits, source_fits, ra1, ra2, dec1, dec2, error):
    
    """
    Script to determine the astrometry off set between e.g lotss and another image
    
    """

    cmd1 = 'stilts tskymatch2 in1="{}" in2="{}" out=source_matches.fits ra1={} dec1={} ra2={} dec2={} error={} join=1and2'.format(crossmatch_fits, source_fits, ra1, dec1, ra2, dec2, error)
    #cmd1 = 'stilts tskymatch2 in1=\"/home/pwcc62/AGN_outflows/Bootes_nonAGN/bootes_final_cross_match_catalogue-v1.0.fits\" in2="test_source_catalouge.fits" out=source_matches.fits ra1=optRA dec1=optDEC ra2=RA_bdsf dec2=DEC_bdsf error=1 join=1and2'
    print(cmd1)
    with open('match_test.sh','w') as f:
        f.write(cmd1)
        f.write('\n')

    os.system('bash match_test.sh')

    matches = Table.read("source_matches.fits") ## want RA_bdsf as this is from source_catalouge

    bdsf_ra = matches['{}'.format(ra2)]
    bdsf_dec = matches['{}'.format(dec2)]
    opt_ra = matches['{}'.format(ra1)]
    opt_dec = matches['{}'.format(dec1)]

    ra_offset = (opt_ra - bdsf_ra) * u.deg
    dec_offset = (opt_dec - bdsf_dec) * u.deg

    ra_off_arcsec = ra_offset.to(u.arcsec)
    dec_off_arcsec = dec_offset.to(u.arcsec)
    ra_off = Table()
    ra_off['ra_offset'] = ra_off_arcsec
    dec_off = Table()
    dec_off['dec_offset'] = dec_off_arcsec
    ra_off.write('ra_offset.csv', format='csv', overwrite=True)
    dec_off.write('dec_offset.csv', format='csv', overwrite=True)
    
    new_cmap = plt.cm.plasma(np.linspace(0,1,255))

    fig = plt.figure(figsize=(12, 10))
    grd = plt.GridSpec(4, 4, hspace=0.2, wspace=0.2)

    ax = fig.add_subplot(grd[1:, :-1]) #main plot
    lax = fig.add_subplot(grd[1:, -1], sharey=ax) #left plot
    bax = fig.add_subplot(grd[0, :-1], sharex=ax) #top plot
    #fig = plt.figure()
    
    ax.scatter(ra_off_arcsec, dec_off_arcsec, color=new_cmap[50], alpha=0.4, marker='*')
    lax.hist(dec_off_arcsec, orientation='horizontal', color=new_cmap[50], alpha=0.4)
    bax.hist(ra_off_arcsec, color=new_cmap[50], alpha=0.4)
    
    ax.set_xlabel('RA_offset')
    ax.set_ylabel('DEC_offset')
    plt.savefig('astrometry_offset.png')
    
    return ra_off, dec_off


def parse_args():
    
     parser = argparse.ArgumentParser(description='Find Astrometry offset to 6" image')
     parser.add_argument('--crossmatch_fits', type=str, help='6" catalouge with flux values')
     parser.add_argument('--source_fits', type=str, help='source_catalouge from pyBDSF')
     parser.add_argument('--ra1', type=str, help='column name of ra from crossmatch catalouge')
     parser.add_argument('--ra2', type=str, help='column name of ra from pyBDSF catalouge')
     parser.add_argument('--dec1', type=str, help='column name of dec from crossmatch catalouge')
     parser.add_argument('--dec2', type=str, help='column name of dec from pyBDSF catalouge')
     parser.add_argument('--error', type=str, help='Error for source location for crossmatching', default=5)

     return parser.parse_args()
 
def main():
    """
    Main function
    """

    args = parse_args()
    astrometry(args.crossmatch_fits, args.source_fits, args.ra1, args.ra2, args.dec1, args.dec2, args.error)


if __name__ == '__main__':
    main()
