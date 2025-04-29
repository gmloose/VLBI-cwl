#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb  3 09:47:43 2025

@author: pwcc62
"""

import bdsf
import argparse
from astropy.table import Table

def source_finder(input_image, rmsbox, thresh_isl, thresh_pix):
    """
    Script to create source catalouge for an imput fits image
    """
    
    prefix = input_image.split('/')[-1].replace('.fits','')
    img = bdsf.process_image(input_image, thresh_isl=thresh_isl, thresh_pix=thresh_pix, rms_box=(int(rmsbox),int(rmsbox)), rms_box_bright=(int(rmsbox/3),int(rmsbox/3)))
    img.write_catalog(clobber=True, outfile='source_catalouge.fits', format='fits', catalog_type='srl')
    img = Table.read('source_catalouge.fits')
    img_ra = img['RA']
    img['RA'] = (img_ra + 360) % 360
    img['RA'].name = 'RA_bdsf'
    img['DEC'].name = 'DEC_bdsf'
    img.write('source_catalouge.fits', overwrite=True, format='fits')
    
    return img

def parse_args():
    
     parser = argparse.ArgumentParser(description='Source Finding with pyBDSF')
     parser.add_argument('--rmsbox', type=float, help='rms box pybdsf', default=120)
     parser.add_argument('--thresh_isl', type=float, help='sigma threshold for island detections with pybdsf', default=5)
     parser.add_argument('--thresh_pix', type=float, help='sigma threshold for pixel with pybdsf', default=5)
     parser.add_argument('--input_image', help='input image for source finding')
     return parser.parse_args()
 

def main():
    """
    Main function
    """

    args = parse_args()
    source_finder(args.input_image, args.rmsbox, args.thresh_isl, args.thresh_pix)


if __name__ == '__main__':
    main()

