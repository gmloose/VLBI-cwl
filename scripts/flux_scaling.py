#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb  3 15:12:32 2025

@author: pwcc62
"""
from astropy.table import Table
import matplotlib.pyplot as plt
import argparse

def flux_scale(fitsfile, lotss_flux, image_flux):
    """
    Script to determine the flux scaling required between lotss and an input image
    """

    matches = Table.read(fitsfile)

    flux_6 = matches['{}'.format(lotss_flux)] ##Total_flux_1
    bdsf_flux = matches['{}'.format(image_flux)] ##_2

    flux_scale = bdsf_flux/flux_6

    scale = Table()
    scale['flux_scale'] = flux_scale
    scale.write('flux_scale.csv', format='csv', overwrite=True)

    plt.scatter(bdsf_flux, flux_6, color='purple', marker='o')
    plt.xlabel('1.2" flux')
    plt.ylabel('6" flux')
    plt.savefig('flux_scaling.png')

    return flux_scale

def parse_args():
    
     parser = argparse.ArgumentParser(description='Find flux scaling between 6" and pyBDSF image')
     parser.add_argument('--fitsfile', type=str, help='source_catalouge from pyBDSF with both image and 6" flux values')
     parser.add_argument('--lotss_flux', type=str, help='column name of total flux from 6" catalouge')
     parser.add_argument('--image_flux', type=str, help='column name of total flux from pyBDSF catalouge')
     return parser.parse_args()
 
def main():
    """
    Main function
    """

    args = parse_args()
    flux_scale(args.fitsfile, args.lotss_flux, args.image_flux)

if __name__ == '__main__':
    main()
 

